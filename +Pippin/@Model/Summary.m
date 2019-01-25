% TODO: Give summary of all of the models, provide KS for whether sufficient
%amount of variance in spike times is explained.
%

function T = Summary(self)

    predictors = arrayfun(@(x) x.name, self.predictors,'UniformOutput',0);
    p = arrayfun(@(x) x.p, self.models);
    beta = self.fullModel.beta;
    np = [arrayfun(@(x) size(x.data,2), self.predictors)];
    dev = arrayfun(@(x) x.dev, self.models);
    dd = arrayfun(@(x) x.difDev, self.models);
    dAIC = arrayfun(@(x) x.dAIC, self.models);
    ind = 1;
    
    for i = 1:length(np)
        coeffs{i} = exp(beta(ind:ind+np(i)-1));
        
        ind = ind+np(i);
        
    end

    %%
    T = table;
    T.Var = predictors';
    T.DF = np';
    T.DevReduced = dd';
    T.AIC = dAIC';
    T.p = p';
    
    
    
    
end