
%% test matlab_specparam overall performance

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

disp('Testing fit_fooof')

out_of_range(Slopes, SlopesMat, AcceptableDifference, 'Slope')
out_of_range(Intercepts, InterceptsMat, AcceptableDifference, 'Intercept')
out_of_range(FooofFrequencies, FooofFrequenciesMat, AcceptableDifference, 'Frequencies')
out_of_range(PeriodicPeaks, PeriodicPeaksMat, AcceptableDifference, 'PeriodicPeaks')
out_of_range(PeriodicPower, PeriodicPowerMat, AcceptableDifference, 'PeriodicPower')
out_of_range(Errors, ErrorsMat, AcceptableDifference, 'Error')
out_of_range(RSquared, RSquaredMat, AcceptableDifference, 'Rsquared')


%% test check_settings

disp('Testing check_settings')
empty = struct();
settings = fooof_check_settings(empty);
settingsmat = oscip.sputils.check_settings(empty);
same_fields(settings, settingsmat, 'Defaults')


%% test different settings output (TODO)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions


function out_of_range(OriginalValue, MatValue, Threshold, Measure)

if any(MatValue < OriginalValue-OriginalValue*Threshold, "all") || any(MatValue > OriginalValue+OriginalValue*Threshold, 'all')
    error([Measure, ' out of range'])
end
end


function same_fields(OriginalSettings, MatSettings, TestName)

Fields = fieldnames(OriginalSettings);
FieldsMat = fieldnames(MatSettings);

if ~isequal(FieldsMat, Fields)
error(['mismatch in fields of ', TestName])
end

for Field = Fields'
if ~isequal(OriginalSettings.(Field{1}), MatSettings.(Field{1}))

    error(['Different value in ', Field{1}])
end
end
end