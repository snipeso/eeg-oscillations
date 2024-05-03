function scoring_hypnogram(Scoring, Time, ScoringIndexes, ScoringLabels)
% plots a classic hypnogram of the sleep scoring. Scoring is an array the
% length of Time. Time should indicate the hours for each epoch in Scoring.
% ScoringIndexes should list all the possible values in the scoring scheme
% (e.g. [-3 -2 -1 0 1]) in order. ScoringLabels should then indicate what
% each of those numbers correspond to.

plot(Time, Scoring, 'LineWidth', 1.5, 'Color', [1, 0, 0, .5])
axis tight
box off
xlabel('Time (h)')

yticks(ScoringIndexes)
yticklabels(ScoringLabels)
ylabel('')