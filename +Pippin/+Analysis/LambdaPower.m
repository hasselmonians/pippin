function pow = LambdaPower(model)
    % Calculates the relative contribution from each (grouped) predictor
    % towards the isntantaneous firing rate over time. 
    % 
    % Only uses predictor groups that have a p value less than sigThresh
    %%
    
    m = model.bestModel;
    
    T = model.Summary();
    inds = T.p < model.sigThresh; 
    
    pred = arrayfun(@(x) x.data, model.predictors(inds),'UniformOutput',0);
    pow = cell(length(pred),1);
    
    for i = 1:length(pred)
        pow{i} = zeros(size(pred{i},1),1);
        for k = 1:size(pred{i},2)
            pow{i} = pow{i} + model.bestModel.beta(i) * pred{i}(:,k);
        end       
        
        pow{i} = exp(pow{i});
    end
    
    %%
    
end