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
% Translated to MATLAB by Claude Sonnet 3.7, corrected by Sophia Snipes,
% 2025.


try
    % Fit initial aperiodic component
    model.aperiodic_params_ = sputils.robust_ap_fit(model);
    ap_fit = sputils.gen_aperiodic(model.freqs, model.aperiodic_params_, model.aperiodic_mode);
    
    % Flatten the power spectrum using the initial aperiodic fit
    model.spectrum_flat = model.power_spectrum - ap_fit;
    
    % Find peaks and fit with gaussians
    model.gaussian_params_ = sputils.fit_peaks(model);
    
    % Calculate the peak fit
    peak_fit = sputils.gen_periodic(model.freqs, model.gaussian_params_);
    
    % Create peak-removed (but not flattened) power spectrum
    spectrum_peak_rm = model.power_spectrum - peak_fit;
    
    % Run final aperiodic fit on peak-removed power spectrum
    model.aperiodic_params_ = sputils.simple_ap_fit(model, spectrum_peak_rm);
    ap_fit = sputils.gen_aperiodic(model.freqs, model.aperiodic_params_, model.aperiodic_mode);
    
    % Recreate the flattened spectrum based on updated aperiodic fit
    % Store the flattened spectrum for potential use by other functions
    model.spectrum_flat = model.power_spectrum - ap_fit;
    
    % Create full model fit
    model.modeled_spectrum_ = peak_fit + ap_fit;
    
    % Store component fits for plotting
    model.ap_fit = ap_fit;
    model.peak_fit = peak_fit;
    
    % Calculate peak parameters from gaussian parameters
    model.peak_params_ = sputils.create_peak_params(model);
    
    % Calculate R^2 and error
    model = sputils.calc_rsquared(model);
    model = sputils.calc_error(model);
    
catch ME
    % Clear any interim model results that may have run
    model.aperiodic_params_ = NaN(1, 2 + strcmp(model.aperiodic_mode, 'knee'));
    model.gaussian_params_ = [];
    model.peak_params_ = [];
    model.r_squared_ = NaN;
    model.error_ = NaN;
    model.modeled_spectrum_ = [];
    model.fit_error = true;
    model.error_msg = ME.message;
    
    % Store diagnostic information
    model.error_details = struct(...
        'message', ME.message, ...
        'identifier', ME.identifier, ...
        'stack', ME.stack ...
    );
    
    % Print status with detailed error information
    if model.verbose
        fprintf('\nModel fitting was unsuccessful.\n');
        fprintf('Error: %s\n', ME.message);
        
        % Additional diagnostics based on error type
        if contains(ME.message, 'NaN') || contains(ME.message, 'Inf')
            fprintf('Diagnostic: Input data contains NaN or Inf values that prevented fitting.\n');
            fprintf('Recommendation: Check input data for invalid values.\n');
        elseif contains(ME.message, 'dimensions')
            fprintf('Diagnostic: Dimension mismatch in calculations.\n');
            fprintf('Recommendation: Ensure frequency and power spectrum arrays are same length.\n');
        elseif contains(ME.message, 'fminsearch')
            fprintf('Diagnostic: Optimization algorithm failed to converge.\n');
            fprintf('Recommendation: Try different initial parameters or aperiodic mode.\n');
        elseif contains(ME.message, 'memory')
            fprintf('Diagnostic: Out of memory error.\n');
            fprintf('Recommendation: Try processing smaller segments of data.\n');
        else
            fprintf('Diagnostic: Unknown error occurred during model fitting.\n');
            fprintf('Recommendation: Check input data and parameters.\n');
        end
        
        % Print stack trace for debugging
        if isfield(model, 'debug') && model.debug
            fprintf('\nStack trace:\n');
            for i = 1:length(ME.stack)
                fprintf('  File: %s, Line: %d, Function: %s\n', ...
                    ME.stack(i).file, ME.stack(i).line, ME.stack(i).name);
            end
        end
    end
end

end