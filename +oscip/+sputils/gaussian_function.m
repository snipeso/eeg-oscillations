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


center = params(1);
height = params(2);
width = params(3);

values = zeros(size(freqs));
values = values + height * exp(-(freqs - center).^2 ./ (2 * width^2));

% Note: Claude had created a lot of extra options based on the dimentions
% of params; it's been deleted, but if something goes wrong, maaaybe thats
% it?
