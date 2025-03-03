clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Select a file:

% SET the path of the file

EEGFilepath = 'D:\Code\MyToolboxes\eeg-oscillations\ExampleData\P09_Sleep_NightPre.mat';

load(EEGFilepath, 'EEG', 'Scoring', 'ScoringIndexes', 'ScoringLabels', 'EpochLength') % load in the data however you have it

% EEG should be a EEGLAB structure. Needs to have fields .srate for the
% sample rate and .data with a channel x time matrix. Plotting the
% topographies requires a .chanlocs.

%%% Write in manually if not loaded in from file

% EpochLength = 30; 
% Scoring = []; % leave empty if you don't have scoring data. Otherwise, should be an array of numbers indicating different stages for each epoch
% ScoringIndexes = []; % all the numbers in the Scoring array, in order
% ScoringLabels = {}; % the label to assign to each number

% power
WelchWindowLength = 2; % in seconds
WelchOverlap = .5; % 50% of the welch windows will overlap

% fooof
FooofFrequencyRange = [3 40]; % frequencies over which to fit the model
SmoothSpan = 3;
MaxError = .15;
MinRSquared = .95;

Data = EEG.data;
SampleRate = EEG.srate;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Run FOOOF on epochs

% calculate power
[EpochPower, Frequencies] = oscip.compute_power_on_epochs(Data, ...
    SampleRate, EpochLength, WelchWindowLength, WelchOverlap);

SmoothPower = oscip.smooth_spectrum(EpochPower, Frequencies, SmoothSpan); % better for fooof if the spectra are smooth


% run FOOOF
[Slopes, Intercepts, FooofFrequencies, PeriodicPeaks, PeriodicPower, Errors, RSquared] ...
    = oscip.fit_fooof_multidimentional(SmoothPower, Frequencies, FooofFrequencyRange, MaxError, MinRSquared);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot


%% plot periodic activity and slopes in time

if isempty (Scoring)
Scoring = zeros(1, size(Slopes, 2));
ScoringIndexes = -3:1:1;
ScoringLabels = {'N3', 'N2', 'N1', 'W', 'R'};
end

oscip.plot.temporal_overview(squeeze(mean(PeriodicPower,1, 'omitnan')), ...
    FooofFrequencies, EpochLength, Scoring, ScoringIndexes, ScoringLabels, Slopes, [], [])

%% plot all periodic peak frequencies by sleep stage

oscip.plot.frequency_overview(PeriodicPower, FooofFrequencies, PeriodicPeaks, ...
    Scoring, ScoringIndexes, ScoringLabels, 2, .1, false, false)

%%
figure('Units','centimeters', 'Position',[0 0 10 15], 'Color','w')

oscip.plot.histogram_stages(Slopes(1, :), Scoring, ScoringLabels, ScoringIndexes);
% oscip.plot.histogram_stages(Slopes(:)', reshape(repmat(Scoring, size(Slopes, 1), 1), [], 1)', ScoringLabels, ScoringIndexes);
xlim([.5 4.5])

%% detect spindles
Settings = oscip.default_settings();
Settings.Mode = 'analysis';
NREM = [-2, -3];
StageEpochs = ismember(Scoring, NREM);
Epochs = PeriodicPeaks(:, StageEpochs, :);
[SlowSigma, FastSigma] = oscip.detect_custom_sigma(Epochs, [9 18], 12, Settings);

figure

if ~isnan(SlowSigma(1))
    Band = dsearchn(FooofFrequencies',  SlowSigma(1) + [-SlowSigma(3)/2; SlowSigma(3)/2]);
subplot(1, 2, 1)
TopoData = mean(mean(PeriodicPower(:, StageEpochs, Band(1):Band(2)), 2, 'omitnan'),3, 'omitnan');
chART.plot.eeglab_topoplot(TopoData, Chanlocs)
title(num2str(SlowSigma(1), '%.1f'))
end

if ~isnan(FastSigma(1))
       Band = dsearchn(FooofFrequencies',  FastSigma(1) + [-FastSigma(3)/2; FastSigma(3)/2]);
subplot(1, 2, 2)
TopoData = mean(mean(PeriodicPower(:, StageEpochs, Band(1):Band(2)), 2, 'omitnan'),3, 'omitnan');
chART.plot.eeglab_topoplot(TopoData, Chanlocs)
title(num2str(FastSigma(1), '%.1f'))
end
%% detect iota
IotaBand = [25 35];
% IotaBand = [5 10];


% REM
StageEpochs = ismember(Scoring, 1);
Epochs = PeriodicPeaks(:, StageEpochs, :);
[isPeak, MaxPeak] = oscip.check_peak_in_band(Epochs, IotaBand, 1);

figure;plot(FooofFrequencies, squeeze(mean(PeriodicPower(:, StageEpochs, :), 2, 'omitnan'))')

figure('Units','centimeters', 'position', [0 0 25 10])
subplot(1, 3, 1)
TopoData = mean(PeriodicPower(:, StageEpochs, dsearchn(FooofFrequencies', MaxPeak(1))), 2, 'omitnan');
chART.plot.eeglab_topoplot(TopoData, Chanlocs)
title(['REM iota: ', num2str(MaxPeak(1), '%.1f') ' Hz'])
colorbar

subplot(1, 3, 2)
ControlFreq = 123;
TopoData = mean(PeriodicPower(:, StageEpochs, ControlFreq), 2, 'omitnan');
chART.plot.eeglab_topoplot(TopoData, Chanlocs)
title(['ControlFreq: ', num2str(FooofFrequencies(ControlFreq), '%.1f') ' Hz'])
colorbar


% wake
StageEpochs = ismember(Scoring, 0);
Epochs = PeriodicPeaks(:, StageEpochs, :);
[isPeak, MaxPeak] = oscip.check_peak_in_band(Epochs, IotaBand, 1);

subplot(1, 3, 3)
TopoData = mean(PeriodicPower(:, StageEpochs, dsearchn(FooofFrequencies', MaxPeak(1))), 2, 'omitnan');
chART.plot.eeglab_topoplot(TopoData, Chanlocs)
title(['Wake iota: ', num2str(MaxPeak(1), '%.1f') ' Hz'])
colorbar

% TopoData = mean(PeriodicPower(:, StageEpochs, 50), 2, 'omitnan');
% chART.plot.eeglab_topoplot(TopoData, Chanlocs)
% title(['Wake iota: ', num2str(MaxPeak(1), '%.1f') ' Hz'])
% colorbar


%% SWA

StageEpochs = ismember(Scoring, [-2 -3]);
% StageEpochs = ismember(Scoring, [0]);
figure
TopoData = mean(Slopes(:, StageEpochs), 2, 'omitnan');
chART.plot.eeglab_topoplot(TopoData, Chanlocs)


figure
  Band = dsearchn(FooofFrequencies', [0.5; 4]);
TopoData = mean(mean(log(SmoothPower(:, StageEpochs, Band(1):Band(2))), 2, 'omitnan'), 3, 'omitnan');
chART.plot.eeglab_topoplot(TopoData, Chanlocs)


