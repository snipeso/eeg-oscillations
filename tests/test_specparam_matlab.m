
%% test matlab_specparam

AcceptableDifference = .01; % basically proportion of the real fooof algorithm, this is the max difference allowed

% Get the directory where the current script is located
thisFilePath = mfilename('fullpath');
thisDir = fileparts(thisFilePath);

% Build path to Data.mat relative to the script
dataPath = fullfile(thisDir, '..', 'ExampleData', 'P07_Sleep_NightPre.mat');
load(dataPath, 'EEG');

Data = EEG.data(1, 2000:5000);

[Power, Frequencies] = oscip.compute_power(Data, EEG.srate, 5, 0.5);


[SlopesMat, InterceptsMat, FooofFrequenciesMat, PeriodicPeaksMat, PeriodicPowerMat, ErrorsMat, RSquaredMat] ...
    = oscip.fit_fooof_matlab(Power, Frequencies, FittingFrequencyRange, MaxError, MinRSquared, AdditionalParameters);

[Slopes, Intercepts, FooofFrequencies, PeriodicPeaks, PeriodicPower, Errors, RSquared] ...
    = oscip.fit_fooof(Power, Frequencies, FittingFrequencyRange, MaxError, MinRSquared, AdditionalParameters);

%%
out_of_range(Slopes, SlopesMat, AcceptableDifference, 'Slope')
out_of_range(Intercepts, InterceptsMat, AcceptableDifference, 'Intercept')
out_of_range(FooofFrequencies, FooofFrequenciesMat, AcceptableDifference, 'Frequencies')
out_of_range(PeriodicPeaks, PeriodicPeaksMat, AcceptableDifference, 'PeriodicPeaks')
out_of_range(PeriodicPower, PeriodicPowerMat, AcceptableDifference, 'PeriodicPower')
out_of_range(Errors, ErrorsMat, AcceptableDifference, 'Error')
out_of_range(RSquared, RSquaredMat, AcceptableDifference, 'Rsquared')

function out_of_range(OriginalValue, MatValue, Threshold, Measure)

if any(MatValue < OriginalValue-OriginalValue*Threshold, "all") || any(MatValue > OriginalValue+OriginalValue*Threshold, 'all')
    error([Measure, ' out of range'])
end
end