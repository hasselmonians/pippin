%%
addpath ~/git/CMBHOME
addpath pippin/
import Pippin.*
load ~/Downloads/BB05_041718_FE.mat

root.cel = [8 2];
model = Model(root);

model = Predictors.HeadDirection(model);
model = Predictors.Speed(model);
model = Predictors.Place(model);
model = Predictors.Random(model);

model = model.genModels();

%% 
load SL_Base.mat
SL(end).summary = [];

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
save('SL_EBC_Summary.mat','SL');

%%
clear 
load SL_EBC_Summary.mat

%%
clf; 
for i = 1:8
    subplot(4,2,i)
    isEBC = arrayfun(@(x) strcmp(x.cellType, 'EBC'), SL);
    
    DR_tot = arrayfun(@(x) sum(x.summary.summary.DevReduced), SL);
    
    DR_ebc = arrayfun(@(x) x.summary.summary.DevReduced(i), SL(isEBC)) ./ DR_tot(isEBC);
    DR_oth = arrayfun(@(x) x.summary.summary.DevReduced(i), SL(~isEBC)) ./ DR_tot(~isEBC);
    DR_all = arrayfun(@(x) x.summary.summary.DevReduced(i), SL) ./ DR_tot;
    lb = prctile(DR_all, 5); ub=prctile(DR_all, 95);
    bins = linspace(lb, ub, 50);
    plot(bins, histc(DR_oth, bins)/sum(~isEBC), 'LineWidth',2)
    hold on
    plot(bins, histc(DR_ebc, bins)/sum(isEBC), 'LineWidth',2)
    title(SL(1).summary.summary.Var(i))
end

%%
for i = 1:length(SL)
    [~,inds] = sort(SL(i).summary.summary.DevReduced,'descend');
    ii(i) = find(inds==6);  
end
clear c
c(:,1) = histc(ii(~isEBC), 1:8);
c(:,2) = histc(ii(isEBC),1:8);

bar(c)

%%
clf; clear c
lb = prctile(DR_all, 5); ub=prctile(DR_all, 95);
bins = linspace(lb, ub, 10);
    
c(:,1) = histc(DR_oth, bins);
c(:,2) = histc(DR_ebc, bins);

bar(bins, c)
vline(prctile(DR_all, 95))

%%
for cel = 1:length(root.cells)
    for lfp = 1:16
        root.active_lfp = lfp;
        %root.cel = root.cells(cel,:);
        mrl(lfp) = CMBHOME.Utils.circ.circ_r(root.cel_thetaphase{1});
        figure
        rose2(wrapTo2Pi(root.cel_thetaphase{1}),17)
    end
end

