function gaussian_params = fit_peak_guess(model, guess)
% Fits a group of peak guesses with a fit function.
%
% Parameters
% ----------
% guess : matrix, shape=[n_peaks, 3]
%     Guess parameters for gaussian fits to peaks, as gaussian parameters.
%
% Returns
% -------
% gaussian_params : matrix, shape=[n_peaks, 3]
%     Parameters for gaussian fits to peaks, as gaussian parameters.
% This MATLAB implementation is based on the original FOOOF project:
% https://github.com/fooof-tools/fooof
% Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0)
% Translated to MATLAB by Claude Sonnet 3.7, corrected by Sophia Snipes,
% 2025.


n_peaks = size(guess, 1);

% Set the bounds for CF, enforce positive height value, and set bandwidth limits
% Note that 'guess' is in terms of gaussian std, so +/- BW is 2 * the guess_gauss_std

% Initialize bound arrays
lo_bound = zeros(n_peaks, 3);
hi_bound = zeros(n_peaks, 3);

% Set initial bounds for each peak
for i = 1:n_peaks
    % Lower bounds: [cf_low, height_low, bw_low]
    lo_bound(i, :) = [guess(i, 1) - 2 * model.cf_bound * guess(i, 3), ...
        0, ...
        model.gauss_std_limits(1)];

    % Upper bounds: [cf_high, height_high, bw_high]
    hi_bound(i, :) = [guess(i, 1) + 2 * model.cf_bound * guess(i, 3), ...
        inf, ...
        model.gauss_std_limits(2)];
end

% Check that CF bounds are within frequency range
% If they are not, update them to be restricted to frequency range
lo_bound(lo_bound(:, 1) < model.freq_range(1), 1) = model.freq_range(1);
hi_bound(hi_bound(:, 1) > model.freq_range(2), 1) = model.freq_range(2);


% Flatten bounds for use with lsqcurvefit
% MATLAB's lsqcurvefit expects column vectors for bounds
lb = reshape(lo_bound', [], 1);  % Lower bounds as column vector
ub = reshape(hi_bound', [], 1);  % Upper bounds as column vector

% Flatten guess for use with curve fit
guess_flat = reshape(guess', [], 1);

% Set up optimization options
options = optimoptions('lsqcurvefit', ...
    'Algorithm','trust-region-reflective', ...
    'MaxFunctionEvaluations', model.maxfev, ...
    'FunctionTolerance', model.tol, ...
    'StepTolerance', model.tol, ...
    'OptimalityTolerance', model.tol, ...
    'Display', 'off');

% Fit the peaks
try
    % Define the multi-gaussian function handle
    gauss_func = @(params, x) multi_gaussian_function(params, x, n_peaks);

    % Perform the curve fitting
    [fitted_params, ~, ~, exitflag] = lsqcurvefit(gauss_func, guess_flat, ...
        model.freqs, model.spectrum_flat, lb, ub, options);

    % Check if fitting was successful
    if exitflag <= 0
        error('FitError:RuntimeError', ...
            'Model fitting failed due to not finding parameters in the peak component fit.');
    end

catch ME
    if contains(ME.identifier, 'FitError')
        rethrow(ME);
    else
        % Handle other potential errors (equivalent to LinAlgError)
        error('FitError:LinAlgError', ...
            'Model fitting failed due to a LinAlgError during peak fitting. This can happen with settings that are too liberal, leading to a large number of guess peaks that cannot be fit together.');
    end
end

% Re-organize params into 2d matrix [n_peaks x 3]
gaussian_params = reshape(fitted_params, 3, n_peaks)';
end

function y = multi_gaussian_function(params, x, n_peaks)
% Multi-gaussian function for curve fitting
% params: flattened parameters [cf1, height1, std1, cf2, height2, std2, ...]
% x: frequency vector
% n_peaks: number of peaks

y = zeros(size(x));

for i = 1:n_peaks
    idx = (i-1)*3 + 1;

    % Gaussian: height * exp(-0.5 * ((x - cf) / std_dev)^2)
    y = y + oscip.sputils.gaussian_function(x, params(idx:idx+2));
end
end

% Notes:
% - it's still not perfectly identical