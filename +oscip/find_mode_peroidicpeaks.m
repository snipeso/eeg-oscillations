function Peaks = find_mode_peroidicpeaks(PeriodicPeaks, BandwidthThreshold, ...
    PeakAmplitudeThreshold, DistributionAmplitudeThreshold, FrequencyResolution, MinPeakDistance)
% From a whole bunch of periodic peaks, it fits a smooth distribution,
% finds the peaks in this distribution, and identifies those as the main
% frequencies in that signal.
% PeriodicPeaks is a channel x epoch x 3 matrix.
% BandWidthThreshold is the maximum bandwidth to consider. By having a
% maximum, it avoids considering periodic peaks that come from two
% neighboring frequencies that largely overlap. 
% FrequencyResolution is for identifying the resolution of the peaks.
% MinPeakDistance is the minimum frequency difference between peaks.
% Peaks is a N x 3 matrix, with the first column indicating the center
% frequency, the second column the amplitude (
%
% Code by Sophia Snipes, 2024, for eeg-oscillations.
arguments
    PeriodicPeaks
    BandwidthThreshold = 4;
    PeakAmplitudeThreshold = 0;
    DistributionAmplitudeThreshold = .01;
    FrequencyResolution = .25; % Hx
    MinPeakDistance = 1; % Hz
end

% pool channels and epochs
PeakFrequencies = reshape(PeriodicPeaks(:, :, 1), [], 1);
Bandwidth = reshape(PeriodicPeaks(:, :, 3), [], 1);
Power  = reshape(PeriodicPeaks(:, :, 2), [], 1);

% fit smooth distribution of histogram of peak frequencies
Frequencies = min(PeakFrequencies):FrequencyResolution:max(PeakFrequencies);

pdca = fitdist(PeakFrequencies(Bandwidth<=BandwidthThreshold & Power>PeakAmplitudeThreshold), 'Kernel');
DistributionPeakFrequencies = pdf(pdca, Frequencies);

% find peaks in the histogram
[pks, locs, w] = findpeaks(DistributionPeakFrequencies, Frequencies, ...
    'MinPeakDistance', MinPeakDistance, 'MinPeakHeight', DistributionAmplitudeThreshold);

% these are the new peaks
Peaks = [locs', pks', w'];
end