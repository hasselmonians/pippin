function self = AngularAcceleration(self)

if ~any(strcmp('AngularAcceleration', arrayfun(@(x) x.name, self.predictors,'UniformOutput',0)))

    self.predictors(end+1).name = 'AngularAcceleration';
    
    root = self.data;
    xvec = CMBHOME.Utils.nanInterp(CMBHOME.Utils.ContinuizeEpochs(root.x),'spline');
    yvec = CMBHOME.Utils.nanInterp(CMBHOME.Utils.ContinuizeEpochs(root.y),'spline');

    out = CMBHOME.Utils.speed_kalman(xvec, yvec, root.fs_video);
    
    self.predictors(end).data = out.ad;
    
else
    warning('Is already a field, not appending')
end

end