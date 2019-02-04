function self = Constant(self)

if ~any(strcmp('Place', arrayfun(@(x) x.name, self.predictors,'UniformOutput',0)))
    self.predictors(end+1).name = 'Constant';

    x = CMBHOME.Utils.ContinuizeEpochs(self.data.x);
    x(:) = 1;

    self.predictors(end).data = [x];
else
    warning('Is already a field, not appending')
end

end