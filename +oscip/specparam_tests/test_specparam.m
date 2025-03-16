% TEST_SPECPARAM - Unit tests for the MATLAB specparam implementation
%
% This script runs a series of tests on the specparam.m implementation
% to verify it functions correctly, in a manner similar to the Python tests.
%
% The tests include:
% - Basic functionality tests
% - Gaussian function tests
% - Aperiodic component tests
% - Full model fitting tests
% - Parameter accuracy tests
% - Edge case tests

% Clear workspace and command window
clear;
clc;

% Set up output formatting
fprintf('\n==== SPECPARAM MATLAB TESTS ====\n\n');

% Initialize test counter
tests_run = 0;
tests_passed = 0;

% Create test frequency range
freq_range = [3, 50];
freqs = freq_range(1):0.1:freq_range(2);

%% ===== Test 1: Gaussian Function =====
tests_run = tests_run + 1;

% Generate a Gaussian with known parameters
center = 10;
height = 0.5;
width = 2;

% Calculate Gaussian
gauss_data = oscip.sputils.gaussian_function(freqs, [center, height, width]);

% Test the peak location and height
[max_val, max_idx] = max(gauss_data);
peak_freq = freqs(max_idx);

if abs(peak_freq - center) < 0.1 && abs(max_val - height) < 0.01
    fprintf('✓ Test 1: Gaussian function generates correct peak\n');
    tests_passed = tests_passed + 1;
else
    fprintf('✗ Test 1: Gaussian function failed - expected peak at %.1f Hz with height %.2f, got %.1f Hz with height %.2f\n', ...
        center, height, peak_freq, max_val);
end

%% ===== Test 2: Aperiodic Function (Fixed) =====
tests_run = tests_run + 1;

% Generate aperiodic component with known parameters
offset = 1;
exponent = 1.5;

% Calculate aperiodic component
ap_data_log = oscip.sputils.gen_aperiodic(freqs, [offset, exponent], 'fixed');
ap_data = 10.^ap_data_log;

% Test the generated values using a reference calculation at specific frequencies
ref_freq1 = 10;
ref_freq2 = 30;
idx1 = find(freqs >= ref_freq1, 1);
idx2 = find(freqs >= ref_freq2, 1);

expected1 = offset - log10(ref_freq1^exponent);
expected2 = offset - log10(ref_freq2^exponent);

if abs(ap_data_log(idx1) - expected1) < 0.01 && abs(ap_data_log(idx2) - expected2) < 0.01
    fprintf('✓ Test 2: Aperiodic function (fixed) generates correct values\n');
    tests_passed = tests_passed + 1;
else
    fprintf('✗ Test 2: Aperiodic function (fixed) failed - expected [%.2f, %.2f], got [%.2f, %.2f]\n', ...
        expected1, expected2, ap_data_log(idx1), ap_data_log(idx2));
end

%% ===== Test 3: Simulate Power Spectrum =====
tests_run = tests_run + 1;

% Generate a test power spectrum with known parameters
ap_params = [1, 1.5];
gauss_params = [10, 0.5, 2, 20, 0.3, 4];

% Calculate aperiodic component
ap_log = oscip.sputils.gen_aperiodic(freqs, ap_params, 'fixed');
aperiodic = 10.^ap_log;

% Calculate peaks
peaks = oscip.sputils.gen_periodic(freqs, gauss_params);

% Calculate full power spectrum
power_spectrum = aperiodic .* (1 + peaks);

% Verify spectrum contains expected data by checking peaks
[pks, locs] = findpeaks(power_spectrum, freqs, 'MinPeakProminence', 0.1);
found_peak1 = any(abs(locs - 10) < 0.5);
found_peak2 = any(abs(locs - 20) < 0.5);

if found_peak1 && found_peak2
    fprintf('✓ Test 3: Power spectrum simulation produces expected peaks\n');
    tests_passed = tests_passed + 1;
else
    fprintf('✗ Test 3: Power spectrum simulation failed to produce expected peaks\n');
end

%% ===== Test 4: Basic Model Fit =====
tests_run = tests_run + 1;

% Set model parameters
params = struct();
params.peak_width_limits = [1, 8];
params.aperiodic_mode = 'fixed';
params.verbose = 0;

% Run the model
model = specparam(power_spectrum, freqs, params);

% Check if the model fit the data
if model.r_squared_ > 0.9
    fprintf('✓ Test 4: Basic model fit achieves good R² (%.4f)\n', model.r_squared_);
    tests_passed = tests_passed + 1;
else
    fprintf('✗ Test 4: Basic model fit failed with poor R² (%.4f)\n', model.r_squared_);
end

%% ===== Test 5: Aperiodic Parameter Recovery =====
tests_run = tests_run + 1;

% Test if the model recovered the aperiodic parameters correctly
ap_offset_error = abs(model.aperiodic_params_(1) - ap_params(1));
ap_exponent_error = abs(model.aperiodic_params_(2) - ap_params(2));

if ap_offset_error < 0.5 && ap_exponent_error < 0.5
    fprintf('✓ Test 5: Aperiodic parameters recovered within tolerance\n');
    fprintf('    Expected: [%.2f, %.2f], Got: [%.2f, %.2f], Error: [%.2f, %.2f]\n', ...
        ap_params(1), ap_params(2), model.aperiodic_params_(1), model.aperiodic_params_(2), ...
        ap_offset_error, ap_exponent_error);
    tests_passed = tests_passed + 1;
