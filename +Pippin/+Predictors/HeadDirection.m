function HeadDirection(self)

if ~any(strcmp('HeadDirection', arrayfun(@(x) x.name, self.predictors,'UniformOutput',0)))
    self.predictors(end+1).name = 'HeadDirection';

    h = CMBHOME.Utils.ContinuizeEpochs(self.data.headdir);

    if max(h) > 5
       h = deg2rad(h);
       h = wrapToPi(h);
    end
    
    self.predictors(end).data = [h h.^2];
else
    warning('Is already a field, not appending')
end

end