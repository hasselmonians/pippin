function Spectral(self, order, nFilts, stds)
    % order = how far back (frames) that spiking can affect current \lambda
    % nFilts = how many banks to create. Banks are linearly space up to
    % nFilts


    if ~any(strcmp('Spectral', arrayfun(@(x) x.name, self.predictors, 'UniformOutput',0)))
        self.predictors(end+1).name = 'Spectral';
        
        %%
        %keyboard; %note: There's an issue in creating xHist right now. 
        if ~exist('order','var')
            order = 100;
        end
        
        if ~exist('nFilts','var')
            nFilts = 20;
        end
        
        if ~exist('stds','var')
            stds = order / nFilts;
        end
        
        centers = linspace(1,order, nFilts);
        
        %%
        
        kernel = NaN(nFilts, order);
        for i = 1:nFilts
            kernel(i,:) = normpdf(1:1:order, centers(i), 5);
        end
        
        %%
        %%{
        xHist = [];
        train = self.SpikeTrain;
        for i = 1:order
           x = train(i+1:end);
           pd = zeros(i,1);
           xHist = [xHist [x;pd]]; 
        end
        
        %}
        %%
        %sps = self.SpikeTrain;
        %Xsp = hankel(sps(1:end-order+1), sps(end-order+1:end));
        %Xsp = [Xsp; zeros(size(sps,1)-size(Xsp,1),size(Xsp,2))];
        
        pred = xHist*kernel';
        self.predictors(end).data = pred;
        self.predictors(end).info.order = order;
        self.predictors(end).info.kernel = kernel';
    else
        warning('Is already a field, not appending');
    end
    
end