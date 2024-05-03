function scoring_spectra(Power, Frequencies, Scoring, ScoringIndexes, ScoringLabels, xLog, yLog)
% power is a E x F matrix
arguments
    Power
    Frequencies
    Scoring = zeros(1, size(Power, 1));
    ScoringIndexes = 0;
    ScoringLabels = "w"; 
    xLog = false;
    yLog = true;
end

Colors = oscip.plot.get_stage_colors(numel(ScoringIndexes));

hold on
for StageIdx = 1:numel(ScoringIndexes)
    Data = mean(Power(Scoring==ScoringIndexes(StageIdx), :), 1, 'omitnan');
    plot(Frequencies, Data, 'LineWidth', 2, 'Color',Colors(StageIdx, :))
end
xlim([min(Frequencies), max(Frequencies)])

if xLog
    set(gca, 'XScale', 'log')
end

if yLog
    set(gca, 'YScale', 'log')
end
ylabel('Power')
xlabel('Frequency (Hz)')

legend(ScoringLabels)
set(legend, 'ItemTokenSize', [10 10])