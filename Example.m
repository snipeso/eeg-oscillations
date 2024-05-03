% Example script: determine if there is a iota oscillation during either
% wake or NREM sleep
clear
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% setup

% choose what to do
PlotIndividuals = true;

% analysis parameters
WelchWindowLength = 4; % in seconds
WelchOverlap = .5; % 50% of the welch windows will overlap
FooofFrequencyRange = [3 40]; % frequencies over which to fit the model


% locations
CD = extractBefore(mfilename('fullpath'), 'Example'); % finds folder this script is saved in
DataFolder = fullfile(CD, 'ExampleData');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% run

Files = oscip.list_filenames(DataFolder);

%%% identify main oscillations in each recording
for FileIdx = 1:numel(Files)
    load(fullfile(DataFolder, Files(FileIdx)), 'EEG', ...
        'EpochLength', 'Scoring', 'ScoringIndexes', 'ScoringLabels')
    SampleRate = EEG.srate;
    Data = EEG.data;

    % calculate power
    [EpochPower, Frequencies] = oscip.compute_power_on_epochs(Data, ...
        SampleRate, EpochLength, WelchWindowLength, WelchOverlap);

    % run FOOOF

    % identify most frequent peaks


    % plot


    % save to table
end

