function self = Time(self)

if ~any(strcmp('Time', arrayfun(@(x) x.name, self.predictors,'UniformOutput',0)))
    self.predictors(end+1).name = 'Time';

    t = CMBHOME.Utils.ContinuizeEpochs(self.data.ts);

    self.predictors(end).data = [t t.^2];
else
    warning('Is already a field, not appending')
end

end