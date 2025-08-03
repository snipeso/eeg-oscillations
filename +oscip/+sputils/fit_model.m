function model = fit_model(model)
% Run the main model fitting algorithm
%
% INPUTS:
%   model : struct
%       Model object containing settings and input data
%
% OUTPUTS:
%   model : struct
%       Updated model object with fit results
%
% This MATLAB implementation is based on the original FOOOF project:
% https://github.com/fooof-tools/fooof
% Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0)
% Translated to MATLAB by Claude Sonnet 3.7, NOTcorrectedYET by Sophia Snipes,
% 2025.


try
    % Fit initial aperiodic component
    model.aperiodic_params = oscip.sputils.robust_ap_fit(model);
    ap_fit = oscip.sputils.gen_aperiodic(model.freqs, model.aperiodic_params, model.aperiodic_mode);

    % Flatten the power spectrum using the initial aperiodic fit
    model.spectrum_flat = model.power_spectrum - ap_fit;

    % Find peaks and fit with gaussians
    model.gaussian_params = oscip.sputils.fit_peaks(model);

    % Calculate the peak fit
    peak_fit = oscip.sputils.gen_periodic(model.freqs, model.gaussian_params);

    % Create peak-removed (but not flattened) power spectrum
    spectrum_peak_rm = model.power_spectrum - peak_fit;

    % Run final aperiodic fit on peak-removed power spectrum
    model.aperiodic_params = oscip.sputils.simple_ap_fit(model, spectrum_peak_rm);
    ap_fit = oscip.sputils.gen_aperiodic(model.freqs, model.aperiodic_params, model.aperiodic_mode);

    % Recreate the flattened spectrum based on updated aperiodic fit
    % Store the flattened spectrum for potential use by other functions
    model.spectrum_flat = model.power_spectrum - ap_fit;

    % Create full model fit
    model.modeled_spectrum = peak_fit + ap_fit;

    % Store component fits for plotting
    model.ap_fit = ap_fit;
    model.peak_fit = peak_fit;

    % Calculate peak parameters from gaussian parameters
    model.peak_params = oscip.sputils.create_peak_params(model);

    % Calculate R^2 and error
    model = oscip.sputils.calc_rsquared(model);
    model = oscip.sputils.calc_error(model);

catch ErrorMessage % the rest of this code just handles the error message and default values
    model = handle_model_not_fitting_error_messages(model, ErrorMessage);
end
end



function model = handle_model_not_fitting_error_messages(model, ErrorMessage)
% provide blanks
model.aperiodic_params = NaN(1, 2 + strcmp(model.aperiodic_mode, 'knee'));
model.gaussian_params = [];
model.peak_params = [];
model.r_squared = 0; % NB: deliberate choice to max out r-squared and error, so that my later code has an easy time excluding these epochs
model.error = 1;
model.modeled_spectrum = [];
model.fit_error = true;
model.errormsg = ErrorMessage.message;

% Store diagnostic information
model.errordetails = struct(...
    'message', ErrorMessage.message, ...
    'identifier', ErrorMessage.identifier, ...
    'stack', ErrorMessage.stack ...
    );

% Print status with detailed error information
if model.verbose
    fprintf('\nModel fitting was unsuccessful.\n');
    fprintf('Error: %s\n', ErrorMessage.message);

    % Additional diagnostics based on error type
    if contains(ErrorMessage.message, 'NaN') || contains(ErrorMessage.message, 'Inf')
        fprintf('Diagnostic: Input data contains NaN or Inf values that prevented fitting.\n');
        fprintf('Recommendation: Check input data for invalid values.\n');
    elseif contains(ErrorMessage.message, 'dimensions')
        fprintf('Diagnostic: Dimension mismatch in calculations.\n');
        fprintf('Recommendation: Ensure frequency and power spectrum arrays are same length.\n');
    elseif contains(ErrorMessage.message, 'fminsearch')
        fprintf('Diagnostic: Optimization algorithm failed to converge.\n');
        fprintf('Recommendation: Try different initial parameters or aperiodic mode.\n');
    elseif contains(ErrorMessage.message, 'memory')
        fprintf('Diagnostic: Out of memory error.\n');
        fprintf('Recommendation: Try processing smaller segments of data.\n');
    else
        fprintf('Diagnostic: Unknown error occurred during model fitting.\n');
        fprintf('Recommendation: Check input data and parameters.\n');
    end

    % Print stack trace for debugging
    if isfield(model, 'debug') && model.debug
        fprintf('\nStack trace:\n');
        for i = 1:length(ErrorMessage.stack)
            fprintf('  File: %s, Line: %d, Function: %s\n', ...
                ErrorMessage.stack(i).file, ErrorMessage.stack(i).line, ErrorMessage.stack(i).name);
        end
    end
end

end