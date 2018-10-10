function Other(self, predName, pred)

if ~any(strcmp(predName, arrayfun(@(x) x.name, self.predictors,'UniformOutput',0)))
    self.predictors(end+1).name = predName;
    self.predictors(end).data = pred;
else
    warning('Is already a field, not appending')
end

end