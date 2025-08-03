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
WelchWindowLength = 8; % in seconds
WelchOverlap = .5; % 50% of the welch windows will overlap

% fooof
FooofFrequencyRange = [3 40]; % frequencies over which to fit the model
SmoothSpan = 3;
MaxError = .18;
MinRSquared = .96;
Refresh = false;

% plot parameters
ScatterSizeScaling = 20;
Alpha = .1;
NewEpochLength = 20;
OldEpochLength = 20;

% locations
DataFolder = 'D:\Data\SophiaHoomans';
Destination = fullfile(DataFolder, 'Results_SleepOnset');
if ~exist(Destination, 'dir')
    mkdir(Destination)
end


% time to keep
TimeToKeep = [0.0001 60*60*2]; % in seconds
ScoringIndexes = -3:1;
ScoringLabels = {'N3', 'N2', 'N1', 'W', 'R'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% run

Files = oscip.list_filenames(DataFolder);

%%% identify main oscillations in each recording
for FileIdx = 1:numel(Files)

    File = Files(FileIdx);

    if exist(fullfile(Destination, File), 'file') && ~Refresh
        load(fullfile(Destination, File))
    else
        load(fullfile(DataFolder, File), 'EEG', 'visnum')
        SampleRate = EEG.srate;
        KeepPoints = ceil(TimeToKeep(1)*SampleRate):floor(TimeToKeep(2)*SampleRate);
        Data = EEG.data;

        Scoring = visnum;
        Scoring(Scoring==1) = 2;
        Scoring(Scoring==0) = 1;
        Scoring(Scoring==2) = 0;
        Scoring(end+1) = nan;
        ScoringInTime = oscip.utils.scoring2time(Scoring, NewEpochLength, SampleRate, size(EEG.data, 2));
        Data = Data(:, ScoringInTime~=1);
        Data = Data(:, KeepPoints);


        % calculate power
        [EpochPower, Frequencies] = oscip.compute_power_on_epochs(Data, ...
            SampleRate, NewEpochLength, WelchWindowLength, WelchOverlap);

        SmoothPower = oscip.smooth_spectrum(EpochPower, Frequencies, SmoothSpan); % better for fooof if the spectra are smooth

        % run FOOOF
        [Exponents, Offsets, FrequenciesPeriodic, PeriodicPeaks, PeriodicPower, Errors, RSquared] ...
            = oscip.fit_fooof_multidimentional(SmoothPower, Frequencies, FooofFrequencyRange, MaxError, MinRSquared);

        save(fullfile(Destination, File), 'EEG',  'ScoringInTime', 'ScoringIndexes', 'ScoringLabels', ...
            'SmoothPower', 'Frequencies', 'Exponents', 'Offsets', ...
            'FrequenciesPeriodic', 'PeriodicPeaks', 'PeriodicPower', 'Errors','RSquared')
    end

    
    % plot
    if PlotIndividuals
        Title = replace(replace(File, '.mat', ''), '_', ' ');
        FigureTitle = char(extractBefore(File, '.mat'));
        oscip.plot.temporal_overview(squeeze(mean(PeriodicPower,1)), ...
            FrequenciesPeriodic, NewEpochLength, zeros(size(PeriodicPower, 2)), ScoringIndexes, ScoringLabels, Exponents, [], [], Title)
        set(gcf, 'InvertHardcopy', 'off', 'Color', 'w')
        print(fullfile(Destination, [FigureTitle, '_time']), '-dtiff', '-r1000')
      
        oscip.plot.peaks_by_exponent(PeriodicPeaks, Exponents, NewEpochLength, Title, 50, .1, flip(chART.external.colorcet('I3')))
        set(gcf, 'InvertHardcopy', 'off', 'Color', 'w')
        print(fullfile(Destination, [FigureTitle, '_Exponents']), '-dtiff', '-r1000')
    end
end
