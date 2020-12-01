function [pred] = Polynomial(x,order)
% Creates a polynomial basis from a single variable

pred = NaN(order,length(x));
for i = 1:length(order)
    pred(i,:) = x .^ order;
end


end

