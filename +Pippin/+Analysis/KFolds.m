function [isa] = KFolds(model, n)
    
    if ~exist('n','var')
        n = 10;
    end
    
    
    block = randi(n,length(model.SpikeTrain),1);

    for i = 1:n
        train = model;
        test = model;

        for k = 1:length(train.predictors)
            train.predictors(k).data = train.predictors(k).data(block~=i,:);
            test.predictors(k).data = test.predictors(k).data(block==i,:);
        end

        train.SpikeTrain = train.SpikeTrain(block~=i);
        test.SpikeTrain = test.SpikeTrain(block==i);


        train = train.genModels;
        test = test.genModels;

        %%
        for pa = 1:length(test.predictors)
            dat{pa} = test.predictors(pa).data;
        end
        
        ma = cell2mat(dat);
        bads = find(sum(isnan(ma),2)>0);
        ma(bads,:) = [];
        ST = test.SpikeTrain;
        ST(bads) = [];
        
        [lambdaA] = glmval(train.fullModel.beta, ma, 'log',train.fullModel.stats,'Constant','Off');
        LL0 = nansum(log(poisspdf(ST, lambdaA)));
        
        % for each reduced:
        for pa = 1:length(dat)
            dat2 = dat;
            dat2{pa} = zeros(size(dat2{pa}));
            mc = cell2mat(dat2);
            mc(bads,:) = [];
            [lambda] = glmval(train.fullModel.beta, mc, 'log','Constant','Off');
            LL = nansum(log(poisspdf(ST, lambda)));
            
            D =  -2*(LL - LL0);
            N = length(train.fullModel.beta) - length(train.models(pa).beta);
            p(i, pa) = 1-chi2cdf(D, N);
        end
        
    end
    
    isa = all(p<0.05);

end