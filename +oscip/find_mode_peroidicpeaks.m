function Peaks = find_mode_peroidicpeaks(PeriodicPeaks, Settings)
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
    Settings = oscip.default_settings();
end

% pool channels and epochs
PeakFrequencies = reshape(PeriodicPeaks(:, :, 1), [], 1);
Bandwidth = reshape(PeriodicPeaks(:, :, 3), [], 1);
Power  = reshape(PeriodicPeaks(:, :, 2), [], 1);

Frequencies = min(PeakFrequencies):Settings.DistributionFrequencyResolution:max(PeakFrequencies);

% select only peaks within given parameters
PeakFrequencies = PeakFrequencies(...
    Bandwidth >= Settings.PeakBandwidthMin & ...
    Bandwidth <= Settings.PeakBandwidthMax &...
    Power >= Settings.PeakAmplitudeMin);

if isempty(PeakFrequencies)
    Peaks = [];
    return
end

% fit smooth distribution of histogram of peak frequencies
pdca = fitdist(PeakFrequencies, 'Kernel', 'Kernel', 'normal', 'Bandwidth', Settings.DistributionFrequencyResolution*2);

DistributionPeakFrequencies = pdf(pdca, Frequencies);

% find peaks in the histogram
try
[pks, locs, w, ~] = findpeaks(DistributionPeakFrequencies, Frequencies, ...
    'MinPeakDistance', Settings.DistributionMinPeakDistance, ...
    'MinPeakHeight', Settings.DistributionAmplitudeMin, 'MinPeakProminence', Settings.DistributionAmplitudeMin, ...
    'MinPeakWidth', Settings.DistributionBandwidthMin, 'MaxPeakWidth', Settings.DistributionBandwidthMax);
catch
    warning('using try/catch on findpeaks')
    Peaks = [];
    return
end

% these are the new peaks
Peaks = [locs', pks', w'];

% TODO: minimum number of points to keep a peak

if strcmpi(Settings.Mode, 'debug')
    figure
    findpeaks(DistributionPeakFrequencies, Frequencies, ...
        'MinPeakDistance', Settings.DistributionMinPeakDistance, ...
        'MinPeakHeight', Settings.DistributionAmplitudeMin, 'MinPeakProminence', Settings.DistributionAmplitudeMin, ...
        'MinPeakWidth', Settings.DistributionBandwidthMin, 'MaxPeakWidth', Settings.DistributionBandwidthMax)

    disp([locs', pks', w']) % debug
end
end
