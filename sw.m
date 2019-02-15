rng('default') % for reproducibility
X = randn(100,20);
mu = exp(X(:,[5 10 15])*[.4;.2;.3] + 1);
y = poissrnd(mu);

mdl =  stepwiseglm(X,y,...
    'constant','upper','linear','Distribution','poisson')

%%
pred = cell2mat(arrayfun(@(x) x.data, model.predictors,'UniformOutput',0));

mdl =  stepwiseglm(pred,model.SpikeTrain,...
    'constant','upper','linear','Distribution','poisson')

%%
tbl = table(model.SpikeTrain,'VariableNames',{'spikeTrain'});
for i = 2:length(model.predictors)
    x = model.predictors(i).data;
    nm = model.predictors(i).name;
    for k = 1:size(x,2)
        eval(['tbl.' [nm num2str(k)] '= x(:,k);']);
    end
end

%%
mdl =  stepwiseglm(tbl, 'linear',...
                   'ResponseVar','spikeTrain',...    
                   'upper','linear','Distribution','poisson',...
                   'PEnter', 0.05,...
                   'PRemove', 0.5);
