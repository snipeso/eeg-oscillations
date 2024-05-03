function Peaks = find_mode_peroidicpeaks(PeriodicPeaks, BandwidthMax, ...
    PeakAmplitudeThreshold, DistributionBandwidthMin, DistributionAmplitudeMin, ...
    FrequencyResolution, MinPeakDistance)
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
    BandwidthMax = 4;
    PeakAmplitudeThreshold = 0;
    DistributionBandwidthMin = .5;
    DistributionAmplitudeMin = .01;
    FrequencyResolution = .25; % Hx
    MinPeakDistance = 1; % Hz
end

% pool channels and epochs
PeakFrequencies = reshape(PeriodicPeaks(:, :, 1), [], 1);
Bandwidth = reshape(PeriodicPeaks(:, :, 3), [], 1);
Power  = reshape(PeriodicPeaks(:, :, 2), [], 1);

% fit smooth distribution of histogram of peak frequencies
Frequencies = min(PeakFrequencies):FrequencyResolution:max(PeakFrequencies);


%%
pdca = fitdist(PeakFrequencies(Bandwidth<=BandwidthMax & Power>PeakAmplitudeThreshold), 'Kernel', 'Kernel','normal', 'Bandwidth', FrequencyResolution*2);
DistributionPeakFrequencies = pdf(pdca, Frequencies);
figure % DEBUG
findpeaks(DistributionPeakFrequencies, Frequencies, ...
    'MinPeakDistance', MinPeakDistance, 'Annotate', 'extents', ...
    'MinPeakHeight', DistributionAmplitudeMin, 'MaxPeakWidth', BandwidthMax)
%%
% find peaks in the histogram
[pks, locs, w, ~] = findpeaks(DistributionPeakFrequencies, Frequencies, ...
    'MinPeakDistance', MinPeakDistance, ...
    'MinPeakHeight', DistributionAmplitudeMin, 'MinPeakProminence', DistributionAmplitudeMin, ...
    'MinPeakWidth',DistributionBandwidthMin, 'MaxPeakWidth', BandwidthMax);

% these are the new peaks
% Peaks = [locs', pks', w', p'] % debug
Peaks = [locs', pks', w']; 
end