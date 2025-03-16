function aperiodic_params = simple_ap_fit(model, power_spectrum)
% Simple fit of the aperiodic component of the power spectrum
%
% INPUTS:
%   model : struct
%       Model object containing model settings and results
%   power_spectrum : 1d array
%       Power spectrum values to fit
%
% OUTPUTS:
%   aperiodic_params : array
%       Parameters for aperiodic fit (offset, exponent) or (offset, knee, exponent)

freqs = model.freqs;

% Get bounds and guess parameters
if strcmp(model.aperiodic_mode, 'fixed')
    % For fixed mode: offset, exponent
    % Initial guesses
    offset_guess = power_spectrum(1);
    exponent_guess = abs((power_spectrum(end) - power_spectrum(1)) / ...
        (log10(freqs(end)) - log10(freqs(1))));
    
    % Set up fit function and initial parameters
    guess = [offset_guess, exponent_guess];
    
    % Fit the aperiodic component
    options = optimset('Display', 'off', 'TolX', 1e-5, 'TolFun', 1e-5, 'MaxFunEvals', 5000);
    % Ensure freqs and power_spectrum have the same length
    if length(freqs) ~= length(power_spectrum)
        % Use only the frequencies that correspond to the power spectrum
        aperiodic_params = fminsearch(@(params) sum((power_spectrum - ...
            (params(1) - log10(freqs(1:length(power_spectrum)).^params(2)))).^2), guess, options);
    else
        aperiodic_params = fminsearch(@(params) sum((power_spectrum - ...
            (params(1) - log10(freqs.^params(2)))).^2), guess, options);
    end
    
elseif strcmp(model.aperiodic_mode, 'knee')
    % For knee mode: offset, knee, exponent
    % Initial guesses
    offset_guess = power_spectrum(1);
    knee_guess = 1; % Default guess for knee
    exponent_guess = abs((power_spectrum(end) - power_spectrum(1)) / ...
        (log10(freqs(end)) - log10(freqs(1))));
    
    % Set up fit function and initial parameters
    guess = [offset_guess, knee_guess, exponent_guess];
    
    % Fit the aperiodic component
    options = optimset('Display', 'off', 'TolX', 1e-5, 'TolFun', 1e-5, 'MaxFunEvals', 5000);
    % Ensure freqs and power_spectrum have the same length
    if length(freqs) ~= length(power_spectrum)
        % Use only the frequencies that correspond to the power spectrum
        aperiodic_params = fminsearch(@(params) sum((power_spectrum - ...
            (params(1) - log10(params(2) + freqs(1:length(power_spectrum)).^params(3)))).^2), guess, options);
    else
        aperiodic_params = fminsearch(@(params) sum((power_spectrum - ...
            (params(1) - log10(params(2) + freqs.^params(3)))).^2), guess, options);
    end
end

end