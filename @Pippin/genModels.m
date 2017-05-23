function genModels(self)

for i = 1:length(self.predictors)
    dat{i} = self.predictors(i).data;
end

ma = cell2mat(dat);
[betaA, devA, statsA] = glmfit(ma, self.SpikeTrain, 'poisson','Constant','off');
self.fullModel.beta = betaA;
self.fullModel.dev = devA;
self.fullModel.stats = statsA;

[lambda] = glmval(self.fullModel.beta, ma, 'log','Constant','off');
R = poissrnd(lambda);

d = self.data;
d.b_lfp = [];
d.spike = [];
d.spike = CMBHOME.Spike('ts',d.ts(R>0),'vid_ts',d.b_ts);
d.cel = []
d.cel = [1 1];
self.fullModel.data = d;
    
    
for i = 1:length(dat)
    
    inds = 1:length(dat);
    inds(i) = [];
    mc = cell2mat(dat(inds));
    
    [betaC, devC, statsC] = glmfit(mc, self.SpikeTrain, 'poisson','Constant','off');
    
    p = 1-chi2cdf(devC-devA,size(ma,2)-size(mc,2));
    
    self.models(i).beta = betaC;
    self.models(i).dev = devC;
    self.models(i).stats = statsC;
    self.models(i).p = p;
    
    [lambda] = glmval(self.models(i).beta, mc, 'log','Constant','off');
    R = poissrnd(lambda);
    
    d = self.data;
    d.b_lfp = [];
    d.spike = [];
    d.spike = CMBHOME.Spike('ts',d.ts(R>0),'vid_ts',d.b_ts);
    d.cel = []
    d.cel = [1 1];
    self.models(i).data = d;
    
    % super reduced: Just baseline and this parameter
    inds = [1 i];
    mcc = cell2mat(dat(inds));
    
    [betaCc, devCc, statsCc] = glmfit(mcc, self.SpikeTrain, 'poisson','Constant','off');
    [lambda] = glmval(betaCc, mcc, 'log','Constant','off');
    R = poissrnd(lambda);
    
    d = self.data;
    d.b_lfp = [];
    d.spike = [];
    d.spike = CMBHOME.Spike('ts',d.ts(R>0),'vid_ts',d.b_ts);
    d.cel = []
    d.cel = [1 1];
    self.models(i).cc.data = d;
    self.models(i).cc.beta = betaCc;
    self.models(i).cc.devCc = devCc;
    self.models(i).cc.stats = statsCc;
end

%arrayfun(@(x) x.p, self.models) <= 0.05/length(self.models)


end