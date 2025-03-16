function values = gaussian_function(freqs, params)
% Gaussian function for fitting peaks
%
% INPUTS:
%   freqs : 1d array
%       Frequency values to create Gaussian at
%   params : array or nx3 matrix
%       Parameters that define the Gaussian(s)
%       If array: [center, height, width]
%       If matrix: each row is [center, height, width] for each Gaussian
%
% OUTPUTS:
%   values : 1d array
%       Values for Gaussian function at the input frequencies
%
% This MATLAB implementation is based on the original FOOOF project:
% https://github.com/fooof-tools/fooof
% Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0)
% Translated to MATLAB by Claude Sonnet 3.7, corrected by Sophia Snipes,
% 2025.


% If single peak parameters provided as row vector, reshape
if size(params, 1) == 1 && length(params) == 3
    center = params(1);
    height = params(2);
    std = params(3);
    values = height * exp(-(freqs - center).^2 / (2 * std^2));
    
% If multiple peaks provided as matrix
elseif size(params, 2) == 3
    values = zeros(size(freqs));
    for i = 1:size(params, 1)
        center = params(i, 1);
        height = params(i, 2);
        std = params(i, 3);
        values = values + height * exp(-(freqs - center).^2 / (2 * std^2));
    end
    
% If flat array of parameters for multiple peaks
else
    values = zeros(size(freqs));
    for i = 1:3:length(params)
        center = params(i);
        height = params(i+1);
        std = params(i+2);
        values = values + height * exp(-(freqs - center).^2 / (2 * std^2));
    end
end

end