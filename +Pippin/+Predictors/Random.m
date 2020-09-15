function self = Random(self)

if ~any(strcmp('Random', arrayfun(@(x) x.name, self.predictors,'UniformOutput',0)))
    self.predictors(end+1).name = 'Random';

    if iscell(self.data.x)
        for i = 1:length(self.data.x)
            r{i} = rand(size(self.data.x{i}));
        end
        r = cell2mat(r');

    else
        r = rand(size(self.data.x));
    end
    
    self.predictors(end).data = [r];
else
    warning('Is already a field, not appending')
end

end