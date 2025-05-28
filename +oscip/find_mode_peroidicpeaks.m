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

FrequencyRange = 'minmax';

[DistributionPeakFrequencies, Frequencies] = oscip.utils.peaks_distribution(PeriodicPeaks, FrequencyRange, Settings);
if isempty(DistributionPeakFrequencies)
    Peaks = [];
    return
end

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

% remove peaks that were based on too few datapoints
Peaks = oscip.utils.check_if_enough_peaks(Peaks, PeriodicPeaks, Settings);

if strcmpi(Settings.Mode, 'debug')
    figure
    findpeaks(DistributionPeakFrequencies, Frequencies, ...
        'MinPeakDistance', Settings.DistributionMinPeakDistance, ...
        'MinPeakHeight', Settings.DistributionAmplitudeMin, 'MinPeakProminence', Settings.DistributionAmplitudeMin, ...
        'MinPeakWidth', Settings.DistributionBandwidthMin, 'MaxPeakWidth', Settings.DistributionBandwidthMax)

    disp([locs', pks', w']) % debug
end
end
