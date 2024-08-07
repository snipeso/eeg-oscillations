function [EpochPower, Frequencies] = compute_power_on_epochs(Data, SampleRate, EpochLength, WelchWindowLength, WelchOverlap)
%  [Power, Frequencies] = compute_power_on_epochs(Data, SampleRate, EpochLength, WelchWindowLength, Overlap)
% Data is a channel x time matrix.
% SampleRate is a single value in Hz.
% EpochLength is a single value in seconds indicating how long each epoch
% should be.
% WelchWindowlength indicates the window over which the pwelch function should
% calculate power for each epoch, and should be less than or equal to the
% epoch length.
% WelchOverlap is a single value from 0 to 1 indicating how much the pwelch
% windows should overlap when calculating power.
%
% Code by Sophia Snipes, 2024, for eeg-oscillations.
arguments
    Data
    SampleRate (1, 1) {mustBePositive}
    EpochLength = 30;
    WelchWindowLength (1, 1) {mustBePositive} = 4;
    WelchOverlap (1, 1) {mustBeLessThanOrEqual(WelchOverlap, 1)} = .5;
end

% set up epoch information
[nChannels, nTimepoints] = size(Data);
ScoringTime = round(1:EpochLength*SampleRate:nTimepoints); % rounded so it can be indexes
Starts = ScoringTime(1:end-1);
Ends = ScoringTime(2:end)-1;
nEpochs = numel(Starts);

[Frequencies, nFrequencies] = oscip.utils.expected_frequencies(WelchWindowLength, SampleRate);


EpochPower = nan(nChannels, nEpochs, nFrequencies);
for EpochIdx = 1:nEpochs

    % select epoch of data
    EpochData = Data(:, Starts(EpochIdx):Ends(EpochIdx));

    % compute power
    [Power, Frequencies] = oscip.compute_power(EpochData, SampleRate, WelchWindowLength, WelchOverlap);
    EpochPower(:, EpochIdx, :) = Power;
end
