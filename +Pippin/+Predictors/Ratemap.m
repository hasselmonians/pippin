function self = Ratemap(self)

if ~any(strcmp('Ratemap', arrayfun(@(x) x.name, self.predictors,'UniformOutput',0)))
    self.predictors(end+1).name = 'Ratemap';
    
    [rate_map, xdim, ydim, occupancy, no_occupancy] = self.data.RateMap;
    
    xvec = CMBHOME.Utils.nanInterp(CMBHOME.Utils.ContinuizeEpochs(self.data.x),'spline');
    yvec = CMBHOME.Utils.nanInterp(CMBHOME.Utils.ContinuizeEpochs(self.data.y),'spline');
    
    [N,XEDGES,YEDGES,BINX,BINY] = histcounts2(xvec, yvec, xdim, ydim);
    
    pred = NaN(size(xvec));
    
    for i = 1:length(pred)
        try
            pred(i) = rate_map(BINY(i), BINX(i));
        end
    end
    
    pred = CMBHOME.Utils.nanInterp(pred,'spline');
    
    self.predictors(end).data = pred;

    
else
    warning('Is already a field, not appending')
end

end
