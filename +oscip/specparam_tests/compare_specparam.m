% Script to compare MATLAB and Python implementations of specparam
clear;
clc;
close all;

%% Generate test data
% Generate frequency vector
freq_range = [1, 30];
freq_res = 0.1;

freqs = freq_range(1):freq_res:freq_range(2);

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

%% Set model parameters
params = struct();
params.peak_width_limits = [1, 8];
params.aperiodic_mode = 'fixed';
params.verbose = 0;  % Suppress terminal output

%% Run both implementations
fprintf('Running MATLAB implementation...\n');
tic;
matlab_model = specparam(power_spectrum, freqs, params);
matlab_time = toc;
fprintf('MATLAB implementation completed in %.4f seconds\n', matlab_time);

% Check if Python code is available
try
    % Try to run Python implementation
    fprintf('\nRunning Python implementation...\n');
    tic;
    python_model = specparam_python(power_spectrum, freqs, params);
    python_time = toc;
    fprintf('Python implementation completed in %.4f seconds\n', python_time);
    python_available = true;
catch ME
    fprintf('\nFailed to run Python implementation: %s\n', ME.message);
    fprintf('Skipping Python implementation comparison.\n');
    python_available = false;
end

%% Compare results if Python available
if python_available
    fprintf('\n=========== COMPARISON RESULTS ===========\n');
    
    % Compare aperiodic parameters
    fprintf('\nAperiodic Parameters:\n');
    fprintf('MATLAB: [%.4f, %.4f]\n', matlab_model.aperiodic_params(1), matlab_model.aperiodic_params(2));
    fprintf('Python: [%.4f, %.4f]\n', python_model.aperiodic_params(1), python_model.aperiodic_params(2));
    
    % Compare number of peaks found
    fprintf('\nNumber of peaks found:\n');
    fprintf('MATLAB: %d\n', size(matlab_model.peak_params, 1));
    fprintf('Python: %d\n', size(python_model.peak_params, 1));
    
    % Compare goodness of fit
    fprintf('\nR-squared:\n');
    fprintf('MATLAB: %.6f\n', matlab_model.r_squared);
    fprintf('Python: %.6f\n', python_model.r_squared);
    
    fprintf('\nError:\n');
    fprintf('MATLAB: %.6f\n', matlab_model.error);
    fprintf('Python: %.6f\n', python_model.error);
    
    % Compare peak parameters
    if ~isempty(matlab_model.peak_params) && ~isempty(python_model.peak_params)
        fprintf('\nPeak Parameters:\n');
        fprintf('%-12s %-12s %-12s\n', 'CF (Hz)', 'PW (log10)', 'BW (Hz)');
        
        fprintf('\nMATLAB Peaks:\n');
        for i = 1:size(matlab_model.peak_params, 1)
            fprintf('%-12.4f %-12.4f %-12.4f\n', ...
                matlab_model.peak_params(i, 1), ...
                matlab_model.peak_params(i, 2), ...
                matlab_model.peak_params(i, 3));
        end
        
        fprintf('\nPython Peaks:\n');
        for i = 1:size(python_model.peak_params, 1)
            fprintf('%-12.4f %-12.4f %-12.4f\n', ...
                python_model.peak_params(i, 1), ...
                python_model.peak_params(i, 2), ...
                python_model.peak_params(i, 3));
        end
        
        % Compare peak frequencies to expected values
        expected_freqs = [6, 10, 22];
        fprintf('\nMatching peaks to expected frequencies [6, 10, 22] Hz:\n');
        
        fprintf('MATLAB matches:\n');
        for i = 1:length(expected_freqs)
            [min_diff, idx] = min(abs(matlab_model.peak_params(:, 1) - expected_freqs(i)));
            if min_diff < 1.0  % Consider it a match if within 1 Hz
                fprintf('Expected: %.1f Hz, Found: %.4f Hz, Difference: %.4f Hz\n', ...
                    expected_freqs(i), matlab_model.peak_params(idx, 1), min_diff);
            else
                fprintf('Expected: %.1f Hz, Not found (closest is %.4f Hz, diff: %.4f Hz)\n', ...
                    expected_freqs(i), matlab_model.peak_params(idx, 1), min_diff);
            end
        end
        
        fprintf('\nPython matches:\n');
        for i = 1:length(expected_freqs)
            [min_diff, idx] = min(abs(python_model.peak_params(:, 1) - expected_freqs(i)));
            if min_diff < 1.0  % Consider it a match if within 1 Hz
                fprintf('Expected: %.1f Hz, Found: %.4f Hz, Difference: %.4f Hz\n', ...
                    expected_freqs(i), python_model.peak_params(idx, 1), min_diff);
            else
                fprintf('Expected: %.1f Hz, Not found (closest is %.4f Hz, diff: %.4f Hz)\n', ...
                    expected_freqs(i), python_model.peak_params(idx, 1), min_diff);
            end
        end
    end
    
    % Calculate model spectrum differences
    if ~isempty(matlab_model.modeled_spectrum) && ~isempty(python_model.modeled_spectrum)
        model_diff = matlab_model.modeled_spectrum - python_model.modeled_spectrum;
        mean_diff = mean(abs(model_diff));
        max_diff = max(abs(model_diff));
        
        fprintf('\nModel Spectrum Differences:\n');
        fprintf('Mean absolute difference: %.6f\n', mean_diff);
        fprintf('Max absolute difference: %.6f\n', max_diff);
    end
    
    %% Plot comparison
    figure('Name', 'MATLAB vs Python Implementation Comparison', 'Position', [100, 100, 1000, 800]);
    
    % Plot original and fitted spectra
    subplot(2, 2, 1);
    semilogy(freqs, power_spectrum, 'k-', 'LineWidth', 2);
    hold on;
    semilogy(freqs, 10.^matlab_model.modeled_spectrum, 'r--', 'LineWidth', 2);
    semilogy(freqs, 10.^python_model.modeled_spectrum, 'b:', 'LineWidth', 2);
    title('Power Spectrum: Original vs. Models');
    legend('Original', 'MATLAB Fit', 'Python Fit');
    xlabel('Frequency (Hz)');
    ylabel('Power');
    grid on;
    
    % Plot log scale comparison
    subplot(2, 2, 2);
    plot(freqs, log10(power_spectrum), 'k-', 'LineWidth', 2);
    hold on;
    plot(freqs, matlab_model.modeled_spectrum, 'r--', 'LineWidth', 2);
    plot(freqs, python_model.modeled_spectrum, 'b:', 'LineWidth', 2);
    title('Log Power Spectrum: Original vs. Models');
    legend('Original', 'MATLAB Fit', 'Python Fit');
    xlabel('Frequency (Hz)');
    ylabel('Log10 Power');
    grid on;
    
    % Plot aperiodic components
    subplot(2, 2, 3);
    plot(freqs, matlab_model.ap_fit, 'r-', 'LineWidth', 2);
    hold on;
    plot(freqs, python_model.ap_fit, 'b:', 'LineWidth', 2);
    title('Aperiodic Component Comparison');
    legend('MATLAB', 'Python');
    xlabel('Frequency (Hz)');
    ylabel('Log10 Power');
    grid on;
    
    % Plot differences
    subplot(2, 2, 4);
    plot(freqs, matlab_model.modeled_spectrum - python_model.modeled_spectrum, 'k-', 'LineWidth', 2);
    title('Model Difference (MATLAB - Python)');
    xlabel('Frequency (Hz)');
    ylabel('Difference (Log10 Power)');
    grid on;
    
    % Save the figure
    saveas(gcf, 'specparam_comparison.png');
    fprintf('\nComparison figure saved as "specparam_comparison.png"\n');
