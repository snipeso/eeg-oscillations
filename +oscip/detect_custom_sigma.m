function [SlowSigma, FastSigma] = detect_custom_sigma(PeriodicPeaks, BandwidthThreshold, PeakAmplitudeThreshold, DistributionAmplitudeThreshold, FrequencyResolution, Band)
% detects slow and fast sigma peak for each participant
arguments
    PeriodicPeaks
    BandwidthThreshold = 2;
    PeakAmplitudeThreshold = 0;
    DistributionAmplitudeThreshold = .01;
    FrequencyResolution = .25;
    Band = [9 18]; % Hz
end

nPeaks = 2;
FrequencySplit = 12; % frequency above which it conventionally counts as fast spindles

Peaks = oscip.find_mode_peroidicpeaks(PeriodicPeaks, BandwidthThreshold, ...
    PeakAmplitudeThreshold, DistributionAmplitudeThreshold, FrequencyResolution);

MaxPeaks = oscip.select_max_peak(Peaks, Band, nPeaks);

if isempty(MaxPeaks) || any(isnan(MaxPeaks(:)))
    SlowSigma = nan(1, 3);
    FastSigma = nan(1, 3);
    return
end

if size(MaxPeaks, 1) == 1 && MaxPeaks(1)<=FrequencySplit % only slow spindles
    MaxPeaks = cat(1, MaxPeaks, nan(1, 3));
elseif  size(MaxPeaks, 1) == 1 && MaxPeaks(1)>FrequencySplit % only fast spindles
    MaxPeaks = cat(1, nan(1, 3), MaxPeaks);
elseif size(MaxPeaks, 1) > 2
    error('too many max peaks')
end


% identify average power and bandwidth for the chosen peak frequency
for SigmaIdx = 1:2
    Range = MaxPeaks(SigmaIdx, 1)+[-MaxPeaks(SigmaIdx, 3), MaxPeaks(SigmaIdx, 3)]/2;
    AveragePeaks = oscip.average_peaks_in_range(PeriodicPeaks, Range);
    MaxPeaks(SigmaIdx, 2) = AveragePeaks(2);
    MaxPeaks(SigmaIdx, 3) = AveragePeaks(3);
end

SlowSigma = MaxPeaks(1, :);
FastSigma = MaxPeaks(2, :);
end