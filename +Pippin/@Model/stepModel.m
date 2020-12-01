function [best] = stepModel(self, nFold)
    
    if ~exist('n','var')
        nFold=2;
    end
    
    block = randi(nFold,length(self.SpikeTrain),1);
    bads = sum(cell2mat(arrayfun(@(x) isnan(x.data), self.predictors, 'UniformOutput', false)),2)>0;

    for i = 1:nFold
        train{i} = find(block~=i & ~bads);
        test{i} = find(block==i & ~bads);
    end
    
    n = length(self.predictors)-1;
    perm = dec2bin(0:(2^n)-1)-'0';
    perm = [ones(size(perm,1),1) perm];
    ST = self.SpikeTrain;
    
    %%
    for i = 1:size(perm,1)
        for k = 1:nFold
            % fit
            preds = perm(i,:);
            preds = cell2mat(arrayfun(@(x) x.data(train{k},:), self.predictors(find(preds)), 'UniformOutput',0));
            [betaTrain, devTrain, statsTrain] = glmfit(preds, ST(train{k}), 'poisson','Constant','off');
            llTrain = sum(log(poisspdf(ST(train{k}), glmval(betaTrain, preds, 'log','Constant','off'))));

            % eval on test
            preds = perm(i,:);
            preds = cell2mat(arrayfun(@(x) x.data(test{k},:), self.predictors(find(preds)), 'UniformOutput',0));
            llTest = sum(log(poisspdf(ST(test{k}), glmval(betaTrain, preds, 'log','Constant','off'))));

            models(i).llTrain(k) = llTrain;
            models(i).llTest(k) = llTest;
            models(i).nParams = size(preds,2);
            models(i).n = sum(perm(i,:));
            models(i).betaTrain(k,:) = betaTrain;
            models(i).params = perm(i,:);
        end
    end
    models = models(:);
    
    %%
    for i = 1:size(perm,1)
        for k = 1:size(perm,1)
            [p(i,k), T(i,k)] = LLRT(models(i), models(k));
            if i==k
                p(i,k) = NaN;
            end
        end
    end
    
    %% 
    bestModel = 1;
    steps = 0;
    change=1;
    
    while change
        change=0; change_add=0; change_rem=0;
        bmo = bestModel;
        steps = steps+1;
        
        %% Adding
        n = models(bestModel).n;
        incr = arrayfun(@(x) x.n, models) == (n+1);
        
        clear nest
        for k = 1:length(models)
            nest(k) = all((models(k).params == models(bestModel).params) | models(bestModel).params==0);
        end
        
        test = find(nest' & incr);
        p_ = p(bestModel, test);
        ll = arrayfun(@(x) nanmean(x.llTest), models(test));
        ll(p_>0.01) = -inf;
        
        if any(ll>nanmean(models(bmo).llTest))
            [~,ind] = max(ll);
            bestModel = test(ind);
            change_add = ~(bestModel==bmo);
            disp('add')
        end
        
        %% Removing
        n = models(bestModel).n;
        incr = arrayfun(@(x) x.n, models) == (n-1);

        clear nest p_
        for k = 1:length(models)
            nest(k) = all((models(k).params == models(bestModel).params) | models(k).params==0);
        end

        test = find(nest' & incr);
        if ~isempty(test)
            for k = 1:length(bestModel)
                p_(k) = LLRT(models(test(k)), models(bestModel));
            end

            test = test(find(p_>0.01));
            if ~isempty(test)
                ll = arrayfun(@(x) nanmean(x.llTest), models(test));
                ll(p_<0.01) = -inf;

                [~,ind] = max(ll);
                bestModel = test(ind);
                change_rem = ~(bestModel==bmo);
                disp('remove')
            else
               change_rem = 0; 
            end
        else
            change_rem = 0;
        end
        
        %% 
        change = change_add || change_rem;
    end
    
best = models(bestModel);
  
end

function [p, T] = LLRT(model1, model2)
    % model 1 = simple
    % model 2 = complex
    T= -2*nanmean(model1.llTest)+nanmean(2*model2.llTest);
    p = 1-chi2cdf(T, model2.nParams - model1.nParams);

end


