function [Distribution, Frequencies] = peaks_distribution(PeriodicPeaks, FrequencyRange, Settings)
% creates a smooth distribution of all the peaks in PeriodicPeaks. Useful
% for finding the peak frequency, and for plotting.
% code by Sophia Snipes, 2024, eeg-oscillations.
arguments
    PeriodicPeaks
    FrequencyRange = 'minmax';
    Settings = oscip.default_settings();
end


% pool channels and epochs
PeakFrequencies = reshape(PeriodicPeaks(:, :, 1), [], 1);
Bandwidth = reshape(PeriodicPeaks(:, :, 3), [], 1);
Power  = reshape(PeriodicPeaks(:, :, 2), [], 1);

if ischar(FrequencyRange) && strcmp(FrequencyRange, 'minmax')
    Frequencies = min(PeakFrequencies):Settings.DistributionFrequencyResolution:max(PeakFrequencies);
else
    Frequencies = FrequencyRange(1):Settings.DistributionFrequencyResolution:FrequencyRange(2);
end

% select only peaks within given parameters
PeakFrequencies = PeakFrequencies(...
    Bandwidth >= Settings.PeakBandwidthMin & ...
    Bandwidth <= Settings.PeakBandwidthMax &...
    Power >= Settings.PeakAmplitudeMin);

if isempty(PeakFrequencies)
    Distribution = [];
    return
end

% fit smooth distribution of histogram of peak frequencies
pdca = fitdist(PeakFrequencies, 'Kernel', 'Kernel', 'normal', 'Bandwidth', Settings.DistributionFrequencyResolution*2);
Distribution = pdf(pdca, Frequencies);