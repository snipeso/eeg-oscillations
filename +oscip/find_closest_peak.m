function Peak = find_closest_peak(Power, Frequencies, TargetFrequency)

PeriodicPeaks = oscip.utils.findpeaks_matlab(Power, Frequencies, []);

Idx = dsearchn(PeriodicPeaks(:, 1), TargetFrequency);

Peak = PeriodicPeaks(Idx, :);