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
WelchWindowLength = 1; % in seconds
WelchOverlap = .5; % 50% of the welch windows will overlap

% fooof
FooofFrequencyRange = [3 40]; % frequencies over which to fit the model
SmoothSpan = 3;
MaxError = .15;
MinRSquared = .95;

% specific oscillation detection
Band = [25 37]; % some participants were just at the edge of 35 Hz, but 38 Hz theres a weird artefact
BandwidthMax = 4; % broader peaks are not oscillations
BandwidthMin = .5; % Hz; narrow peaks are more often than not noise
PeakAmplitudeThreshold = .5;
FrequencyResolution = .25; % this determines the smoothness of the curves, at the cost of frequency resolution
DistributionAmplitudeMin = .01; % this just excludes stupid small peaks


% plot parameters
ScatterSizeScaling = 50;
Alpha = .1;

% locations
% DataFolder = 'E:\Data\Examples Inhibition Reticular thalamus';
% ChannelsToKeep = 1:4;
DataFolder = 'D:\Data\AlejoMouseSD';
ChannelsToKeep = [1 2 5 6];

% stages
StageLabels = {'W', 'R', 'NR'};
StageIndexes = {0, 1, -1};
EpochLength = 8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% run

Files = oscip.list_filenames(DataFolder);

%%% identify main oscillations in each recording
HasIota = table();
for FileIdx = 1:numel(Files)
    load(fullfile(DataFolder, Files(FileIdx)), 'traces', 'b', 'traceName')
    SampleRate = 200;
    Data = traces(ChannelsToKeep, :);
    traceName = traceName(ChannelsToKeep);
    EEG = struct();
    EEG.data = Data;
    EEG.srate = 1000;

    EEG.chanlocs = [];
    EEG.xmax = size(traces, 2)/EEG.srate;
    EEG.xmin = 0;
    EEG.trials = 1;
    EEG.pnts = size(traces, 2);
    EEG.nbchan = 4;
    EEG.event = [];
    EEG.setname = '';
    EEG.icasphere = '';
    EEG.icaweights = '';
    EEG.icawinv = '';


    Data = pop_resample(EEG, 200);
    Data = Data.data;

    % calculate power
    [EpochPower, Frequencies] = oscip.compute_power_on_epochs(Data, ...
        SampleRate, EpochLength, WelchWindowLength, WelchOverlap);

    
    [Scoring, ScoringIndexes, ScoringLabels] = oscip.convert_animal_scoring(b, size(EpochPower, 2), EpochLength, 4);

    SmoothPower = oscip.smooth_spectrum(EpochPower, Frequencies, SmoothSpan); % better for fooof if the spectra are smooth

    % run FOOOF
    [Slopes, Intercepts, FooofFrequencies, PeriodicPeaks, WhitenedPower, Errors, RSquared] ...
        = oscip.fit_fooof_multidimentional(SmoothPower, Frequencies, FooofFrequencyRange, MaxError, MinRSquared);

    % identify iota for each stage
    for StageIdx = 1:numel(StageLabels)
        StageEpochs = ismember(Scoring, StageIndexes{StageIdx});
        Epochs = PeriodicPeaks(:, StageEpochs, :);
        if isempty(Epochs)
            HasIota.([StageLabels{StageIdx}, '_Iota'])(FileIdx) = nan;
            continue
        end
        [isPeak, MaxPeak] = oscip.check_peak_in_band(Epochs, ...
            Band, 1, BandwidthMax, PeakAmplitudeThreshold, BandwidthMin, DistributionAmplitudeMin, FrequencyResolution);

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
        oscip.plot.temporal_overview(squeeze(mean(WhitenedPower,1)), ...
            FooofFrequencies, EpochLength, Scoring, ScoringIndexes, ScoringLabels, Slopes, [], [], Title)

        Channels = [1:2];
        oscip.plot.frequency_overview(SmoothPower(Channels, :, :), Frequencies, PeriodicPeaks(Channels, :, :), ...
            Scoring, ScoringIndexes, ScoringLabels, ScatterSizeScaling, Alpha, true, true)
        title(Title)


        figure('Units','centimeters', 'Position',[0 0 10 30], 'Color','w')
        for ChannelIdx = 1:size(Slopes, 1)
            subplot(4, 1, ChannelIdx)
            oscip.plot.histogram_stages(Slopes(ChannelIdx, :), Scoring, ScoringLabels, ScoringIndexes); title(traceName(ChannelIdx))
            xlim([0 3.5])
        end
    end
end


disp(HasIota)
