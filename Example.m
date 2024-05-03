% Example script: determine if there is a iota oscillation during either
% wake or NREM sleep

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% setup

% choose what to do
PlotIndividuals = true;

% analysis parameters
FooofFrequencyRange = [3 40]; % frequencies over which to fit the model


% locations
CD = extractBefore(Paths.Analysis, mfilename('fullpath'), 'Example'); % finds folder this script is saved in
DataFolder = fullfile(CD, 'ExampleData');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% run



%%% identify main oscillations in the signal


