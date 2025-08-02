function pe_vals = gen_periodic(freqs, gaussian_params)
% Generate periodic values from gaussian parameters
%
% INPUTS:
%   freqs : 1d array
%       Frequency values to create periodic component for
%   gaussian_params : array or nx3 matrix
%       Parameters that define the Gaussian(s)
%       If array: [center1, height1, width1, center2, height2, width2, ...]
%       If matrix: each row is [center, height, width] for each Gaussian
%
% OUTPUTS:
%   pe_vals : 1d array
%       Values for periodic component at the input frequencies
%
% This MATLAB implementation is based on the original FOOOF project:
% https://github.com/fooof-tools/fooof
% Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0)
% Translated to MATLAB by Claude Sonnet 3.7, NOTcorrectedYET by Sophia Snipes,
% 2025.



% Initialize output
pe_vals = zeros(size(freqs));

% If no peaks, return zeros
if isempty(gaussian_params)
    return;
end

% Reshape parameters if needed
if size(gaussian_params, 2) == 3
    params_mat = gaussian_params;
else
    % Reshape flat parameters to [n_peaks x 3]
    n_peaks = length(gaussian_params) / 3;
    params_mat = reshape(gaussian_params, 3, n_peaks)';
end

% Generate periodic component for each peak
for i = 1:size(params_mat, 1)
    center = params_mat(i, 1);
    height = params_mat(i, 2);
    std = params_mat(i, 3);
    
    pe_vals = pe_vals + height * exp(-(freqs - center).^2 / (2 * std^2));
end

end