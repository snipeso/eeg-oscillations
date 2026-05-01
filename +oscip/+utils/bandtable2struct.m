function CustomBands = bandtable2struct(Metadata, Bands, ScoringLabels,Bandwidth)
% this function assumes you've run some version of the peak detection, and
% there's columns in a metadata table called "W_PeakAmplitude_Delta" or
% similar.
arguments
    Metadata
    Bands = [];
    ScoringLabels = {};
    Bandwidth = []; % either provide fixed number, or if empty will use peaks' bandwdith
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

            if isempty(Bandwidth)
                BW =  Metadata.([ScoringLabels{ScoringIdx}, '_PeakBandwidth_', BandLabels{BandIdx}])(RowIdx)/2;
            end

            CustomBands(RowIdx, ScoringIdx).(BandLabels{BandIdx}) = PeakFrequency + [-BW, BW];
        end
    end
end