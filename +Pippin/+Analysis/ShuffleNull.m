function [iff, dd, AIC] = ShuffleNull(model, N)
% Get the null distribution of a model for all parameters, under a shuffled
% distribution. Warning, it's slowwwwww.

    if ~exist('N','var')
        N = 1000;
    end

    spkOrig = model.SpikeTrain;
    dd = NaN(N, length(model.predictors));
    betas = NaN(N, sum(arrayfun(@(x) size(x.data,2), model.predictors)));
    ddc = NaN(N, length(model.predictors));
    AIC = NaN(N, length(model.predictors));
    
    %% for shuffling the spike train
    for n = 1:N
        %disp(n)
        spk = zeros(length(spkOrig),1);
        inds = randperm(length(spkOrig), sum(spkOrig));
        spk(inds) = 1;
        model_ = model;
        model_.SpikeTrain = spk;
        
        model_ = model_.genModels;
        s = model_.Summary;
        dd(n,:) = s.DevReduced;
        betas(n,:) = model_.fullModel.beta;
        ddc(n,:) = arrayfun(@(x) x.cc.devCc, model_.models);
        AIC(n,:) = arrayfun(@(x) x.dAIC, model_.models);
    end


    
    %%
    sTrue = model.Summary;
    sTrue = sTrue.dAIC;

    for i = 1:length(sTrue)
        lb(i) = sTrue(i) < prctile(AIC(:,i), 2.5);
        ub(i) = sTrue(i) > prctile(AIC(:,i), 97.5);
        mn(i) = sTrue(i) > nanmean(AIC(:,i));
    end
    iff = ub;



end




