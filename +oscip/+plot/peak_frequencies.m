function peak_frequencies(SpectralPeaks, ParticipantColors)
% plots line plot with markers indicating peak frequency for each
% participant. Good to compare spindle frequencies.
% SpectralPeaks is a P x N matrix.
arguments
    SpectralPeaks
    ParticipantColors = oscip.plot.get_stage_colors(size(SpectralPeaks, 1));
end

[SpectralPeaks, Index] = sortrows(SpectralPeaks, 1, 'ascend');
ParticipantColors = ParticipantColors(Index, :);

hold on
for ParticipantIdx = 1:size(SpectralPeaks, 1)
plot(SpectralPeaks(ParticipantIdx, :)', repmat(ParticipantIdx, 1, size(SpectralPeaks, 2))', '-o', ...
    'Color', ParticipantColors(ParticipantIdx, :), 'MarkerSize', 5,  ...
    'MarkerFaceColor', ParticipantColors(ParticipantIdx, :))
end
xlabel('Frequency (Hz)')
set(gca, 'ytick', [], 'YColor', 'none')