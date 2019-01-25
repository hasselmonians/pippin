%% Ch-9 works
load ~/Downloads/Ch9-spikes-1.mat

root = CMBHOME.Session('b_ts', t, 'b_x',X, 'b_y', X, 'fs_video', 1000);

root.spike = CMBHOME.Spike('ts',spiketimes, 'vid_ts', t);
root = root.AlignSpike2Session;
root.cel = [1 1];


model = Pippin.Model(root);
dir = [0;diff(X)>0];
Pippin.Predictors.Other(model, 'dir', [dir]);
Pippin.Predictors.Spectral(model, 100,10);
Pippin.Predictors.Other(model, 'time', [root.ts root.ts.^2]);
Pippin.Predictors.Other(model, 'place', [root.x root.x.^2]);

model.genModels;
model.Summary

figure; model.KSPlot;
%% 
load SL_Base.mat

for i = 1:length(SL)
    if isempty(SL(i).summary)
        clc;
        i
        r = load(SL(i).name);
        root = r.root; QP = r.QP;
        root.cel = SL(i).cel;
        SL(i).summary = EgoCentricRateMap_dev(root, 'boundaryMode', QP);
        close all;
    end
end


%% Ch-10 figuring out
