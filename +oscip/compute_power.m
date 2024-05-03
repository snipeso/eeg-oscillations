function [Power, Frequencies] = compute_power(Data, SampleRate, WindowLength, OverlapPoints)
% [Power, Frequencies] = compute_power(Data, SampleRate, WindowLength, Overlap)
% Runs pwelch on data.
% Data is a channel x time marix matrix. SampleRate is a single value in
% Hz, WindowLength is a single value in seconds. N.B., this script will
% take the window length that is the next largest power of 2, to speed up
% the FFT. Don't be alarmed.
% Overlap is a ratio from 0 to 1.
% e.g.:  [Power, Frequencies] = compute_power(Data, fs, 4, 0.5);
% Power is a Channel x Frequency matrix.
% Code by Sophia Snipes, 2024, for eeg-oscillations.
arguments
    Data
    SampleRate (1, 1) {mustBePositive}
    WindowLength (1, 1) {mustBePositive} = 4;
    OverlapPoints (1, 1) {mustBeLessThanOrEqual(OverlapPoints, 1)} = .5;
end

% set up defaults if calculation doesn't work
 [Frequencies, nFrequencies, WindowPoints] = oscip.utils.expected_frequencies(WindowLength, SampleRate);
 BlankPower = nan(size(Data, 1), nFrequencies);


% remove any NaN values in time
Data(:, isnan(sum(Data, 1))) = [];

% check if there's enough data
if size(Data, 2) < WindowLength*SampleRate
    warning('not enough data')
    Power = BlankPower;
    return
end

% FFT
OverlapPoints = round(WindowPoints*OverlapPoints);
Window = hanning(WindowPoints);

[Power, Frequencies] = pwelch(Data', Window, OverlapPoints, WindowPoints, SampleRate);
Power = Power';
Frequencies = Frequencies';



