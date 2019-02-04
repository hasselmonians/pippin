function ShuffleNull(model, N)
% Get the null distribution of a model for all parameters, under a shuffled
% distribution. Warning, it's slowwwwww.

    if ~exist('N','var')
        N = 1000;
    end

    spkOrig = model.SpikeTrain;
    dd = NaN(N, length(model.predictors));
    betas = NaN(N, length(model.predictors));
    
    for n = 1:N
        disp(n)
        spk = zeros(length(spkOrig),1);
        inds = randperm(length(spkOrig), sum(spkOrig));
        spk(inds) = 1;
        model_ = model;
        model_.SpikeTrain = spk;
        
        model_ = model_.genModels;
        s = model_.Summary;
        dd(n,:) = s.DevReduced;
        betas(n,:) = model_.fullModel.beta;
    end

    %%
    sTrue = model.Summary;
    sTrue = sTrue.DevReduced;

    for i = 1:length(sTrue)
        iff(i) = sTrue(i) > prctile(dd(:,i), 95);
    end
    
    iff
    

end




