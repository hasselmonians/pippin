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
    end
    
    methods
        function self = Model(root)
            import Pippin.*
            self.data = root;
            
            ts = CMBHOME.Utils.ContinuizeEpochs(root.ts);
            spk = CMBHOME.Utils.ContinuizeEpochs(root.cel_ts);
            [self.SpikeTrain, ~] = histc(spk,ts);
            self.SpikeTrain = self.SpikeTrain(:);
            self.predictors = [];
            
            self.models = [];
            self = Pippin.Predictors.Constant(self);
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

