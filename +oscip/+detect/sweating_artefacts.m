function Artefacts = sweating_artefacts(Power, Frequencies, MinEEGFrequency)
arguments
    Power % epoch power, data can't be high-pass filtered
    Frequencies
    MinEEGFrequency = 0.5;
end

Power = log10(Power);

MaxSweatFrequencyIndex = find(Frequencies>MinEEGFrequency, 1, 'first')-1;
LowPower = Power(:, :, 1:MaxSweatFrequencyIndex);

Median = median(LowPower,  1, 'omitnan');

Diff = LowPower - Median;
STD = mad(Diff, 1, 1);

Threshold = Median + 5*STD;

Artefacts = all(LowPower > Threshold, 3);
end