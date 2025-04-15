clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Select a file:

% SET the path of the file

EEGFilepath = 'C:\Users\lucie\Documents\Code\eeg_oscillation_analysis\eeg-oscillations\ExampleData\P09_Sleep_NightPre.mat';

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
WelchWindowLength = 4; % in seconds
WelchOverlap = .5; % 50% of the welch windows will overlap

% fooof
FooofFrequencyRange = [3 40]; % frequencies over which to fit the model
SmoothSpan = 3;
MaxError = .15;
MinRSquared = .95;

Data = EEG.data;
SampleRate = EEG.srate;
Chanlocs = EEG.chanlocs;


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

ScatterPlotDotSize = 50; % dots are sized based on periodic peak amplitude, but this scales the whole range
ScatterPlotDotTransparency = .2;
xLog = false;
yLog = false;

oscip.plot.frequency_overview(PeriodicPower, FooofFrequencies, PeriodicPeaks, ...
    Scoring, ScoringIndexes, ScoringLabels, ScatterPlotDotSize, ScatterPlotDotTransparency, xLog, yLog)

%% histogram densities

figure('Units','centimeters', 'Position',[0 0 10 10], 'Color','w')

oscip.plot.histogram_stages(Slopes(1, :), Scoring, ScoringLabels, ScoringIndexes);
xlabel('Slope')
xlim([.5 4.5])


%%
[BandByStage, PeakDetectionSettings] = oscip.peaks_by_stage(PeriodicPeaks, Scoring);


%%

Bands = BandByStage(BandByStage.Stages==1, :);

oscip.plot.band_timecourse(PeriodicPower, FooofFrequencies, EpochLength, Bands,10, Scoring, ScoringIndexes, ScoringLabels);


%%

A = tic;

[Slopes, Intercepts, FooofFrequencies, PeriodicPeaks, PeriodicPower, Errors, RSquared] ...
    = oscip.fit_fooof_multidimentional(SmoothPower, Frequencies, FooofFrequencyRange, MaxError, MinRSquared);

disp(['time to analyze: ', num2str(toc(A)/60)])


