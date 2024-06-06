

% power
WelchWindowLength = 2; % in seconds
WelchOverlap = .5; % 50% of the welch windows will overlap

% fooof
FooofFrequencyRange = [3 40]; % frequencies over which to fit the model
SmoothSpan = 3;
MaxError = .15;
MinRSquared = .95;

% specific oscillation detection
Settings = oscip.default_settings(); % check inside here to see what the defaults are


Data = EEG.data;

SampleRate = EEG.srate;
EpochLength = 10;



% calculate power
[EpochPower, Frequencies] = oscip.compute_power_on_epochs(Data, ...
    SampleRate, EpochLength, WelchWindowLength, WelchOverlap);

SmoothPower = oscip.smooth_spectrum(EpochPower, Frequencies, SmoothSpan); % better for fooof if the spectra are smooth


% run FOOOF
[Slopes, Intercepts, FooofFrequencies, PeriodicPeaks, WhitenedPower, Errors, RSquared] ...
    = oscip.fit_fooof_multidimentional(SmoothPower, Frequencies, FooofFrequencyRange, MaxError, MinRSquared);

%% plot

% close all

Scoring = zeros(1, size(Slopes, 2));
ScoringIndexes = -3:1:1;
ScoringLabels = {'N3', 'N2', 'N1', 'W', 'R'};

oscip.plot.temporal_overview(squeeze(mean(WhitenedPower,1, 'omitnan')), ...
    FooofFrequencies, EpochLength, Scoring, ScoringIndexes, ScoringLabels, Slopes, [], [])

oscip.plot.frequency_overview(WhitenedPower, FooofFrequencies, PeriodicPeaks, ...
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
TopoData = mean(mean(WhitenedPower(:, StageEpochs, Band(1):Band(2)), 2, 'omitnan'),3, 'omitnan');
chART.plot.eeglab_topoplot(TopoData, Chanlocs)
title(num2str(SlowSigma(1), '%.1f'))
end

if ~isnan(FastSigma(1))
       Band = dsearchn(FooofFrequencies',  FastSigma(1) + [-FastSigma(3)/2; FastSigma(3)/2]);
subplot(1, 2, 2)
TopoData = mean(mean(WhitenedPower(:, StageEpochs, Band(1):Band(2)), 2, 'omitnan'),3, 'omitnan');
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

figure;plot(FooofFrequencies, squeeze(mean(WhitenedPower(:, StageEpochs, :), 2, 'omitnan'))')

figure('Units','centimeters', 'position', [0 0 25 10])
subplot(1, 3, 1)
TopoData = mean(WhitenedPower(:, StageEpochs, dsearchn(FooofFrequencies', MaxPeak(1))), 2, 'omitnan');
chART.plot.eeglab_topoplot(TopoData, Chanlocs)
title(['REM iota: ', num2str(MaxPeak(1), '%.1f') ' Hz'])
colorbar

subplot(1, 3, 2)
ControlFreq = 123;
TopoData = mean(WhitenedPower(:, StageEpochs, ControlFreq), 2, 'omitnan');
chART.plot.eeglab_topoplot(TopoData, Chanlocs)
title(['ControlFreq: ', num2str(FooofFrequencies(ControlFreq), '%.1f') ' Hz'])
colorbar


% wake
StageEpochs = ismember(Scoring, 0);
Epochs = PeriodicPeaks(:, StageEpochs, :);
[isPeak, MaxPeak] = oscip.check_peak_in_band(Epochs, IotaBand, 1);

subplot(1, 3, 3)
TopoData = mean(WhitenedPower(:, StageEpochs, dsearchn(FooofFrequencies', MaxPeak(1))), 2, 'omitnan');
chART.plot.eeglab_topoplot(TopoData, Chanlocs)
title(['Wake iota: ', num2str(MaxPeak(1), '%.1f') ' Hz'])
colorbar

% TopoData = mean(WhitenedPower(:, StageEpochs, 50), 2, 'omitnan');
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


