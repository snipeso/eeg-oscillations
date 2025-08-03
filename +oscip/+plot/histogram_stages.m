function histogram_stages(Data, Scoring, ScoringLabels, ScoringIndexes, Normalization)
arguments
    Data
    Scoring
    ScoringLabels
    ScoringIndexes
    Normalization = 'pdf';
end
% histogram_stages(Data, Scoring, ScoringLabels, ScoringIndexes, Normalization)
% plots a histogram of all the values, by stage. Especially useful for
% seeing how Exponent changes with each sleep stage.
% Part of eeg-oscillations, by Sophia Snipes, 2024.

Colors = oscip.plot.get_stage_colors(ScoringIndexes);

hold on
for StageIdx = 1:numel(ScoringIndexes)

    DataEpoch = mean(Data(:, Scoring==ScoringIndexes(StageIdx)), 1, 'omitnan');

    histogram(DataEpoch, 'FaceColor', Colors(StageIdx, :), 'FaceAlpha', .4, 'EdgeColor','none', 'Normalization',Normalization)
end

if strcmp(Normalization, 'pdf')
    ylabel('Density')
end

legend(ScoringLabels)
set(legend, 'ItemTokenSize', [10 10])