function FooofFrequencies = expected_fooof_frequencies(Frequencies, FittingFrequencyRange)
% FooofFrequencies = expected_fooof_frequencies(Frequencies, FittingFrequencyRange)
% preallocates frequencies that the fooof algorithm will outout.
%
% Code by Sophia Snipes, 2024, for eeg-oscillations.

Start = find(Frequencies>=FittingFrequencyRange(1), 1, 'first');
End = find(Frequencies<=FittingFrequencyRange(2), 1, 'last');
FooofFrequencies = Frequencies(Start:End);
