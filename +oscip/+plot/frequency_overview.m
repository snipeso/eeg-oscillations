function frequency_overview(Power, Frequencies, PeriodicPeaks, Scoring, ScoringIndexes, ScoringLabels, ScatterSizeScaling, Alpha, xLog, yLog)
% frequency_overview(Power, Frequencies, PeriodicPeaks, Scoring, ScoringIndexes, ScoringLabels, ScatterSizeScaling, Alpha, xLog, yLog)
% Power is a channel x epoch x frequency matrix.
arguments
Power
Frequencies
PeriodicPeaks
Scoring = zeros(1, size(Power, 2));
ScoringIndexes = 0;
ScoringLabels = "W";
ScatterSizeScaling = 10;
Alpha = .1;
xLog = false;
yLog = true;
end



if numel(size(Power)) == 2
    Power = permute(Power, [1 3 2]);
    PeriodicPeaks = permute(PeriodicPeaks, [1, 3, 2]);
    Scoring = Scoring(1);
end

figure('Units','centimeters', 'Position',[0 0 20 10], 'Color','w')
if all(isnan(Power))
    return
end

subplot(1, 2, 1)
oscip.plot.scoring_spectra(squeeze(mean(Power, 1, 'omitnan')), Frequencies, ...
    Scoring, ScoringIndexes, ScoringLabels, xLog, yLog)


if not(any(not(isnan(PeriodicPeaks(:)))))
    return
end

xlim([min(Frequencies) max(PeriodicPeaks(:, :, 1), [], 'all')])


subplot(1, 2, 2)
oscip.plot.periodic_peaks(PeriodicPeaks, Scoring, ScoringIndexes, ScoringLabels, ScatterSizeScaling, Alpha)
xlim([min(Frequencies) max(PeriodicPeaks(:, :, 1), [], 'all')])
