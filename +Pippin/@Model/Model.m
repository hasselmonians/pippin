classdef Model
    % Point process neuron (Pippin) class.
    %   Holds data required for leave-one-out approach to GLM decoding of
    %   functional neuron types.
    
    properties
        predictors
        models
        data
        SpikeTrain
        fullModel
        bestModel
        sigThresh
    end
    
    methods
        function self = Model(root, sigThresh)
            import Pippin.*
            self.data = root;
            
            ts = CMBHOME.Utils.ContinuizeEpochs(root.ts);
            spk = CMBHOME.Utils.ContinuizeEpochs(root.cel_ts);
            [self.SpikeTrain, ~] = histc(spk,ts);
            self.SpikeTrain = self.SpikeTrain(:);
            self.predictors = [];
            
            self.models = [];
            self = Pippin.Predictors.Constant(self);
            
            if ~exist('sigThresh','var')
                sigThresh = 0.01;
            end
            
            self.sigThresh = sigThresh;
        end
        
        function self = addPredictor(self, mode, dat)
            if exist('dat','var')
                self.Other(mode, dat);
            else
                self.(mode);
            end
                    
        end
        
    end
        
end