else
    % Just plot MATLAB results if Python is not available
    figure('Name', 'MATLAB Implementation Results', 'Position', [100, 100, 800, 600]);
    
    subplot(2, 1, 1);
    semilogy(freqs, power_spectrum, 'b-', 'LineWidth', 2);
    hold on;
    semilogy(freqs, 10.^matlab_model.modeled_spectrum, 'r--', 'LineWidth', 2);
    title('Power Spectrum: Original vs. MATLAB Model');
    legend('Original', 'MATLAB Fit');
    xlabel('Frequency (Hz)');
    ylabel('Power');
    grid on;
    
    subplot(2, 1, 2);
    plot(freqs, log10(power_spectrum), 'b-', 'LineWidth', 2);
    hold on;
    plot(freqs, matlab_model.ap_fit, 'g--', 'LineWidth', 2);
    plot(freqs, matlab_model.modeled_spectrum, 'r--', 'LineWidth', 2);
    title('Model Components (MATLAB)');
    legend('Original', 'Aperiodic Component', 'Full Model');
    xlabel('Frequency (Hz)');
    ylabel('Log10 Power');
    grid on;
    
    saveas(gcf, 'matlab_specparam_results.png');
    fprintf('\nMATLAB results figure saved as "matlab_specparam_results.png"\n');
end

fprintf('\nComparison complete!\n');


%%

% timing

A = tic;
matlab_model = specparam(power_spectrum, freqs, params);
disp(['finished matlab in ', num2str(toc(A)), ' s'])

A = tic;
python_model = specparam_python(power_spectrum, freqs, params);
disp(['finished python in ', num2str(toc(A)), ' s'])

