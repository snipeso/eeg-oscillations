function CustomBands = bandtable2struct(Metadata, Range, Bands, ScoringLabels)
% this function assumes you've run some version of the peak detection, and
% there's columns in a metadata table called "W_PeakAmplitude_Delta" or
% similar.
arguments
    Metadata
    Range = 0.5;
    Bands = [];
    ScoringLabels = {};
end

CustomBands = struct();

if isempty(Bands)

    ColumnNames = Metadata.Properties.VariableNames;
    ColumnNames(~contains(ColumnNames, 'PeakFrequency')) = [];

    BandLabels = unique(extractAfter(ColumnNames, 'PeakFrequency_'));
else
    BandLabels = fieldnames(Bands);
end

if isempty(ScoringLabels)
    ColumnNames = Metadata.Properties.VariableNames;
    ColumnNames(~contains(ColumnNames, 'PeakFrequency')) = [];

    ScoringLabels = unique(extractBefore(ColumnNames, '_PeakFrequency'));
end

for RowIdx = 1:size(Metadata, 1)
    for BandIdx  = 1:numel(BandLabels)
        for ScoringIdx = 1:numel(ScoringLabels)

            PeakFrequency = Metadata.([ScoringLabels{ScoringIdx}, '_PeakFrequency_', BandLabels{BandIdx}])(RowIdx);
            CustomBands(RowIdx, ScoringIdx).(BandLabels{BandIdx}) = PeakFrequency + [-Range, Range];
        end
    end
end