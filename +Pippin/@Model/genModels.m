function self = genModels(self)
    self.models = [];
    
    for i = 1:length(self.predictors)
        dat{i} = self.predictors(i).data;
    end

    %% ModelA (full model)
    ma = cell2mat(dat);
    [betaA, devA, statsA] = glmfit(ma, self.SpikeTrain, 'poisson','Constant','0ff');
    self.fullModel.beta = betaA;
    self.fullModel.dev = devA;
    self.fullModel.stats = statsA;
    [lambdaA, upb, lowb] = glmval(self.fullModel.beta, ma, 'log',statsA,'Constant','0ff');
    self.fullModel.lambda = lambdaA;
    self.fullModel.lambda_l = lambdaA - lowb;
    self.fullModel.lambda_u = lambdaA + upb;
    
    LL = nansum(log(poisspdf(self.SpikeTrain, lambdaA)));
    self.fullModel.LogLikelihood = LL;
    self.fullModel.AIC = -2*LL + 2*size(ma,2);
    
    
    %% For each reduced   
    if length(dat) > 1
        for i = 1:length(dat)

            %% Fit ModelC
            inds = 1:length(dat);
            inds(i) = [];

            mc = cell2mat(dat(inds));
            [betaC, devC, statsC] = glmfit(mc, self.SpikeTrain, 'poisson','Constant','Off');
            self.models(i).beta = betaC;
            self.models(i).dev = devC;
            self.models(i).difDev = devC-devA;
            self.models(i).stats = statsC;

            [lambda, upb, lowb] = glmval(self.models(i).beta, mc, 'log', statsC,'Constant','Off');
            self.models(i).lambda = lambda;
            self.models(i).lambda_l = lowb;
            self.models(i).lambda_u = upb;


            LL = nansum(log(poisspdf(self.SpikeTrain, lambda)));
            self.models(i).LogLikelihood = LL;
            self.models(i).AIC = -2*LL + 2*size(mc,2);
            self.models(i).dAIC = self.models(i).AIC - self.fullModel.AIC;

            self.models(i).n_params = size(ma,2)-size(mc,2);
            self.models(i).n_params_total = size(mc,2);
            self.models(i).p = 1-chi2cdf(self.models(i).difDev,self.models(i).n_params);


            %% Model CC
            mcc = cell2mat(dat(i));
            if i == 1
                [betaCc, devCc, statsCc] = glmfit(mcc, self.SpikeTrain, 'poisson','Constant','off');
            else
                [betaCc, devCc, statsCc] = glmfit(mcc, self.SpikeTrain, 'poisson','Constant','on');
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
    
    %% create compact
    %keyboard
    %{
    p = arrayfun(@(x) x.p, self.models) ;
    drops = p>0.05;
    drops(1) = 1;
    
    pred = arrayfun(@(x) x.data, self.predictors(~drops),'UniformOutput',0);
    pred = cell2mat(pred);
    mdl = fitglm(pred, self.SpikeTrain, 'Distribution','poisson');
    %}
end














