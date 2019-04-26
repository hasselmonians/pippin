%%
addpath ~/git/CMBHOME
addpath pippin/
import Pippin.*
load ~/Downloads/BB05_041718_FE.mat


root.b_x = root.b_x - min(root.b_x);
root.b_y = root.b_y - min(root.b_y);
root.cel = [8 2];
[out, detailed]= EgoCentricRateMap_dev(root, 'degSamp', 10); close all
%%
model = Model(root);

model = Predictors.HeadDirection(model);
model = Predictors.Speed(model);
model = Predictors.Place(model);
model = Predictors.Random(model);
model = Predictors.Acceleration(model);
model = Predictors.ISI(model);
model = Predictors.Other(model, 'EBC', [detailed.dis]);%, detailed.dis.^2]);

model = model.genModels();




%%
for i = 1:length(model.models)
    subplot(5,3,i)
    prob = glmval(model.models(i).cc.beta, model.predictors(i).data,'log');
    pred = model.predictors(i).data;
    nm = model.predictors(i).name;
    
    switch nm
        case 'Constant'
            % nothing
        case 'HeadDirection'
            x = linspace(-pi, pi, 100); x = x(:);
            x(:,2) = x.^2;
            
            y = glmval(model.models(i).cc.beta, x, 'log');
            polarplot(x(:,1), y);
        case 'movementDirection'
            x = linspace(-pi, pi, 100); x = x(:);
            x(:,2) = x.^2;
            
            y = glmval(model.models(i).cc.beta, x, 'log');
            polarplot(x(:,1), y);
        case 'Speed'
            x = prctile(root.vel,[5, 95]);
            x = linspace(x(1), x(2), 100);
            y = glmval(model.models(i).cc.beta, x, 'log');
            plot(x,y);
        case 'Place'
            
            x1 = prctile(model.predictors(i).data(:,1), [5 95]); x1 = linspace(x1(1), x1(2), 100);
            x2 = prctile(model.predictors(i).data(:,3), [5 95]); x2 = linspace(x2(1), x2(2), 100);
            for m = 1:length(x1)
                for n = 1:length(x2)
                    pred = [x1(m) x1(m).^2 x2(n) x2(n).^2 x1(m)*x2(n)];
                    y(m,n) = exp(glmval(model.models(i).cc.beta, pred, 'log'));
                end
            end
            xx = size(meshgrid(x1,x2));
            imagesc(x1,x2,y); set(gca,'ydir','normal'); axis square
        case 'ISI'
            basis = model.predictors(i).info.basis;
            beta = model.models(i).cc.beta(2:end);
            plot(basis*beta)
        case 'Random'
            x = prctile(model.predictors(i).data, [5 95]);
            x = x(:);
            y = glmval(model.models(i).cc.beta, x, 'log');
            plot(x,y);
        case 'Acceleration'
            1+1
        case 'AngularAcceleration' 
            1+1
        case 'time'
            x = linspace(root.ts(1), root.ts(end));
            x = [x(:) x(:).^2];
            y = glmval(model.models(i).cc.beta, x, 'log');
            plot(x(:,1),exp(y))
        case 'EBC'
            x1 = 1:74; x1 = x1(:);
            x2 = 1:74; x2 =x2.^2; x2 = x2(:);
            for m = 1:length(x1)
                for n = 1:length(x2)
                    pred = [x1(m);x2(n)];
                    y(m,n) = exp(glmval(model.models(i).cc.beta, pred, 'log'));
                end
            end
            xx = size(meshgrid(x1,x2));
            imagesc(x1,x2,y); set(gca,'ydir','normal'); axis square
        otherwise
           disp(['No plotter for pred ' nm])
    end
            
    %{
    if size(pred,2)==1
        plot(pred,prob,'.')
    elseif size(pred,2)==2 && i==9
        plot(pred(:,1), prob)
    elseif size(pred,2)==2
        % TODO: 2d ratemap here
    end
    %}
    title(model.predictors(i).name)
end


%%
%{
dd = []; dt = {}; b=[]; bads = [];
for i = 1:length(SL)
    try
        dd(i,:) = SL(i).summary.DevReduced ./ SL(i).devTotal;
        %dd(i,:) = SL(i).devCC ./ sum(SL(i).devCC(1));
        %dd(i,:) = SL(i).summary.DevReduced ./ (SL(i).devTotal-SL(i).devCC(1));
        
        %dd(i,:) = SL(i).summary.DevReduced ./ sum(SL(i).summary.DevReduced(2:end));
        dd(i,:) = SL(i).summary.
        
        ct{i} = SL(i).cellType;
        b(i) = NaN; %SL(i).thetaness;
    catch
        b(i) = NaN;
        dd(i,:) = NaN;
        ct{i} = 'bad';
    end
end
b = b(:); ct = ct(:);
% 1: constant
% 2: HD
% 3: SP
% 4: Place
% 5: ISI
% 6: Random

fetNames = {'c','hd','spd','plc','isi','random'};
types = {'Border','Conj', 'Grid','HD'};%,'Interneuron','None'};

bads =  dd(:,2)>100000 | isnan(dd(:,2)) | strcmp(ct,'bad');
b(bads,:) = []; dd(bads,:) = []; ct(bads,:) = []; 

clf
for fet = 1:6
    clear mn sd
    for tp = 1:length(types)
        isA = find(strcmp(ct, types{tp}));
        mn(tp) = nanmean(dd(isA,fet)); 
        sd(tp) = nanstd(dd(isA, fet) / sqrt(length(isA)));

    end




    subplot(3,2,fet)
    bar(1:length(mn), mn)
    hold on
    errorbar(1:length(mn), mn, sd, 'r.')

    set(gca,'XTickLabel', types) 
    title(fetNames{fet})
    %ylim([-1e-6 1e-1])
end

%%


%%
dt = {}; hdRank = [];
for i = 1:length(SL)
    try
        t = SL(i).summary.DevReduced;
        [~,inds] = sort(t,'descend');
        hdRank(end+1) = find(inds==2);
        dt{end+1} = SL(i).cellType;
    catch
        disp(i)
    end
end
hdRank = hdRank(:); dt = dt(:);
isHD = strcmp(dt, 'HD');

clear c
figure
c(:,1) = histc(hdRank(~isHD), 1:6) / sum(~isHD);
c(:,2) = histc(hdRank(isHD),1:6) / sum(isHD);

bar(c)
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
%}
