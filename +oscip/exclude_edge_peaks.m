function PeriodicPeaks = exclude_edge_peaks(PeriodicPeaks, FittingFrequencyRange)
% This identifies any periodic peaks (nPeaks x 3; TODO: any dimention) that
% have a peak frequency + bandwidth/2 that overlaps with either edges of
% the fitting range. Do this when the aperiodic signal curves at the edges
% in unwanted ways. 

if isempty(PeriodicPeaks)
    return
end

Bandwidth = (PeriodicPeaks(:, 3)./2);

PeriodicPeaksMin = PeriodicPeaks(:, 1)-Bandwidth;
PeriodicPeaksMax = PeriodicPeaks(:, 1)+Bandwidth;

Remove = PeriodicPeaksMin<FittingFrequencyRange(1) | ...
    PeriodicPeaksMax > FittingFrequencyRange(2);

PeriodicPeaks(Remove, :) = [];