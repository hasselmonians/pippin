%% Ch-9: Basics + 1-D Place Fields
clear
load ~/Downloads/Ch9-spikes-1.mat
root = CMBHOME.Session('b_ts', t, 'b_x',X, 'b_y', X, 'fs_video', 1000);
root.spike = CMBHOME.Spike('ts',spiketimes, 'vid_ts', t);
root = root.AlignSpike2Session;
root.cel = [1 1];

model = Pippin.Model(root);
dir = [0;diff(X)>0];
Pippin.Predictors.Other(model, 'dir', [dir]);
Pippin.Predictors.Other(model, 'place', [root.x root.x.^2]);
Pippin.Predictors.Other(model, 'time', [root.ts root.ts.^2]); 
% Note that 'time' is not in the original example

model.genModels;
model.Summary

figure; Pippin.Analysis.KSPlot(model);

%% Ch-10 - Model 2

clear
load ~/Downloads/Ch10-spikes-1.mat

K = 50; T0 = length(t);
Imove=ones(K,1)*[zeros(1,T0/2) ones(1, T0/2)];
Imove = reshape((Imove)', K*T0,1);
train = reshape(train', K*T0, 1);

t = cumsum(ones(length(train),1))/1000;
spkTs = find(train)/1000;

xdir = reshape((direction*ones(1,T0))',K*T0,1);

n = length(t);

spk = CMBHOME.Spike('ts',spkTs,'vid_ts',t);
root = CMBHOME.Session('b_x', rand(n,1),...
                       'b_y', rand(n,1),...
                       'fs_video', 1/(t(2)-t(1)),...
                       'b_ts', t,...
                       'epoch', [-inf inf],...
                       'spike', spk);
root.cel = [1 1];

model = Pippin.Model(root);
Pippin.Predictors.Other(model, 'Imove', Imove);
Pippin.Predictors.Other(model, 'dir', xdir);
model.genModels;
model.Summary
exp(model.fullModel.beta)

%% Ch-10 - Model 5
% Note: This corresponds to Model 5, in which we're exclusively looking at
% smooth ("spectral") time-dependence. 
clear
load ~/Downloads/Ch10-spikes-1.mat

K = 50; T0 = length(t);
Imove=ones(K,1)*[zeros(1,T0/2) ones(1, T0/2)];
Imove = reshape((Imove)', K*T0,1);
train = reshape(train', K*T0, 1);

t = cumsum(ones(length(train),1))/1000;
spkTs = find(train)/1000;

xdir = reshape((direction*ones(1,T0))',K*T0,1);

n = length(t);

spk = CMBHOME.Spike('ts',spkTs,'vid_ts',t);
root = CMBHOME.Session('b_x', rand(n,1),...
                       'b_y', rand(n,1),...
                       'fs_video', 1/(t(2)-t(1)),...
                       'b_ts', t,...
                       'epoch', [-inf inf],...
                       'spike', spk);
root.cel = [1 1];

model = Pippin.Model(root);
model = Pippin.Predictors.Other(model, 'Imove', Imove);
model = Pippin.Predictors.Other(model, 'dir', xdir);
model = Pippin.Predictors.Spectral(model, 100, 20);
model = model.genModels;
model.Summary

%% Chapter 11: Spike-Field Coherence
%clear
load ~/Downloads/Ch11-spikes-LFP-1.mat

lfp = y'; lfp = lfp(:);
t = (t(2)-t(1)) * (cumsum(ones(size(lfp)))-1);
n = n(:);
spkTs = t(find(n));

lfp = CMBHOME.LFP(lfp, t, 1/t(2)-t(1), 'lfp');
spk = CMBHOME.Spike('ts',spkTs,'vid_ts',t);

n = length(t);
root = CMBHOME.Session('b_x', rand(n,1),...
                       'b_y', rand(n,1),...
                       'fs_video', 1/(t(2)-t(1)),...
                       'b_ts', t,...
                       'epoch', [-inf inf],...
                       'spike', spk,...
                       'b_lfp', lfp);
root.cel = [1 1];
root.active_lfp = 1;

model = Pippin.Model(root);
model = Pippin.Predictors.PhaseLocking(model, [44 46]);
model = model.genModels;
model.Summary
model.fullModel.beta


%%
Pippin.Analysis.ThinningFactor(model)