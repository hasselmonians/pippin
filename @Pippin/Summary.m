%TODO: Give summary of all of the models, provide KS for whether sufficient
%amount of variance in spike times is explained.

function Summary(self)

    predictors = arrayfun(@(x) x.name, self.predictors,'UniformOutput',0);
    p = arrayfun(@(x) x.p, self.models);
    beta = self.fullModel.beta;
    np = [arrayfun(@(x) size(x.data,2), self.predictors)];
   
    ind = 1;
    for i = 1:length(np)
        coeffs{i} = exp(beta(ind:ind+np(i)-1));
        ind = ind+np(i);
    end

    
    for i = 1:length(predictors)
       disp([predictors{i} ': p = ' num2str(p(i)) ' | b = ' mat2str(coeffs{i}')]) 
    end
    
end