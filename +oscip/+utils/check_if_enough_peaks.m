function Peaks = check_if_enough_peaks(Peaks, PeriodicPeaks, Settings)
% check if there's actually a good number of data points that contributed
% to the peak detected in the signal.

% flatten center frequencies of periodic peaks, ignoring channels vs epochs
Frequencies = PeriodicPeaks(:, :, 1);
Frequencies = Frequencies(:);

nPeaks = nan(size(Peaks, 1), 1);
for PeakIdx = 1:size(Peaks, 1)

    % identify range of each peak
    Min = Peaks(PeakIdx, 1) - Peaks(PeakIdx, 3)/2;
    Max = Peaks(PeakIdx, 1) + Peaks(PeakIdx, 3)/2;
    
    % count how many peaks were in that range
    nPeaks(PeakIdx) = nnz(Frequencies>=Min & Frequencies<=Max);

end

% remove any peaks that were too fiew
Peaks(nPeaks<Settings.MinPeaksInPeak, :) = [];