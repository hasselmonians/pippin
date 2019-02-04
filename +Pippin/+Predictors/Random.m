function self = Random(self)

if ~any(strcmp('Random', arrayfun(@(x) x.name, self.predictors,'UniformOutput',0)))
    self.predictors(end+1).name = 'Random';

    r = rand(size(self.data.x));

    self.predictors(end).data = [r];
else
    warning('Is already a field, not appending')
end

end