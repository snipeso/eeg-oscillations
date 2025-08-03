% Example script: determine if there is a iota oscillation during either
% wake or sleep.
clear
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% setup

% choose what to do
PlotIndividuals = true;

%%% analysis parameters

% power
WelchWindowLength = 8; % in seconds
WelchOverlap = .5; % 50% of the welch windows will overlap

% fooof
FooofFrequencyRange = [3 40]; % frequencies over which to fit the model
SmoothSpan = 3;
MaxError = .15;
MinRSquared = .95;

% specific oscillation detection
Settings = oscip.default_settings(); % check inside here to see what the defaults are
% Settings.PeakBandwidthMax = 2; % and change like this any of the defaults you don't like

SpindleBand = [9 17];


% locations
CD = extractBefore(mfilename('fullpath'), 'Example'); % finds folder this script is saved in
DataFolder = fullfile(CD, 'ExampleData');

% stages to look for spindles
NREM = [-2, -3];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% run

Files = oscip.list_filenames(DataFolder);
Files(~contains(Files, 'Sleep')) = [];

%%% identify main oscillations in each recording
Spindles = nan(numel(Files), 2);
for FileIdx = 1:numel(Files)
    load(fullfile(DataFolder, Files(FileIdx)), 'EEG', ...
        'EpochLength', 'Scoring', 'ScoringIndexes', 'ScoringLabels')
    SampleRate = EEG.srate;
    Data = EEG.data;

    % calculate power
    [EpochPower, Frequencies] = oscip.compute_power_on_epochs(Data, ...
        SampleRate, EpochLength, WelchWindowLength, WelchOverlap);

    SmoothPower = oscip.smooth_spectrum(EpochPower, Frequencies, SmoothSpan); % better for fooof if the spectra are smooth

    % run FOOOF
    [~, ~, FrequenciesPeriodic, PeriodicPeaks, PeriodicPower, ~, ~] ...
        = oscip.fit_fooof_multidimentional(SmoothPower, Frequencies, FooofFrequencyRange);

    % select only NREM
    StageEpochs = ismember(Scoring, NREM);
    Epochs = PeriodicPeaks(:, StageEpochs, :);
    if isempty(Epochs)
        Spindles(FileIdx, :) = nan;
        continue
    end
    [SlowSigma, FastSigma] = oscip.detect_custom_sigma(Epochs);
    Spindles(FileIdx, 1) = SlowSigma(1);
    Spindles(FileIdx, 2) = FastSigma(1);
end

figure
oscip.plot.peak_frequencies(Spindles)
