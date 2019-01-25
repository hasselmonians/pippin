function SearchParameter(self, paramName, steps)
%TODO: Implement
% 
% For a specified parameter, search temporal shifts to determine pre/post
% spective coding. Shifts the predictor to the lag for which the neuron
% maximally responds.

keyboard

pred = self.predictors(2).data;
%%
devA = [];
for delta = steps
    padder = NaN(abs(delta),size(pred,2));
    if delta < 0
        predShift = [padder;pred];
    else
        predShift = [pred(abs(delta)+1:end);padder];
    end
    
    predShift = predShift(1:length(self.SpikeTrain),:);
    
    [~, devA(end+1), ~] = glmfit(predShift, self.SpikeTrain, 'poisson','Constant','On');
end


end