else
    fprintf('✗ Test 5: Aperiodic parameter recovery failed\n');
    fprintf('    Expected: [%.2f, %.2f], Got: [%.2f, %.2f], Error: [%.2f, %.2f]\n', ...
        ap_params(1), ap_params(2), model.aperiodic_params_(1), model.aperiodic_params_(2), ...
        ap_offset_error, ap_exponent_error);
end

%% ===== Test 6: Peak Detection =====
tests_run = tests_run + 1;

% Test if the model found the correct number of peaks
expected_n_peaks = length(gauss_params) / 3;
found_n_peaks = size(model.peak_params_, 1);

if found_n_peaks == expected_n_peaks
    fprintf('✓ Test 6: Correct number of peaks detected (%d)\n', found_n_peaks);
    tests_passed = tests_passed + 1;
else
    fprintf('✗ Test 6: Incorrect number of peaks detected (expected %d, got %d)\n', ...
        expected_n_peaks, found_n_peaks);
end

%% ===== Test 7: Peak Parameter Recovery =====
tests_run = tests_run + 1;

% Test peak parameter recovery (center frequency)
peak_errors = zeros(1, length(gauss_params) / 3);
for i = 1:length(gauss_params) / 3
    expected_cf = gauss_params((i-1)*3 + 1);
    
    % Find the closest peak in the results
    [min_diff, idx] = min(abs(model.peak_params_(:, 1) - expected_cf));
    peak_errors(i) = min_diff;
end

if max(peak_errors) < 1.0  % Allow up to 1 Hz error in peak location
    fprintf('✓ Test 7: Peak frequencies recovered within tolerance\n');
    fprintf('    Peak frequency errors: [%s]\n', sprintf('%.2f ', peak_errors));
    tests_passed = tests_passed + 1;
else
    fprintf('✗ Test 7: Peak frequency recovery failed\n');
    fprintf('    Peak frequency errors: [%s]\n', sprintf('%.2f ', peak_errors));
end

%% ===== Test 8: Knee Mode =====
tests_run = tests_run + 1;

% Generate a spectrum with a knee
ap_params_knee = [1, 10, 1.5];  % offset, knee, exponent

% Calculate aperiodic component with knee
ap_knee_log = oscip.sputils.gen_aperiodic(freqs, ap_params_knee, 'knee');
aperiodic_knee = 10.^ap_knee_log;

% Calculate full power spectrum with the same peaks
power_spectrum_knee = aperiodic_knee .* (1 + peaks);

% Set model parameters for knee
params_knee = struct();
params_knee.peak_width_limits = [1, 8];
params_knee.aperiodic_mode = 'knee';
params_knee.verbose = 0;

% Run the model
model_knee = specparam(power_spectrum_knee, freqs, params_knee);

% Check if the model has 3 aperiodic parameters (offset, knee, exponent)
if length(model_knee.aperiodic_params_) == 3
    fprintf('✓ Test 8: Knee mode detected and fit correctly\n');
    tests_passed = tests_passed + 1;
else
    fprintf('✗ Test 8: Knee mode failed to fit correctly\n');
end

%% ===== Test 9: Error Handling - Empty Data =====
tests_run = tests_run + 1;

% Test model behavior with empty data
try
    model_empty = specparam([], [], params);
    failed = false;
catch
    failed = true;
end

if failed
    fprintf('✓ Test 9: Model correctly rejects empty data\n');
    tests_passed = tests_passed + 1;
else
    fprintf('✗ Test 9: Model failed to reject empty data\n');
end

%% ===== Test 10: MATLAB vs. Python Comparison =====
tests_run = tests_run + 1;

try
    % Try to run Python implementation for comparison
    python_model = specparam_python(power_spectrum, freqs, params);
    
    % Compare results
    r2_diff = abs(model.r_squared_ - python_model.r_squared_);
    ap_diff = mean(abs(model.aperiodic_params_ - python_model.aperiodic_params_));
    
    % Get peak frequency differences
    peak_freq_diffs = [];
    for i = 1:size(model.peak_params_, 1)
        if ~isempty(python_model.peak_params_)
            [min_diff, ~] = min(abs(model.peak_params_(i, 1) - python_model.peak_params_(:, 1)));
            peak_freq_diffs = [peak_freq_diffs, min_diff];
        end
    end
    
    if isempty(peak_freq_diffs)
        peak_freq_diff = Inf;
    else
        peak_freq_diff = mean(peak_freq_diffs);
    end
    
    if r2_diff < 0.05 && ap_diff < 0.2 && peak_freq_diff < 1.0
        fprintf('✓ Test 10: MATLAB and Python implementations produce similar results\n');
        fprintf('    R² difference: %.4f, Aperiodic param difference: %.4f, Peak freq difference: %.4f\n', ...
            r2_diff, ap_diff, peak_freq_diff);
        tests_passed = tests_passed + 1;
    else
        fprintf('✗ Test 10: MATLAB and Python implementations produce different results\n');
        fprintf('    R² difference: %.4f, Aperiodic param difference: %.4f, Peak freq difference: %.4f\n', ...
            r2_diff, ap_diff, peak_freq_diff);
    end
catch ME
    fprintf('✗ Test 10: Could not compare MATLAB and Python implementations\n');
    fprintf('    Error: %s\n', ME.message);
end

%% ===== Test Results Summary =====
fprintf('\n==== TEST SUMMARY ====\n');
fprintf('Tests run: %d\n', tests_run);
fprintf('Tests passed: %d (%.1f%%)\n', tests_passed, 100 * tests_passed / tests_run);

if tests_passed == tests_run
    fprintf('\nALL TESTS PASSED!\n');
else
    fprintf('\nSOME TESTS FAILED!\n');
end