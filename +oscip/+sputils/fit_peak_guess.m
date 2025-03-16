function gaussian_params = fit_peak_guess(model, guess)
% Fits a group of peak guesses with optimization to more closely match the Python implementation
%
% INPUTS:
%   model : struct
%       Model object containing model settings and results
%   guess : nx3 array
%       Initial guesses for peak parameters, each row as [center, height, width]
%
% OUTPUTS:
%   gaussian_params : nx3 array
%       Parameters for gaussian fits, each row as [center, height, width]
%
% This MATLAB implementation is based on the original FOOOF project:
% https://github.com/fooof-tools/fooof
% Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0)
% Translated to MATLAB by Claude Sonnet 3.7, corrected by Sophia Snipes,
% 2025.



freqs = model.freqs;
% Use the stored flattened spectrum if available, otherwise calculate it
if isfield(model, 'spectrum_flat')
    spectrum_flat = model.spectrum_flat;
else
    spectrum_flat = model.power_spectrum - oscip.sputils.gen_aperiodic(freqs, model.aperiodic_params, model.aperiodic_mode);
end

% If there are no peaks to fit, return empty array
if isempty(guess)
    gaussian_params = [];
    return;
end

% Don't optimize peaks individually - instead, fit all peaks at once similar to the Python implementation
n_peaks = size(guess, 1);
guess_params = reshape(guess', 1, []);  % Flatten guess parameters [cf1, amp1, std1, cf2, amp2, std2, ...]
bounds_lo = zeros(1, n_peaks * 3);
bounds_hi = zeros(1, n_peaks * 3);

% Set bounds for each parameter
for idx = 1:n_peaks
    % Parameters start indices (center freq, amplitude, std dev for each peak)
    cf_idx = (idx-1)*3 + 1;
    amp_idx = (idx-1)*3 + 2;
    std_idx = (idx-1)*3 + 3;
    
    % Extract initial guesses
    cf_guess = guess(idx, 1);
    amp_guess = guess(idx, 2);
    std_guess = guess(idx, 3);
    
    % Set bounds for center frequency
    bounds_lo(cf_idx) = max(model.freq_range(1), cf_guess - 2 * model.cf_bound * std_guess);
    bounds_hi(cf_idx) = min(model.freq_range(2), cf_guess + 2 * model.cf_bound * std_guess);
    
    % Set bounds for amplitude
    bounds_lo(amp_idx) = 0;                                          % Lower bound: must be positive
    bounds_hi(amp_idx) = max(amp_guess * 10, max(spectrum_flat) * 2); % Upper bound: reasonable limit
    
    % Set bounds for std deviation
    bounds_lo(std_idx) = model.gauss_std_limits(1);
    bounds_hi(std_idx) = model.gauss_std_limits(2);
end

% Define the objective function for all peaks together
function err = objective_func(params)
    % Compute the model with all peaks
    model_fit = zeros(size(freqs));
    for p = 1:n_peaks
        cf = params((p-1)*3 + 1);
        amp = params((p-1)*3 + 2);
        std = params((p-1)*3 + 3);
        model_fit = model_fit + amp * exp(-(freqs - cf).^2 / (2 * std^2));
    end
    
    % Return the sum of squared errors
    err = sum((spectrum_flat - model_fit).^2);
end

% Objective function with bounded parameters via transformation
function err = constrained_objective(x)
    % Transform bounded parameters to unbounded x values
    params = zeros(size(bounds_lo));
    for i = 1:length(x)
        % Use sigmoid to map unbounded x to [0,1]
        s = 1 / (1 + exp(-x(i)));
        % Map [0,1] to [bound_lo, bound_hi]
        params(i) = bounds_lo(i) + s * (bounds_hi(i) - bounds_lo(i));
    end
    err = objective_func(params);
end

% Convert initial guess to unbounded parameters
x0 = zeros(1, length(guess_params));
for i = 1:length(guess_params)
    % Inverse of the sigmoid transformation
    if guess_params(i) <= bounds_lo(i)
        x0(i) = -5;  % Very negative value for lower bound
    elseif guess_params(i) >= bounds_hi(i)
        x0(i) = 5;   % Very positive value for upper bound
    else
        % Convert from [bound_lo, bound_hi] to [0,1]
        s = (guess_params(i) - bounds_lo(i)) / (bounds_hi(i) - bounds_lo(i));
        % Convert from [0,1] to unbounded x using logit
        x0(i) = log(s / (1 - s));
    end
end

% Options for optimization
options = optimset('Display', 'off', 'MaxFunEvals', 10000, 'MaxIter', 1000, 'TolFun', 1e-8, 'TolX', 1e-8);

% Perform the optimization
x_opt = fminsearch(@constrained_objective, x0, options);

% Convert optimized parameters back to their constrained values
opt_params = zeros(size(bounds_lo));
for i = 1:length(x_opt)
    s = 1 / (1 + exp(-x_opt(i)));
    opt_params(i) = bounds_lo(i) + s * (bounds_hi(i) - bounds_lo(i));
end

% Reshape the optimized parameters back to the gaussian_params format
gaussian_params = reshape(opt_params, 3, n_peaks)';  % Each row is [cf, amp, std] for a peak

end