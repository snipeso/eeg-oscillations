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
%
% This MATLAB implementation is based on the original FOOOF project:
% https://github.com/fooof-tools/fooof
% Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0)
% Translated to MATLAB by Claude Sonnet 3.7, corrected by Sophia Snipes,
% 2025.


y = 1 ./ (1 + exp(-x));

end