function model = init_model_params(params)
% Initialize model parameters with defaults
%
% INPUTS:
%   params : struct
%       User provided parameters (optional)
%
% OUTPUTS:
%   model : struct
%       Initialized model structure with default settings
%
% This MATLAB implementation is based on the original FOOOF project:
% https://github.com/fooof-tools/fooof
% Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0)
% Translated to MATLAB by Claude Sonnet 3.7, corrected by Sophia Snipes,
% 2025.



% Create struct with default values
model = struct(...
    'peak_width_limits', [0.5, 12], ...
    'max_n_peaks', Inf, ...
    'min_peak_height', 0, ...
    'peak_threshold', 2, ...
    'aperiodic_mode', 'fixed', ...
    'verbose', 1, ...
    'debug', false, ...
    'freqs', [], ...
    'power_spectrum', [], ...
    'freq_range', [], ...
    'freq_res', [], ...
    'modeled_spectrum', [], ...
    'aperiodic_params', [NaN, NaN], ...
    'peak_params', [], ...
    'gaussian_params', [], ...
    'r_squared', NaN, ...
    'error', NaN, ...
    'fit_error', false, ...
    'error_msg', '');

% Update with user provided parameters
if isfield(params, 'peak_width_limits')
    model.peak_width_limits = params.peak_width_limits;
end
if isfield(params, 'max_n_peaks')
    model.max_n_peaks = params.max_n_peaks;
end
if isfield(params, 'min_peak_height')
    model.min_peak_height = params.min_peak_height;
end
if isfield(params, 'peak_threshold')
    model.peak_threshold = params.peak_threshold;
end
if isfield(params, 'aperiodic_mode')
    model.aperiodic_mode = params.aperiodic_mode;
end
if isfield(params, 'verbose')
    model.verbose = params.verbose;
end
if isfield(params, 'debug')
    model.debug = params.debug;
end

% Set internal settings
model.gauss_std_limits = model.peak_width_limits / 2; % Convert to gaussian std limits
model.ap_percentile_thresh = 0.025; % Percentile for selecting points for aperiodic fit
model.cf_bound = 1.5; % Bounds for center frequency when fitting gaussians
model.bw_std_edge = 1.0; % Threshold for edge detection
model.gauss_overlap_thresh = 0.75; % Threshold for gaussian overlap

end