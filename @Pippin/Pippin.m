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
            
            self.predictors(1).name = 'constant';
            self.predictors(1).data = ones(size(self.SpikeTrain));
            
            self.models = [];
        end
        
        function self = addPredictor(self, mode, dat)
            switch lower(mode)
                case 'custom'
                    keyboard
                otherwise
                    %try
                        self.(mode);
                    %catch
                    %    warning('Unknown predictory type. End');
                    %end
            end
                    
        end
        
    end
    
end

