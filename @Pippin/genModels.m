function genModels(self)

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
    
    %% For each reduced    
    for i = 1:length(dat)

        %% Fit ModelC
        inds = 1:length(dat);
        inds(i) = [];

        mc = cell2mat(dat(inds));
        [betaC, devC, statsC] = glmfit(mc, self.SpikeTrain, 'poisson','Constant','0ff');
        self.models(i).beta = betaC;
        self.models(i).dev = devC;
        self.models(i).stats = statsC;
        self.models(i).p = 1-chi2cdf(devC-devA,size(ma,2)-size(mc,2));
       
        [lambda, upb, lowb] = glmval(self.models(i).beta, mc, 'log', statsC,'Constant','0ff');
        self.models(i).lambda = lambda;
        self.models(i).lambda_l = lowb;
        self.models(i).lambda_u = upb;

        %% Model CC
        mcc = cell2mat(dat(i));

        [betaCc, devCc, statsCc] = glmfit(mcc, self.SpikeTrain, 'poisson','Constant','0ff');

        self.models(i).cc.beta = betaCc;
        self.models(i).cc.devCc = devCc;
        self.models(i).cc.stats = statsCc;
        
    end
end