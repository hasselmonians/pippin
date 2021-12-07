function self = genModels(self, nFold)

    self.models = [];
    if ~exist('nFold','var')
        nFold = 5;
    end
    
    for i = 1:length(self.predictors)
        dat{i} = self.predictors(i).data;
    end
    
    %% Generate training and test sets
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
    
    %% Generate and Evaluate all models
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
    
    %% LLRT
    for i = 1:size(perm,1)
        for k = 1:size(perm,1)
            [p(i,k), T(i,k)] = LLRT(models(i), models(k));
            if i==k
                p(i,k) = NaN;
            end
        end
    end
    
    %% Model which has no improvements
    models(1).p = [1, 0];
    for i = 2:length(models)
        step = find(arrayfun(@(x) x.n, models)==models(i).n-1);
        clear p_ dropped
        for k = 1:length(step)
            try
                dropped(k) = find((models(step(k)).params==0) & (models(i).params==1));
                p_(k) = LLRT(models(step(k)), models(i));
            catch
                dropped(k) = NaN;
                p_(k) = NaN;
            end
        end
        dropped = dropped(~isnan(dropped));
        p_ = p_(~isnan(p_));
        models(i).p(dropped) = p_';
    end
    
    maxModel = find(arrayfun(@(x) all(x.p(:,2) < self.sigThresh), models));
    
    [~,ind] = max(arrayfun(@(x) nanmean(x.llTest), models(maxModel)));
    maxModel = maxModel(ind);
    
    %% get p values for maxModel's missing preds
    prms = models(maxModel).params;
    msng = find(prms==0);
    pMax = [];
    for i=1:length(msng)
        prms_ = prms;
        prms_(msng(i)) = 1;
        cmp = find(arrayfun(@(x) all(x.params==prms_), models));
        [p_, t_] = LLRT(models(maxModel), models(cmp));
        models(maxModel).p(msng(i)) = p_;
    end
    
    for i = 1:length(models(maxModel).params)
        models(maxModel).Summary(i,1) = i;
        models(maxModel).Summary(i,2) = i;
        models(maxModel).Summary(i,3) = i;
    end
    %% ModelA (full model)
    ma = cell2mat(dat);
    bads = find(sum(isnan(ma),2)>0);
    ma(bads,:) = [];
    ST = self.SpikeTrain;
    ST(bads) = [];
    
    [betaA, devA, statsA] = glmfit(ma, ST, 'poisson','Constant','0ff');
    self.fullModel.beta = betaA;
    self.fullModel.dev = devA;
    self.fullModel.stats = statsA;
    [lambdaA, upb, lowb] = glmval(self.fullModel.beta, ma, 'log',statsA,'Constant','0ff');
    self.fullModel.lambda = lambdaA;
    self.fullModel.lambda_l = lambdaA - lowb;
    self.fullModel.lambda_u = lambdaA + upb;
    
    LL = nansum(log(poisspdf(ST, lambdaA)));
    self.fullModel.LogLikelihood = LL;
    self.fullModel.AIC = -2*LL + 2*size(ma,2);
    
    
    %% For each reduced   
    if length(dat) > 1
        for i = 1:length(dat)

            %% Fit ModelC
            inds = 1:length(dat);
            inds(i) = [];

            mc = cell2mat(dat(inds));
            mc(bads,:) = [];
            [betaC, devC, statsC] = glmfit(mc, ST, 'poisson','Constant','Off');
            self.models(i).beta = betaC;
            self.models(i).dev = devC;
            self.models(i).difDev = devC-devA;
            self.models(i).stats = statsC;

            [lambda, upb, lowb] = glmval(self.models(i).beta, mc, 'log', statsC,'Constant','Off');
            self.models(i).lambda = lambda;
            self.models(i).lambda_l = lowb;
            self.models(i).lambda_u = upb;


            LL = nansum(log(poisspdf(ST, lambda)));
            self.models(i).LogLikelihood = LL;
            self.models(i).AIC = -2*LL + 2*size(mc,2);
            self.models(i).dAIC = self.models(i).AIC - self.fullModel.AIC;

            self.models(i).n_params = size(ma,2)-size(mc,2);
            self.models(i).n_params_total = size(mc,2);
            self.models(i).p = 1-chi2cdf(self.models(i).difDev,self.models(i).n_params);


            %% Model CC
            mcc = cell2mat(dat(i));
            mcc(bads,:) = [];
            if i == 1
                [betaCc, devCc, statsCc] = glmfit(mcc, ST, 'poisson','Constant','off');
            else
                [betaCc, devCc, statsCc] = glmfit(mcc, ST, 'poisson','Constant','on');
            end
            
            self.models(i).cc.beta = betaCc;
            self.models(i).cc.devCc = devCc;
            self.models(i).cc.stats = statsCc;
            
            if i == 1
                [lambda, upb, lowb] = glmval(betaCc, mcc, 'log', statsCc,'Constant','off');
            else
                [lambda, upb, lowb] = glmval(betaCc, mcc, 'log', statsCc,'Constant','on');
            end
            
            self.models(i).cc.lambda = lambda;
            
            %disp(i)
            %disp(length(self.models(i).cc.beta))
        end
    end
    
    %% create model using only the significant groups
    T = self.Summary();
    inds = T.p < self.sigThresh;
    if ~any(inds)  % If nothing is significant, at least test the FR
        inds(1) = 1;
    end
    
    pred = arrayfun(@(x) x.data, self.predictors(inds),'UniformOutput',0);
    pred = cell2mat(pred);
    pred(bads,:) = [];
    [betaA, devA, statsA] = glmfit(pred, ST, 'poisson','Constant','0ff');
    self.bestModel.beta = betaA;
    self.bestModel.dev = devA;
    self.bestModel.stats = statsA;
    [lambdaA, upb, lowb] = glmval(self.bestModel.beta, pred, 'log',statsA,'Constant','0ff');
    self.bestModel.lambda = lambdaA;
    self.bestModel.lambda_l = lambdaA - lowb;
    self.bestModel.lambda_u = lambdaA + upb;
    
    LL = nansum(log(poisspdf(ST, lambdaA)));
    self.bestModel.LogLikelihood = LL;
    self.bestModel.AIC = -2*LL + 2*size(pred,2);
        
end


function [p, T] = LLRT(model1, model2)
    % model 1 = simple
    % model 2 = complex
    T= -2*nanmean(model1.llTest)+nanmean(2*model2.llTest);
    p = 1-chi2cdf(T, model2.nParams - model1.nParams);

end








