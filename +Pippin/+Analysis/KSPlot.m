function [mCDF, eCDF] = KSPlot(self, modelNum)        
        
        spkIndex = find(self.SpikeTrain);
        if ~exist('modelNum','var')
            modelNum=0;
        end
    
        if modelNum == 0 
            lambda = self.fullModel.lambda;
        else
            lambda = self.models(modelNum).lambda;
        end


        Z(1) = sum(lambda(1:spkIndex(1)));
        N = length(spkIndex);
        for k = 2:length(spkIndex)
            inds = spkIndex(k-1):spkIndex(k);
            Z(k) = sum(lambda(spkIndex(k-1):spkIndex(k)));
        end
        
        % ploting
        
        [eCDF, zvals] = ecdf(Z);
        mCDF = 1-exp(-zvals);
        plot(mCDF, eCDF);
        hold on
        plot([0 1], [0 1]+1.36/sqrt(N),'k')
        plot([0 1], [0 1]-1.36/sqrt(N),'k');
        xlabel('Model CDF'); ylabel('Empirical CDF');
        xlim([0 1])
        ylim([0 1])
        axis square
        

end