%% Ch-9 works
load ~/Downloads/Ch9-spikes-1.mat

root = CMBHOME.Session('b_ts', t, 'b_x',X, 'b_y', X, 'fs_video', 1000);

root.spike = CMBHOME.Spike('ts',spiketimes, 'vid_ts', t);
root = root.AlignSpike2Session;
root.cel = [1 1];


model = Pippin(root);
model.Other('place1', [root.x]);
model.Other('place2', [root.x.^2]);
dir = [0;diff(X)>0];
model.Other('dir', [dir]);
model.genModels;
model.fullModel.beta

%% 
row=64;
load(SL(row).name);
root.cel = SL(row).cel;
EgoCentricRateMap_dev(root, 'boundaryMode',QP)

%%

row=1;load(SL(row).fname); 
root = Resample(root,100);
root = root.FixTime;
root.cel = SL(row).cel;
root.b_x = root.b_x - min(root.b_x); 
root.b_y = root.b_y - min(root.b_y);

model = Pippin(root);
%
model.Place;
model.HeadDirection;
model.AngularAcceleration;
model.Other('time', [root.b_ts root.b_ts.^2]);
model.Other('random', rand(size(root.b_ts)));

model.genModels;

model.Summary

for pred = 2:6
    rp{pred} = model.Shuffle(pred, 100);
end

%% Ch-10 figuring out
