function [isPeak, MaxPeak] = check_peak_in_band(PeriodicPeaks, Band, nPeaks, Settings)
%  [isPeak, MaxPeak] = check_peak_in_band(PeriodicPeaks, Band, nPeaks, Settings)
% checks if there was a periodic peak within a specified band that means
% all the thresholds.
% Outputs:
% isPeak is a boolean.
% MaxPeak is a 1 x 3 matrix of frequency, amplitude, and bandwidth.
%
% Inputs:
% PeriodicPeaks is Channel x Epoch x 3 matrix.
% Band is a 1 x 2 matrix (e.g. [4 8]).
% nPeaks is the number of peaks you want to find in the band. Normally
% just 1, but if looking at sigma, better 2.
arguments
    PeriodicPeaks
    Band
    nPeaks = 2;
    Settings = oscip.default_settings();
end

Peaks = oscip.find_mode_peroidicpeaks(PeriodicPeaks, Settings);

MaxPeak = oscip.select_max_peak(Peaks, Band, nPeaks);

if ~isempty(MaxPeak) && ~any(isnan(MaxPeak))
    isPeak = true;

    % identify average power and bandwidth for the chosen peak frequency
    Range = MaxPeak(1)+[-MaxPeak(3), MaxPeak(3)]/2;
    AveragePeaks = oscip.average_peaks_in_range(PeriodicPeaks, Range);
    MaxPeak(2) = AveragePeaks(2);
    MaxPeak(3) = AveragePeaks(3);
else
    isPeak = false;
    MaxPeak = nan(1, 3);
    MaxPeak(2) = 0;
end