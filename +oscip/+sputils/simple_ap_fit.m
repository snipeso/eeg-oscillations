function aperiodic_params = simple_ap_fit(model, power_spectrum)
% Simple fit of the aperiodic component of the power spectrum
%
% INPUTS:
% model : struct
%   Model object containing model settings and results
% power_spectrum : 1d array, optional
%   Power spectrum values to fit. If empty, uses model.power_spectrum
%
% OUTPUTS:
% aperiodic_params : array
%   Parameters for aperiodic fit (offset, exponent) or (offset, knee, exponent)
%
% This MATLAB implementation is based on the original FOOOF project:
% https://github.com/fooof-tools/fooof
% Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0)
% Translated to MATLAB by Claude Sonnet 3.7, corrected by Sophia Snipes,
% 2025.

% Handle optional power_spectrum input
if nargin < 2 || isempty(power_spectrum)
    power_spectrum = model.power_spectrum;
end

freqs = model.freqs;
ap_guess = model.ap_guess;
ap_bounds = model.ap_bounds;

% Calculate guess parameters
if isnan(ap_guess(1)) % offset
    offset_guess = power_spectrum(1);  % just uses first value
else
    offset_guess = ap_guess(1);
end

% NB: choosing the default for the knee is done later, inside the "if"
% related to whether a knee paramter was requested at all

if isnan(ap_guess(3)) % exponent
    exponent_guess = abs((power_spectrum(end) - power_spectrum(1)) / ...
        (log10(freqs(end)) - log10(freqs(1))));
else
    exponent_guess = ap_guess(3);
end


% Set up optimization options
options = optimoptions('lsqcurvefit', ...
    'Algorithm','trust-region-reflective', ... % NB: fooof uses curvefit in python, and provide bounds as an input, even if infinite; this means that it defaults to the trf algorithm
    'MaxFunctionEvaluations', model.maxfev, ...
    'FunctionTolerance', model.tol, ...
    'StepTolerance', model.tol, ...
    'OptimalityTolerance', model.tol, ...
    'CheckGradients', false, ...
    'Display', 'off');

if strcmp(model.aperiodic_mode, 'fixed')
ap_func = oscip.sputils.functions('aperiodic', 'fixed');
    guess = [offset_guess, exponent_guess];
    bounds_lower = ap_bounds(1, [1, 3]);  % offset, exponent
    bounds_upper = ap_bounds(2, [1, 3]);

elseif strcmp(model.aperiodic_mode, 'knee')
    ap_func = oscip.sputils.functions('aperiodic', 'knee');
    knee_guess = ap_guess(2);
    guess = [offset_guess, knee_guess, exponent_guess];
    bounds_lower = ap_bounds(1, :);  % all parameters
    bounds_upper = ap_bounds(2, :);

else
    error('Invalid aperiodic_mode. Must be "fixed" or "knee".');
end

% Perform the fit with error handling
try
    [aperiodic_params, ~, ~, exitflag] = lsqcurvefit(ap_func, guess, ...
        freqs, power_spectrum, ...
        bounds_lower, bounds_upper, options);

    if exitflag <= 0
        error('Optimization failed to converge');
    end

catch ME
    error('Model fitting failed due to not finding parameters in the simple aperiodic component fit.');
end

% NB: aperiodic fit can end up slightly different if periodic fit is
% slightly different from original fooof
