function Table = all_peak_parameters_matlab(Freqs, Power, MetadataRow)
% fits fooof on power, saves relevant information
% power is a channel x frequency matrix

% set up new row
MetadataRow.Frequency = nan;
MetadataRow.BandWidth = nan;
MetadataRow.Power = nan;

% fit fooof

% maybe one day
% AllPeriodicPeaks = [];
% for ChannelIdx = 1:size(Power, 1)
%     PeriodicPeaks = oscip.findpeaks_matlab(Power(ChannelIdx, :), Freqs, 5);
%     AllPeriodicPeaks = cat(1, AllPeriodicPeaks, PeriodicPeaks);
% end

AllPeriodicPeaks = oscip.findpeaks_matlab(mean(Power, 1, 'omitnan'), Freqs, 5);
if isempty(AllPeriodicPeaks)
    Table = table();
    return
end

Table = repmat(MetadataRow, size(AllPeriodicPeaks, 1), 1);
Table.Frequency = AllPeriodicPeaks(:, 1);
Table.Power = AllPeriodicPeaks(:, 2);
Table.BandWidth = AllPeriodicPeaks(:, 3);
Table.Prominance = AllPeriodicPeaks(:, 4);
end