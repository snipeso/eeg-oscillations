function frequency_overview(Power, Frequencies, PeriodicPeaks, Scoring, ScoringIndexes, ScoringLabels, ScatterSizeScaling, Alpha)
% Power is a channel x epoch x time matrix.

figure('Units','centimeters', 'Position',[0 0 20 10], 'Color','w')

subplot(1, 2, 1)
oscip.plot.scoring_spectra(squeeze(mean(Power, 1, 'omitnan')), Frequencies, ...
    Scoring, ScoringIndexes, ScoringLabels, false, true)
xlim([3 40])

subplot(1, 2, 2)
oscip.plot.periodic_peaks(PeriodicPeaks, Scoring, ScoringIndexes, ScoringLabels, ScatterSizeScaling, Alpha)