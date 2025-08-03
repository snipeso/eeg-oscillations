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
% Translated to MATLAB by Claude Sonnet 3.7, NOTcorrectedYET by Sophia Snipes,
% 2025.



% Create struct with default values
model = struct(...
    'peak_width_limits', [0.5, 12], ...
    'max_n_peaks', Inf, ...
    'min_peak_height', 0, ... % NB: original fooof uses .1, but these lines don't do much; might be mistake?
    'peak_threshold', 2, ... % multiply STD of remaining signal to determine if any peaks left in signal
    'aperiodic_mode', 'fixed', ...
    'verbose', true, ...
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

if isfield(params, 'freq_range')
    model.freq_range = params.freq_range;
end

% Set internal settings that shouldn't come from the user
model.ap_percentile_thresh = 0.025; % Percentile for selecting points for aperiodic fit (this value is tiiiny, not sure if meant to be 2.5);

model.ap_guess = [nan, 0, nan]; % [offset, knee, exponent]. if Offset guess is nan, the first value of powerspectrum is used as offset guess. If exponent is nan, the abs(log-log slope) of first and last points is used
model.ap_bounds = [-inf, -inf, -inf; inf, inf, inf]; % bounds for aperiodic fitting (offsetlow, knee low, exp low; offset high, knee high, exp high). By default unbounded
model.bw_std_edge = 1; % how far a peak needs t obe to be dropped, defined in untis of gaussian standard deviation % TODO: make it a user option
model.gauss_overlap_thresh = 0.75; % degree of overlap between guassians for one to be dropped, in units of standard deviations  % TODO make user option
model.cf_bound = 1.5; % Bounds for center frequency when fitting gaussians
model.error_metric = 'MAE'; % specparam default is MAE, but can also be MSE or RMSE NB: if you change this, error thresholds will have to change!!
model.maxfev = 5000; % max times call curve fitting function TODO: implement?
model.tol = .00001; % tolerance setting for curve fitting; TODO: implement?
% model.check_freqs = true; % checks if frequencies evenly spaced; TODO: implement?
model.check_data = true; % checks power values and raises error if there's NaNs
model.gauss_std_limits = model.peak_width_limits / 2; % Convert to gaussian std limits




end