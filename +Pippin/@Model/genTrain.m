function [d] = genTrain(self, modelNum, ifAll, N)
    
    if ~exist('N','var'); N = 1000;end
    if ~exist('ifAll','var')
        ifAll = 0;
    end
    
    indC = [];
    a=arrayfun(@(x) size(x.data,2), self.predictors);
    for i = 1:length(a)
        indC = [indC; i*ones(a(i),1)];
    end
    
    inds = ones(size(self.predictors));
    
    if modelNum ~= 0
        inds(modelNum) = 0;
    end
    
    if ~ifAll % get rid of insigniticant predicters 
        inds(find(self.fullModel.stats.p > 0.05)) = 0;
    end
    
    pred = arrayfun(@(x) x.data, self.predictors,'UniformOutput',0);
    pred = cell2mat(pred);
    %pred = pred(:,inds==1);
    %beta = self.fullModel.beta(inds==1);    
    beta = self.fullModel.beta;
    
    d = self.data;
    d.active_lfp = [];
    d.path_lfp = [];
    d.b_lfp = [];
    d.spike = [];
    
    
    for trainNum = 1:N % Generate MANY trains under the null, and fit with full and reduced model
        
        if ~any(arrayfun(@(x) strcmp(x.name, 'FixThis'), self.predictors))     
            % Generate with reduced model
            if modelNum > 0
                lambda = glmval(beta,pred,'log','Constant','0ff');
            else
                lambda = glmval(beta,pred,'log','Constant','0ff');
            end
            spikeTrain = poissrnd(lambda);
        else
            keyboard
            spikeTrain = self.SpikeTrain;
            beta = self.fullModel.beta;
            histInd = find((arrayfun(@(x) strcmp(x.name, 'ISI'), self.predictors)));
            
            %% 
            order = self.predictors(histInd).info.order;
            kernel = self.predictors(histInd).info.kernel;
            coeffs = self.fullModel.beta;
            coeffs = coeffs((size(beta,1) - size(kernel,2))+1:size(beta,1));
            ac = kernel*coeffs;
            
            %%
            for i = (order+1):size(self.predictors(1).data,1)
               %%
               st = spikeTrain(i-order+1:i);
               %keyboard %ugh
            end
            
            %%
            tic;
            for i = (order+1):length(self.fullModel.lambda)
                st = spikeTrain(i-order:i);
                
                xHist = [];
                for ind = 1:order
                    x = st(ind:end);
                    pd = zeros(ind,1);
                    xHist = [xHist [pd;x]]; 
                end
                st = xHist*kernel;
                st = st(end,:);
                pred(i,:) = [pred(i,1:size(pred,2)-20) st];
                lambda(i) = glmval(beta, pred(i,:),'log','Constant','off');
                spikeTrain(i) = poissrnd(lambda(i));
                dt = toc;
                
                if mod(i,10000) == 1
                    pct = i/length(self.fullModel.lambda);
                    disp((dt/pct) * (1-pct));
                end
            end       
        end
        ts = CMBHOME.Utils.ContinuizeEpochs(d.ts);
        if isempty(d.spike)
            d.spike = CMBHOME.Spike('ts',ts(spikeTrain>0),'vid_ts',d.b_ts);
        else
            d.spike(trainNum,1) = CMBHOME.Spike('ts',ts(spikeTrain>0),'vid_ts',d.b_ts);
        end

    end    
    d = d.AlignSpike2Session;
end