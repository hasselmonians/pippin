clear; clc;cla;close all
addpath ~/github/CMBHOME/
addpath ~/github/pippin/
import CMBHOME.*
import Pippin.*
load ~/Downloads/CMBobject_cm-37-58.mat
root.cel = root.cells(2,:);

close all
self = Pippin(root);
clear root

self.addPredictor('Place');
self.addPredictor('Speed');
self.addPredictor('HeadDirection');
self.addPredictor('Random');
self.genModels;

h = arrayfun(@(x) x.p, self.models) < 0.01/length(self.fullModel.stats.p);
ps = arrayfun(@(x) x.p, self.models);
names = arrayfun(@(x) x.name, self.predictors, 'UniformOutput',0);

[h(:) ps(:)]