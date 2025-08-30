function Peak = find_closest_peak(Power, Frequencies, TargetFrequency, MinProminence)
arguments
    Power
    Frequencies
    TargetFrequency
    MinProminence = .01
end

PeriodicPeaks = oscip.utils.findpeaks_matlab(Power, Frequencies, []);

PeriodicPeaks(PeriodicPeaks(:, 4)<MinProminence, :) = [];

Idx = dsearchn(PeriodicPeaks(:, 1), TargetFrequency);

Peak = PeriodicPeaks(Idx, :);