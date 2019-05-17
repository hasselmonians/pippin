function [paramMatch, modelMatch] = CompareModels(model1, model2)
% [paramMatch, modelMatch] = Pippin.Analysis.CompareModels(model1, model2)
%  
% Determines which parameters and parameter sets from model2 fall within
% the 95% C.I. from model1. 
% 
% ie: testing effects of manipulations.
% 
% paramMatch is sub-predictor-by-sub-predictor, while modelMatch checks iff
% ALL subparameters for a given predictor are within the bounds.

%% param by param level matching
lb = model1.fullModel.stats.beta - 2*model1.fullModel.stats.se;
ub = model1.fullModel.stats.beta + 2*model1.fullModel.stats.se;

beta2 = model2.fullModel.stats.beta;

paramMatch = (beta2 > lb) & (beta2 < ub); 
p = model1.fullModel.stats.p;

%% model-level matching
ind = [];

for i = 1:length(model1.Summary.DF)
    ind = [ind;i*ones(model1.Summary.DF(i),1)];
    ii = find(ind==i);
    %modelMatch(i) = all(paramMatch(ii));
    iii = find(p(ii) < 0.05);
    if isempty(iii)
        modelMatch(i) = 1;
    else
        modelMatch(i) = sum(paramMatch(ii(iii))) / length(ii(iii));
    end
end
    
    
    
end



