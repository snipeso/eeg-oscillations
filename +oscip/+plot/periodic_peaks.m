function periodic_peaks(PeriodicPeaks, Scoring, ScoringIndexes, ScoringLabels, ScatterSizeScaling, Alpha, Colors)
% plots a scatterplot of the periodic peaks, colorcoded by scoring
% (optional). ScoringIndexes are values that are all the possible scores in
% Scoring, and ScoringLabels are the labels for each of those values.
% ScatterSizeScaling is a number with which to multiply values in the
% second column of PeriodicPeaks (usually power amplitude), to make them
% bigger or smaller.
% Alpha is the transparency of the dots.
% Colors is the colors to assign to each score.
%
% Code by Sophia Snipes, 2024, for eeg-oscillations.
arguments
    PeriodicPeaks
    Scoring = zeros(size(PeriodicPeaks, 2), 1);
    ScoringIndexes = 0;
    ScoringLabels = "w";
    ScatterSizeScaling = 2;
    Alpha = .05;
    Colors = oscip.plot.get_stage_colors(numel(ScoringIndexes));
end

hold on
for StageIdx = 1:numel(ScoringLabels)

    % identify relevant epochs
    Sc = Scoring==ScoringIndexes(StageIdx);
    BW = PeriodicPeaks(:, Sc, 3);
    F = PeriodicPeaks(:, Sc, 1);
    P = PeriodicPeaks(:, Sc, 2);

    BW = BW(:);
    F = F(:);
    P = P(:);

    scatter(F, BW, P*ScatterSizeScaling, 'filled', 'MarkerFaceAlpha', Alpha, ...
        'MarkerFaceColor', Colors(StageIdx, :), 'HandleVisibility','off', ...
        'DisplayName',ScoringLabels{StageIdx});
    scatter(0, 0, nan, 'MarkerFaceColor', Colors(StageIdx, :), 'MarkerEdgeColor','none');
end

% legend(ScoringLabels)
legend(ScoringLabels)

ylim([1 12])
ylabel('Bandwidth (Hz)')
set(legend, 'ItemTokenSize', [10 10], 'location', 'northwest')

xlabel('Peak frequency (Hz)')