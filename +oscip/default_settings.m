function Settings = default_settings()

Settings = struct();
Settings.Mode = 'analysis'; % options are 'analysis', or 'debug'. if debug, it will plot the distribution of periodic peaks.

%%% peak frequency detection parameters

% To detect the peak frequency within a given band, it's best to only use a
% subset of the detected peaks that have the narrowest bands for example.
Settings.PeakBandwidthMin = 0;  % select periodic peaks that have at least this bandwidth. Good for beta and gamma broad signals
Settings.PeakBandwidthMax = 2; % select periodic peaks that had at most this bandwidth (good for spindle and iota detection)
Settings.PeakAmplitudeMin = 0;

% All the periodic peaks in the signal are assembled, and the peak
% frequency is determined from the histogram of those periodic peaks. The
% following settings determine limits for which a peak van be detected in
% the distrubution of periodic peaks. 
Settings.DistributionBandwidthMin = .5; % a minimum avoids too narrow distributions, that often come from noise that have exactly the same peak frequency
Settings.DistributionBandwidthMax = 5; % too broad, and it's not specific enough
Settings.DistributionAmplitudeMin = .01; % it's a psd, so values are between 0 and 1. Too small, and it's likely just fluctuations from 0.
Settings.DistributionMinPeakDistance = .5; % Hz, peaks closer than this won't be considered

Settings.DistributionFrequencyResolution = .1; % Hz
Settings.DistributionSmoothFactor = .2; % Hz
Settings.MinPeaksInPeak = 50; % min number of peaks between the half-prominence of 