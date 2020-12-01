function self = ISI(self)
    
    % Fits interspike intervals, based on raised cosine basis functions
    % See Pillow et al 2008 (Nature)    
    
    %%
     if any(strcmp('ISI', arrayfun(@(x) x.name, self.predictors, 'UniformOutput',0)))
         warning('already a predictor, not appending');
         return
     else
        self.predictors(end+1).name = 'ISI';
     end
    
    %%
    Bprs.nh = 10;  % number of basis vectors
    Bprs.endpoints = [0, 0.5]; % location of 1st and last cosines
    Bprs.b = .01;  % nonlinear stretch factor (larger => more linear)
    Bprs.dt = 1/self.data.fs_video; % time bin size
    [~, ~, basis, ~] = Pippin.Transforms.RaisedCosine(Bprs); 
    order = size(basis,1);
    
    %%
    xHist = [];
    train = self.SpikeTrain;
    for i = 1:order
       x = train(i+1:end);
       pd = zeros(i,1);
       xHist = [xHist [x;pd]]; 
    end
    
    %%
    pred = xHist*basis;
    self.predictors(end).data = pred;
    self.predictors(end).info.basis = basis;
    self.predictors(end).info.order = order;
    
    %%
    %{
    plot(tt, B)
    xlim([0. 0.75])
    hold on;plot(tt,sum(B,2)/2)
    xlim([0. 0.75])
    %}
end