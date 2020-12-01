function pred = LUT(x, n)
% Creates an N dimensional ratemap from x (N=dimensionality of x). Then
% creates a categorical predictor, where each entry is a specific
% "location" in that LUT. This is similar to the "LNP" approach taken by
% Hardcastle.

%% get locs
if size(x,2) == 1
     mn = min(x);
     mx = max(x);  
     bins = linspace(mn,mx,n);
     [~,loc] = histc(x, bins);
     loc = loc+1;
elseif size(x,2) == 2
    for d = 1:size(x,2)
        mn = min(x(:,d));
        mx = max(x(:,d));
        bins{d} = linspace(mn,mx,n);
    end

    [~, ~, ~, loc] = CMBHOME.Utils.histcn(x,bins{1}, bins{2});
    loc = loc+1;
    loc = sub2ind([n+1, n+1], loc(:,1), loc(:,2));
end

%% make 1-hot
pred = zeros(size(x,1),max(loc));

for i = 1:size(x,1)
    pred(i,loc(i)) = 1;
end


end