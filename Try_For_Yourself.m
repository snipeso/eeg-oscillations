clear
close all
clc


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


% % epileptic kid (bad epilepsy)
% load('D:\Data\ElenaEpilepsy\preprocessed_kispi\A_Preprocessed_CES14.mat', 'epochl', 'artndxn', 'badch', 'vissymb', 'outerring')
% load('D:\Data\ElenaEpilepsy\mat\test.mat', 'EEG')
% SampleRate = EEG.srate;
% Data = EEG.data;
% EpochLength = epochl;

% epileptic kid, great iota
load('D:\Data\ElenaEpilepsy\raw\PIota\EPISL_MU_09_allData_cut.mat', 'pat')
Data = pat.data;
SampleRate = pat.fs;
EpochLength = 20;
vissymb = repmat('0', 1, round(size(Data, 2)*EpochLength/60/60));

ScoringWhole = nan(1, numel(vissymb));
ScoringWhole(vissymb=='0') = 0;
ScoringWhole(vissymb=='1') = -1;
ScoringWhole(vissymb=='2') = -2;
ScoringWhole(vissymb=='3') = -3;
ScoringWhole(vissymb=='r') = 1;



%%


% calculate power
[EpochPower, Frequencies] = oscip.compute_power_on_epochs(Data, ...
    SampleRate, EpochLength, WelchWindowLength, WelchOverlap);

SmoothPower = oscip.smooth_spectrum(EpochPower, Frequencies, SmoothSpan); % better for fooof if the spectra are smooth


%%
% run FOOOF
[Slopes, Intercepts, FooofFrequencies, PeriodicPeaks, WhitenedPower, Errors, RSquared] ...
    = oscip.fit_fooof_multidimentional(SmoothPower, Frequencies, FooofFrequencyRange, MaxError, MinRSquared);

%% plot

close all

Scoring = ScoringWhole(1:size(EpochPower, 2));
ScoringIndexes = -3:1:1;
ScoringLabels = {'N3', 'N2', 'N1', 'W', 'R'};

oscip.plot.temporal_overview(squeeze(mean(WhitenedPower,1, 'omitnan')), ...
    FooofFrequencies, EpochLength, Scoring, ScoringIndexes, ScoringLabels, Slopes, [], [])

oscip.plot.frequency_overview(WhitenedPower, FooofFrequencies, PeriodicPeaks, ...
    Scoring, ScoringIndexes, ScoringLabels, 2, .1, false, false)


%% detect spindles
Settings = oscip.default_settings();
Settings.Mode = 'debug';
% NREM = [-2, -3];
NREM = [0];
StageEpochs = ismember(Scoring, NREM);
Epochs = PeriodicPeaks(:, StageEpochs, :);
[SlowSigma, FastSigma] = oscip.detect_custom_sigma(Epochs, [9 18], 12, Settings);

%%
figure
subplot(1, 2, 1)
TopoData = mean(WhitenedPower(:, :, dsearchn(FooofFrequencies', SlowSigma(1))), 2, 'omitnan');
chART.plot.eeglab_topoplot(TopoData, EEG.chanlocs)
title(num2str(SlowSigma(1), '%.1f'))

subplot(1, 2, 2)
TopoData = mean(WhitenedPower(:, :, dsearchn(FooofFrequencies', FastSigma(1))), 2, 'omitnan');
chART.plot.eeglab_topoplot(TopoData, EEG.chanlocs)
title(num2str(FastSigma(1), '%.1f'))
%% detect iota

