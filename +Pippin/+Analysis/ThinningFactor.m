function ThinningFactor(model, ThinningRange)

% Estimates whether there is an effect of overall firing rate on each of
% the predictors in model.
%
% Based on section 11.2
%%
if ~exist('ThinningRange','var')
    ThinningRange = 0:0.05:0.7;
end

for i = 1:length(ThinningRange)
    tr = ThinningRange(i);
    model_down = Pippin.Model(model.data);
    model_down.predictors = model.predictors;
    
    spk_train = model_down.SpikeTrain;
    inds = find(spk_train==1);
    rm_inds = randperm(length(inds));
    rm_inds = rm_inds(floor(1:length(inds)*tr));
    spk_train(inds(rm_inds)) = 0;
    model_down.SpikeTrain = spk_train;
    
    model_down.genModels;
    coeffs(i,:) = model_down.fullModel.stats.beta;
    se(i,:) = model_down.fullModel.stats.se;
    model_down.delete;
    
end

%%
clf; hold on

plot(1-ThinningRange, coeffs(:,2))
plot(1-ThinningRange, coeffs(:,3))


end