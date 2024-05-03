function AveragePeaks = average_peaks_in_range(PeriodicPeaks, Range)
% AveragePeaks is a 1 x 3 matrix of Frequency, Amplitude, and Bandwidth.

F= PeriodicPeaks(:, :, 1);
F = F(:);

P = PeriodicPeaks(:, :, 2);
P = P(:);
BW = PeriodicPeaks(:, :, 3);
BW = BW(:);

AveragePeaks(1) = mean(F(F>=Range(1)&F<=Range(2)));
AveragePeaks(2) = mean(P(F>=Range(1)&F<=Range(2)));
AveragePeaks(3) = mean(BW(F>=Range(1)&F<=Range(2)));