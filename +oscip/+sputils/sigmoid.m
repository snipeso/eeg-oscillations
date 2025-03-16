function y = sigmoid(x)
% Sigmoid function to constrain parameters between 0 and 1
%
% INPUTS:
%   x : scalar or array
%       Input values
%
% OUTPUTS:
%   y : scalar or array
%       Sigmoid of input values, constrained between 0 and 1

y = 1 ./ (1 + exp(-x));

end