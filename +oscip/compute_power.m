function [Power, Frequencies] = compute_power(Data, SampleRate, WindowLength, OverlapPoints, RoundToPower2)
% [Power, Frequencies] = compute_power(Data, SampleRate, WindowLength, Overlap)
% Runs pwelch on data.
% Data is a channel x time marix matrix. SampleRate is a single value in
% Hz, WindowLength is a single value in seconds. N.B., this script will
% take the window length that is the next largest power of 2, to speed up
% the FFT. Don't be alarmed.
% Overlap is a ratio from 0 to 1.
% e.g.:  [Power, Frequencies] = compute_power(Data, fs, 4, 0.5);
% Power is a Channel x Frequency matrix.
%
% Code by Sophia Snipes, 2024, for eeg-oscillations.
arguments
    Data
    SampleRate (1, 1) {mustBePositive}
    WindowLength (1, 1) {mustBePositive} = 4;
    OverlapPoints (1, 1) {mustBeLessThanOrEqual(OverlapPoints, 1)} = .5;
    RoundToPower2 = false;
end

% set up defaults if calculation doesn't work
if RoundToPower2
    [Frequencies, nFrequencies, WindowPoints] = oscip.utils.expected_frequencies(WindowLength, SampleRate);
    BlankPower = nan(size(Data, 1), nFrequencies);
else
    WindowPoints = SampleRate*WindowLength;
    nFrequencies = floor(WindowPoints/2) + 1;
    Frequencies = linspace(0, SampleRate/2, nFrequencies);
    BlankPower = nan(size(Data, 1), nFrequencies);
end

% remove any NaN values in time
Data(:, isnan(sum(Data, 1))) = [];

% check if there's enough data
if size(Data, 2) < WindowLength*SampleRate
    warning('not enough data')
    Power = BlankPower;
    return
elseif size(Data,2)<WindowPoints
    WindowPoints = size(Data, 2);
end

% FFT
OverlapPoints = round(WindowPoints*OverlapPoints);
Window = hanning(WindowPoints);

[Power, Frequencies] = pwelch(Data', Window, OverlapPoints, WindowPoints, SampleRate);
Power = Power';
Frequencies = Frequencies';



