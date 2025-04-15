function peak_params = create_peak_params(model)
% Convert gaussian parameters to peak parameters
%
% INPUTS:
%   model : struct
%       Model object containing model settings and results
%
% OUTPUTS:
%   peak_params : nx3 array
%       Parameters for peaks, each row as [center_frequency, power, bandwidth]
%
% This MATLAB implementation is based on the original FOOOF project:
% https://github.com/fooof-tools/fooof
% Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0)
% Translated to MATLAB by Claude Sonnet 3.7, corrected by Sophia Snipes,
% 2025.



if isempty(model.gaussian_params)
    peak_params = [];
    return;
end

% Initialize output
peak_params = zeros(size(model.gaussian_params));

for i = 1:size(model.gaussian_params, 1)
    % Find the index closest to the center frequency
    [~, ind] = min(abs(model.freqs - model.gaussian_params(i, 1)));
    
    % Get center frequency, power, and bandwidth
    peak_params(i, 1) = model.gaussian_params(i, 1); % CF
    peak_params(i, 2) = model.modeled_spectrum(ind) - model.ap_fit(ind); % Power
    peak_params(i, 3) = model.gaussian_params(i, 3) * 2; % BW (2 * std)
end

end