function [Frequencies, nFrequencies, WindowPoints] = expected_frequencies(WelchWindowLength, SampleRate)
% pre-allocates the frequency array that "compute_power.m" will calculate

% round up 
WindowPoints = 2^nextpow2(WelchWindowLength*SampleRate); % also refered to as nfft
nFrequencies = WindowPoints/2 + 1;
Frequencies = linspace(0, SampleRate/2, nFrequencies);