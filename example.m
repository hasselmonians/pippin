%% Set up the behavioral information
clearvars -except root

root = root.FixDir;
root = root.FixPos;
root.b_vel = [];
root = root.AppendKalmanVel;

%% Add predictors to the model

% First, pass in the session data to create a new "model" object
model = Pippin.Model(root);

% Now add some pre-programmed predictors to the model. 
% Look inside of Pippin/+Pippin/Predictors to see a list of all
% preprogrammed ones
model = Pippin.Predictors.HeadDirection(model);
model = Pippin.Predictors.Place(model);
model = Pippin.Predictors.Speed(model);
%model = Pippin.Predictors.ISI(model);

%% Add custom predictors
% You can also add a predictor manually. The only real limitation is that
% the size of the predictor should be TxN. T is the number of behavioral
% samples in the original root object. N is however many "subcomponents"
% are in each predictor. For example, any angular variable (eg: theta
% phase) has to have both a sin and cos component to transform to a
% *linear* function of phase.

% Extract theta phase. See CMBHOME wiki for more details
root.active_lfp = 1;
phase = root.lfp.theta_phase;
ts = root.lfp.ts;
[~,wb] = histc(root.lfp.ts, root.ts);
phase_behavioral = arrayfun(@(x) CMBHOME.Utils.circ_mean(wb==x), unique(wb));

% Now add the extract phase to the model. Must pass in a name ('ThetaPhase'
% here), and the matrix 
model = Pippin.Predictors.Other(model,'ThetaPhase', [cos(phase_behavioral) sin(phase_behavioral)]);


%% Run the GLM, and look at results
model = model.genModels();  % This line actually runs the models. May take a while
glmSummary = model.Summary; % glmSummary is now a table with information about which predictors are significant.
pow = Pippin.Analysis.LambdaPower(model); 
% this returns a matrix showing the relative contribution of each predictor
% for each timestep in the original dataset


disp(glmSummary)
figure; plot(root.ts, cell2mat(pow'))

%% Finally, create example spike trains from the fit model
fake = model.genTrain(0);
