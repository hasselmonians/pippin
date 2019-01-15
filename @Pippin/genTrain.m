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
    d.b_lfp = [];
    d.spike = [];
    
    for trainNum = 1:N % Generate MANY trains under the null, and fit with full and reduced model
        
        if ~any(arrayfun(@(x) strcmp(x.name, 'Spectral'), self.predictors))     
            % Generate with reduced model
            if modelNum > 0
                lambda = glmval(beta,pred,'log','Constant','0ff');
            else
                lambda = glmval(beta,pred,'log','Constant','0ff');
            end
            spikeTrain = poissrnd(lambda);
        else
            spikeTrain = self.SpikeTrain;
            %ones(length(self.fullModel.lambda),1);
            beta = self.fullModel.beta;
            histInd = find((arrayfun(@(x) strcmp(x.name, 'Spectral'), self.predictors)));
            
            %% ghgh
            
            % IMPORTANT: When this changes, it also needs to change in
            % Spectral. 
            % TODO: Seperate and integrate so they work together.
            
            %% 
            order = self.predictors(end).info.order;
            kernel = self.predictors(end).info.kernel;
            
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
                pred(i,:) = [pred(i,1:size(pred,2)-10) st];
                lambda(i) = glmval(beta, pred(i,:),'log','Constant','off');
                spikeTrain(i) = poissrnd(lambda(i));
                dt = toc;
                
                if mod(i,10000) == 1
                    pct = i/length(self.fullModel.lambda);
                    disp((dt/pct) * (1-pct));
                end
            end       
        end
        if isempty(d.spike)
            d.spike = CMBHOME.Spike('ts',d.ts(spikeTrain>0),'vid_ts',d.b_ts);
        else
            d.spike(trainNum,1) = CMBHOME.Spike('ts',d.ts(spikeTrain>0),'vid_ts',d.b_ts);
        end
        % fitting
        %{
        p = Pippin(d);
        p.predictors = self.predictors;
        p.genModels;
        devC(i) = p.models(modelNum).dev;
        devA(i) = p.fullModel.dev;
        %}
    end    
    
end