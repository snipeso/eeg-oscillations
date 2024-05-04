% Runs the code on animal data (from A. Osorio-Forero). This repo does not include the data, you'll need to have your own. Sorry :/
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
ChannelsToPlot = [1:2];

% stages
StageLabels = {'W', 'R', 'NR'};
StageIndexes = {0, 1, -1};
EpochLength = 8; % Can be as low as 4, or as high as you want. Should be multiple of 4.
    NewSampleRate = 200;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% run

Files = oscip.list_filenames(DataFolder);

%%% identify main oscillations in each recording
for FileIdx = 1:numel(Files)
    load(fullfile(DataFolder, Files(FileIdx)), 'traces', 'b', 'traceName')
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
    EEG.nbchan = size(Data, 1);
    EEG.event = [];
    EEG.setname = '';
    EEG.icasphere = '';
    EEG.icaweights = '';
    EEG.icawinv = '';

    % downsample to decent values
    Data = pop_resample(EEG, 200);
    Data = Data.data;

    % calculate power
    [EpochPower, Frequencies] = oscip.compute_power_on_epochs(Data, ...
        NewSampleRate, EpochLength, WelchWindowLength, WelchOverlap);

    % select most common score for each epoch (when new epoch is larger
    % than old)
    [Scoring, ScoringIndexes, ScoringLabels] = oscip.convert_animal_scoring(b, size(EpochPower, 2), EpochLength, 4);

    SmoothPower = oscip.smooth_spectrum(EpochPower, Frequencies, SmoothSpan); % better for fooof if the spectra are smooth

    % run FOOOF
    [Slopes, Intercepts, FooofFrequencies, PeriodicPeaks, WhitenedPower, Errors, RSquared] ...
        = oscip.fit_fooof_multidimentional(SmoothPower, Frequencies, FooofFrequencyRange, MaxError, MinRSquared);
    
    % plot
    if PlotIndividuals
        Title = replace(replace(Files(FileIdx), '.mat', ''), '_', ' ');
        oscip.plot.temporal_overview(squeeze(mean(WhitenedPower,1)), ...
            FooofFrequencies, EpochLength, Scoring, ScoringIndexes, ScoringLabels, Slopes, [], [], Title)

        oscip.plot.frequency_overview(SmoothPower(ChannelsToPlot, :, :), Frequencies, PeriodicPeaks(ChannelsToPlot, :, :), ...
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
