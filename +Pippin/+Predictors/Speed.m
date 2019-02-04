function self = Speed(self)

if ~any(strcmp('Speed', arrayfun(@(x) x.name, self.predictors,'UniformOutput',0)))
    self.predictors(end+1).name = 'Speed';

        v = CMBHOME.Utils.ContinuizeEpochs(self.data.vel);
        self.predictors(end).data = [v];
    else
        warning('Is already a field, not appending')
    end
end