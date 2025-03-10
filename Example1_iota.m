% Example script: determine if there is a iota oscillation during either
% wake or sleep. Starts from raw or minimally processed data.
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
Band = [25 37]; % some participants were just at the edge of 35 Hz, but 38 Hz theres a weird artefact


PeakDetectionSettings = oscip.default_settings();
PeakDetectionSettings.PeakBandwidthMax = 4; % broader peaks are not oscillations
PeakDetectionSettings.PeakBandwidthMin = .5; % Hz; narrow peaks are more often than not noise
% PeakDetectionSettings.PeakAmplitudeMin = .5;


% plot parameters
ScatterSizeScaling = 50;
Alpha = .1;

% locations
CD = extractBefore(mfilename('fullpath'), 'Example'); % finds folder this script is saved in
DataFolder = fullfile(CD, 'ExampleData');

% stages
StageLabels = {'W', 'R', 'NR'};
StageIndexes = {0, 1, [-2, -3]};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% run

Files = oscip.list_filenames(DataFolder);

%%% identify main oscillations in each recording
HasIota = table();
for FileIdx = 3:numel(Files)
    tic
    load(fullfile(DataFolder, Files(FileIdx)), 'EEG', ...
        'EpochLength', 'Scoring', 'ScoringIndexes', 'ScoringLabels')
    SampleRate = EEG.srate;
    Data = EEG.data;

    % calculate power
    [EpochPower, Frequencies] = oscip.compute_power_on_epochs(Data, ...
        SampleRate, EpochLength, WelchWindowLength, WelchOverlap);

    SmoothPower = oscip.smooth_spectrum(EpochPower, Frequencies, SmoothSpan); % better for fooof if the spectra are smooth

    % run FOOOF
    [Slopes, Intercepts, FooofFrequencies, PeriodicPeaks, PeriodicPower, Errors, RSquared] ...
        = oscip.fit_fooof_multidimentional(SmoothPower, Frequencies, FooofFrequencyRange, MaxError, MinRSquared);

    % identify iota for each stage
    for StageIdx = 1:numel(StageLabels)
        StageEpochs = ismember(Scoring, StageIndexes{StageIdx});
        Epochs = PeriodicPeaks(:, StageEpochs, :);
        if isempty(Epochs)
            HasIota.([StageLabels{StageIdx}, '_Iota'])(FileIdx) = nan;
            continue
        end
        [isPeak, MaxPeak] = oscip.check_peak_in_band(Epochs, Band, 1, PeakDetectionSettings);

        HasIota.File(FileIdx) = Files(FileIdx);

        % save to table
        if isPeak
            HasIota.([StageLabels{StageIdx}, '_Iota'])(FileIdx) = MaxPeak(1);
        else
            HasIota.([StageLabels{StageIdx}, '_Iota'])(FileIdx) = nan;
        end
    end

    % plot
    if PlotIndividuals
        Title = replace(replace(Files(FileIdx), '.mat', ''), '_', ' ');
        oscip.plot.temporal_overview(squeeze(mean(PeriodicPower,1)), ...
            FooofFrequencies, EpochLength, Scoring, ScoringIndexes, ScoringLabels, Slopes, [], [], Title)

        oscip.plot.frequency_overview(SmoothPower, Frequencies, PeriodicPeaks, ...
            Scoring, ScoringIndexes, ScoringLabels, ScatterSizeScaling, Alpha)
        toc
        title(Title)
    end
end


disp(HasIota)
