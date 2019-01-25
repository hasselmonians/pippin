function Place(self)

if ~any(strcmp('Place', arrayfun(@(x) x.name, self.predictors,'UniformOutput',0)))
    self.predictors(end+1).name = 'Place';

    x = CMBHOME.Utils.ContinuizeEpochs(self.data.x);
    y = CMBHOME.Utils.ContinuizeEpochs(self.data.y);

    self.predictors(end).data = [x x.^2 y y.^2 x.*y];
else
    warning('Is already a field, not appending')
end

end