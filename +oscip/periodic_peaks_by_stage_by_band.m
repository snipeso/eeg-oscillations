function MetadataTableRow = periodic_peaks_by_stage_by_band(PeriodicPower, Frequencies, ...
    Scoring, ScoringLabels, ScoringIndexes, Bands, MetadataTableRow, MinEpochs, Settings, SmoothSpan)
arguments
    PeriodicPower % a time x frequency matrix
    Frequencies
    Scoring
    ScoringLabels
    ScoringIndexes
    Bands,
    MetadataTableRow = table(); % optional, contains participant information and any other metadata for easy indexing
    MinEpochs = 3;
    Settings = oscip.default_settings();
    SmoothSpan = []; % if power was from average of lots of channels,this can be small; if it was from only a few channels, this should be big, like 5
end


BandLabels = fieldnames(Bands);
Table = oscip.periodic_peaks_by_stage(PeriodicPower, Frequencies, Scoring, ScoringIndexes, table(), MinEpochs, SmoothSpan);


for StageIdx = 1:numel(ScoringIndexes)
    for BandIdx = 1:numel(BandLabels)
        Band = Bands.(BandLabels{BandIdx});
        Data = Table(Table.Stage==ScoringIndexes(StageIdx) & ...
            Table.Frequency>=Band(1) & Table.Frequency < Band(2) & ...
            Table.BandWidth >= Settings.BandwidthLimits(1) & Table.BandWidth <= Settings.BandwidthLimits(2) & ...
            Table.Power >= Settings.PeakAmplitudeMin, :);

        if isempty(Data)
            continue
        end

        Data = sortrows(Data, 'Power', 'descend');

        MetadataTableRow.([ScoringLabels{StageIdx}, '_PeakFrequency_', BandLabels{BandIdx}]) = Data.Frequency(1);
        MetadataTableRow.([ScoringLabels{StageIdx}, '_PeakBandwidth_', BandLabels{BandIdx}]) = Data.BandWidth(1);
        MetadataTableRow.([ScoringLabels{StageIdx}, '_PeakAmplitude_', BandLabels{BandIdx}]) = Data.Power(1);
    end
end