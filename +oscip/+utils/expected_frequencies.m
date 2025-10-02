function [Frequencies, nFrequencies, WindowPoints] = expected_frequencies(WelchWindowLength, SampleRate, RoundToPower2)
% pre-allocates the frequency array that "compute_power.m" will calculate
arguments
    WelchWindowLength
    SampleRate
    RoundToPower2 = false;
end

% round up
if RoundToPower2
    WindowPoints = 2^nextpow2(WelchWindowLength*SampleRate); % also refered to as nfft
    nFrequencies = WindowPoints/2 + 1;
else
    WindowPoints = SampleRate*WelchWindowLength;
    nFrequencies = floor(WindowPoints/2) + 1;
end

Frequencies = linspace(0, SampleRate/2, nFrequencies);