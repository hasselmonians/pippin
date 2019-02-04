function [fd] = Shuffle(self, pred, N)

% shuffle the desired predictors N times, and calculate the log likelihood
% increase for each shuffled train. Compare the non-shuffled score to this
% distribution. 

nd = size(self.predictors(pred).data, 1);
orig = self.predictors(pred).data;

for n = 1:N
    disp(n)
    self_ = self;
    self_.predictors(pred).data = orig(randperm(nd),:);
    self_.genModels;
    fd(n) = self_.models(pred).difDev;
end


self_.predictors(pred).data = orig;
self_.genModels;


end


