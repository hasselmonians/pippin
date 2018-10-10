function SpikeHistory(self, order)

    if ~any(strcmp('SpikeHistory', arrayfun(@(x) x.name, self.predictors, 'UniformOutput',0)))
        self.predictors(end+1).name = 'SpikeHistory';
        
        sps = self.SpikeTrain;
        Xsp = hankel(sps(1:end-order+1), sps(end-order+1:end));
        Xsp = [Xsp; zeros(size(sps,1)-size(Xsp,1),size(Xsp,2))];
        
        self.predictors(end).data = Xsp;
    else
        warning('Is already a field, not appending');
    end
    
end