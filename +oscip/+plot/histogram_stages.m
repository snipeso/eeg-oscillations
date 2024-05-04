function histogram_stages(Feature, Scoring, ScoringLabels, ScoringIndexes)

Colors = oscip.plot.get_stage_colors(numel(ScoringIndexes));

hold on
for StageIdx = 1:numel(ScoringIndexes)
    Data = mean(Feature(Scoring==ScoringIndexes(StageIdx)), 1, 'omitnan');
    histogram(Data, 'FaceColor', Colors(StageIdx, :), 'FaceAlpha', .4, 'EdgeColor','none')
end

legend(ScoringLabels)
set(legend, 'ItemTokenSize', [10 10])