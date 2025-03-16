% Example script for using the specparam function to model a power spectrum
clear
clc
close all


% Generate frequency vector
freq_range = [1, 30];
freq_res = 0.1;
freqs = freq_range(1):freq_res:freq_range(2);

%% Generate a simulated power spectrum with aperiodic component and peaks

% Aperiodic component parameters (offset, exponent)
aperiodic_params = [1, 1.5];

% Simulate aperiodic component
aperiodic = 10.^(aperiodic_params(1) - log10(freqs.^aperiodic_params(2)));

% Add some peaks (centered at 6 Hz, 10 Hz, and 22 Hz)
peaks = zeros(size(freqs));
gauss_params = [
    6, 0.5, 1;     % Center frequency, height, width (std)
    10, 0.7, 1.2;
    22, 0.3, 1.5
];

for i = 1:size(gauss_params, 1)
    center = gauss_params(i, 1);
    height = gauss_params(i, 2);
    std = gauss_params(i, 3);
    peaks = peaks + height * exp(-(freqs - center).^2 / (2 * std^2));
end

% Convert peaks to linear and add them to aperiodic component
power_spectrum = aperiodic .* (1 + peaks);

%% Fit the model


% Set custom parameters
params = struct();
params.peak_width_limits = [1, 8];
params.aperiodic_mode = 'fixed';
params.verbose = 1;

% Run the model
fprintf('Fitting spectrum with specparam...\n');
model = specparam(power_spectrum, freqs, params);

%% Display results

% Check if model fitting was successful
if isfield(model, 'fit_error') && model.fit_error
    fprintf('\n=== Model Fitting Failed ===\n');
    fprintf('Error message: %s\n', model.errormsg);
    
    % Display specific recommendations based on the error
    fprintf('\nTroubleshooting tips:\n');
    if isfield(model, 'error_details')
        fprintf('- Error identifier: %s\n', model.errordetails.identifier);
        
        % Recommend solutions based on error type
        if contains(model.errormsg, 'NaN') || contains(model.errormsg, 'Inf')
            fprintf('- Check your input data for NaN or Inf values\n');
            fprintf('- Try preprocessing your data to remove artifacts\n');
        elseif contains(model.errormsg, 'dimension')
            fprintf('- Ensure your frequency and power spectrum arrays have matching dimensions\n');
        elseif contains(model.errormsg, 'convergence') || contains(model.errormsg, 'fminsearch')
            fprintf('- Try different initial parameters\n');
            fprintf('- Consider changing aperiodic_mode (fixed vs. knee)\n');
            fprintf('- Adjust peak detection thresholds\n');
        else
            fprintf('- Try with a simpler frequency range\n');
            fprintf('- Check if your data is in linear scale (not log scale)\n');
            fprintf('- Smooth your spectrum if it contains a lot of noise\n');
        end
    end
    
    % Early return if visualization isn't possible
    if ~isfield(model, 'freqs') || isempty(model.freqs)
        return;
    end
else
    % Print model information for successful fit
    fprintf('\n=== Model Results ===\n');
    fprintf('Aperiodic Parameters (offset, exponent): [%.2f, %.2f]\n', ...
        model.aperiodic_params(1), model.aperiodic_params(2));
    fprintf('Number of peaks found: %d\n', size(model.peak_params, 1));
    fprintf('R-squared: %.4f\n', model.r_squared);
    fprintf('Error: %.4f\n', model.error);
end

% Print peak information
if ~isempty(model.peak_params)
    fprintf('\n=== Peak Parameters ===\n');
    fprintf('CF (Hz)   PW (log10)   BW (Hz)\n');
    for i = 1:size(model.peak_params, 1)
        fprintf('%.2f      %.2f        %.2f\n', ...
            model.peak_params(i, 1), model.peak_params(i, 2), model.peak_params(i, 3));
    end
end

%% Plot the results

figure;

% Plot original spectrum
subplot(2, 1, 1);
semilogy(freqs, power_spectrum, 'b-', 'LineWidth', 2);
hold on;

% Add model fit if available
if ~isfield(model, 'fit_error') || ~model.fit_error
    semilogy(freqs, 10.^model.modeled_spectrum, 'r--', 'LineWidth', 2);
    title('Power Spectrum: Original vs. Model');
    legend('Original Spectrum', 'Model Fit');
else
    title('Power Spectrum (Model Fitting Failed)');
    legend('Original Spectrum');
end
xlabel('Frequency (Hz)');
ylabel('Power');
grid on;

% Plot model components if available
subplot(2, 1, 2);
plot(freqs, log10(power_spectrum), 'b-', 'LineWidth', 2);
hold on;

if ~isfield(model, 'fit_error') || ~model.fit_error
    % Plot aperiodic component
    plot(freqs, model.ap_fit, 'g--', 'LineWidth', 2);
    
    % Extract and plot individual peaks if available
    if ~isempty(model.gaussian_params)
        peak_fit = zeros(size(freqs));
        for i = 1:size(model.gaussian_params, 1)
            center = model.gaussian_params(i, 1);
            height = model.gaussian_params(i, 2);
            std = model.gaussian_params(i, 3);
            
            peak = height * exp(-(freqs - center).^2 / (2 * std^2));
            peak_fit = peak_fit + peak;
            
            % Plot individual peaks with aperiodic offset
            plot(freqs, model.ap_fit + peak, 'r:', 'LineWidth', 1.5);
        end
    end
    
    plot(freqs, model.modeled_spectrum, 'c--', 'LineWidth', 2);
    title('Model Components');
    legend('Original Spectrum', 'Aperiodic Component', 'Full Model');
else
    title('Log Power Spectrum (Model Fitting Failed)');
    legend('Original Spectrum (log10)');
end

xlabel('Frequency (Hz)');
ylabel('Log10 Power');
grid on;

fprintf('\nExample complete. Review the figure for visual representation of the model fit.\n');