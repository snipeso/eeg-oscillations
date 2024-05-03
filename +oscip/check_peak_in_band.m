function [isPeak, MaxPeak] = check_peak_in_band(PeriodicPeaks, Band, nPeaks, BandwidthThreshold, PeakAmplitudeThreshold, DistributionAmplitudeThreshold, FrequencyResolution)
%  [isPeak, MaxPeak] = check_peak_in_band(PeriodicPeaks, Band, nPeaks, BandwidthThreshold, PeakAmplitudeThreshold, DistributionAmplitudeThreshold, FrequencyResolution)
% checks if there was a periodic peak within a specified band that means
% all the thresholds.
% Outputs:
% isPeak is a boolean.
% MaxPeak is a 1 x 3 matrix of frequency, amplitude, and bandwidth.
%
% Inputs:
% PeriodicPeaks is Channel x Epoch x 3 matrix.
% Band is a 1 x 2 matrix (e.g. [4 8]).
% BandPeaks is the number of peaks you want to find in the band. Normally
% just 1, but if looking at sigma, better 2.
% BandWidthThreshold is a single value from 1 to 12 (or maximum available
% in fooof).
% FrequencyResolution is self-explanatory. Should relate to the frequency
% resolution of the power analysis.
arguments
    PeriodicPeaks
    Band
    nPeaks = 2;
    BandwidthThreshold = 2;
    PeakAmplitudeThreshold = 0;
    DistributionAmplitudeThreshold = .01;
    FrequencyResolution = .25;
end

Peaks = oscip.find_mode_peroidicpeaks(PeriodicPeaks, BandwidthThreshold, ...
    PeakAmplitudeThreshold, DistributionAmplitudeThreshold, FrequencyResolution);

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