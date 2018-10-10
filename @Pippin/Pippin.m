classdef Pippin < handle
    %PIPPIN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        predictors
        models
        data
        SpikeTrain
        fullModel
    end
    
    methods
        function self = Pippin(root)
            import Pippin.*
            self.data = root;
            
            ts = CMBHOME.Utils.ContinuizeEpochs(root.ts);
            spk = CMBHOME.Utils.ContinuizeEpochs(root.cel_ts);
            [self.SpikeTrain, ~] = histc(spk,ts);
            %self.SpikeTrain(self.SpikeTrain>1) = 1;
            
            %self.predictors(1).name = 'constant';
            %self.predictors(1).data = ones(size(self.SpikeTrain));
            self.predictors = [];
            
            self.models = [];
            self.Constant;
        end
        
        function self = addPredictor(self, mode, dat)
            if exist('dat','var')
                self.Other(mode, dat);
            else
                self.(mode);
            end
                    
        end
        
    end
    
    
    %% Begin List 
    
end

