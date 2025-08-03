function [Exponent, Offset, FrequenciesPeriodic, PeriodicPeaks, PeriodicPower, Error, RSquared] ...
    = fit_fooof_matlab(Power, Frequencies, FittingFrequencyRange, AdditionalParameters)
% FooofModel = fit_fooof(Power, Frequencies, FittingFrequencyRange, AdditionalParameters)
% Fits the fooof model to determine spectral parameters. This is script is little
% more than an error-catcher, and instead of outputing a struct like fooof
% does, it outputs a seperate variable for each parameter. Recommendation:
% power should be smoothed before trying to fit model.
%
% Code by Sophia Snipes, 2024, for eeg-oscillations.
arguments
    Power
    Frequencies
    FittingFrequencyRange = [3 40];
    AdditionalParameters = struct();
end

% ensure Power is correct dimensions
Dims = size(Power);
if numel(Dims)>2 || ~any(Dims==1)
    error('power spectrum wrong for specparam')
end

% default outputs
Exponent = nan;
Offset = nan;
FrequenciesPeriodic = oscip.utils.expected_fooof_frequencies(Frequencies, FittingFrequencyRange);
PeriodicPower = nan(1, numel(FrequenciesPeriodic));
Error = 1; % if the model doesn't get fit, this will max out how wrong the fit was
RSquared = 0;
PeriodicPeaks = [];

% check if the data is acceptable
if any(isnan(Power))
    return
elseif all(Power<=0) % power should be all positive
    return
elseif any(Power<=0) % sometimes when smoothing, a few values dip below 0
    % correct data
    Power(Power<=0) = min(Power(Power>0)); % these are set to the lowest other recorded power value to allow the function to keep working
end

try % since it can be finicky, better to use a try/catch statement
    % run fooof
    FooofModel = oscip.specparam_matlab(Frequencies, Power, FittingFrequencyRange, AdditionalParameters); % new function
    Error = FooofModel.error;
    RSquared = FooofModel.r_squared;

    % set up outputs
    FrequenciesPeriodic = FooofModel.freqs;
    Offset = FooofModel.aperiodic_params(1);
    Exponent = FooofModel.aperiodic_params(2);
    PeriodicPeaks = FooofModel.peak_params;
    PeriodicPower = FooofModel.power_spectrum-FooofModel.ap_fit;
catch
    warning("couldn't fit fooof")
end
