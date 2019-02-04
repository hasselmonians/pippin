function self = Categorical(self, name, vec)
    % model.Predictors.Categorical('TrialType', randi(2, length(root.b_ts))
    %
    % Takes a categorical value (eg 1 for Left trials, 2 for Rightward
    % trials, 3 for fowards trials) and creates dummy variables coding for
    % each of the unique values.

    if ~any(strcmp(name, arrayfun(@(x) x.name, self.predictors, 'UniformOutput',0)))
        self.predictors(end+1).name = name;
        self.predictors(end).data = vec;
    else
        warning('Is already a field, not appending');
    end
    
end