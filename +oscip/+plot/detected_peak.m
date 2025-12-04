function detected_peak(PeriodicStagePower, FrequenciesPeriodic, PeaksByStageByBand, StageIdx, BandIdx)

hold on
plot(FrequenciesPeriodic, squeeze(PeriodicStagePower(:, 5, :)), 'Color', [.2 .2 .2 .3], 'HandleVisibility', 'off')
plot(FrequenciesPeriodic, squeeze(mean(PeriodicStagePower(:, StageIdx, :), 1, 'omitnan')), 'Color', oscip.plot.color_picker(1, '', 'blue'), 'LineWidth', 2)
Peak = PeaksByStageByBand(StageIdx, BandIdx, 1);
Amp = PeaksByStageByBand(StageIdx, BandIdx, 2);
BW = PeaksByStageByBand(StageIdx, BandIdx, 3);
Ch = PeaksByStageByBand(StageIdx, BandIdx, 5);

if ~isnan(Ch)
    plot(FrequenciesPeriodic, squeeze(PeriodicStagePower(Ch, StageIdx, :)), 'Color', oscip.plot.color_picker(1, '', 'red'), 'LineWidth', 2)
end

plot([Peak-BW/2, Peak+BW/2], [Amp, Amp], 'Color', oscip.plot.color_picker(1, '', 'red'))
scatter(PeaksByStageByBand(StageIdx, BandIdx, 1), PeaksByStageByBand(StageIdx, BandIdx, 2), 30, 'filled', 'MarkerFaceColor',oscip.plot.color_picker(1, '', 'red'))