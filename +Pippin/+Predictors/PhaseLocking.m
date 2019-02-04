function self = PhaseLocking(self, freqRange)
    % Pippin.PhaseLocking(model, [lowerFreq, upperFreq])

    if ~any(strcmp('PhaseLocking', arrayfun(@(x) x.name, self.predictors, 'UniformOutput',0)))
        signal = self.data.b_lfp(self.data.active_lfp).signal;
        fs = self.data.b_lfp(self.data.active_lfp).fs;
        signal_filt = CMBHOME.LFP.BandpassFilter(signal, fs, freqRange);
        phi = CMBHOME.LFP.InstPhase(signal_filt);
        %phi = phi(CMBHOME.Utils.ContinuizeEpochs(self.data.p_lfp_ind(:)));
        
        self.predictors(end+1).name = 'PhaseLocking';
        self.predictors(end).data = [cos(phi), sin(phi)];
    else
        warning('Is already a field, not appending');
    end
    
end