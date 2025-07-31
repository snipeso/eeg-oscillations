function Table = fill_table_row(Table, BandLabels, ScoringLabels, Data, MeasureLabel)
% Data is a Stage x Band matrix or a Stage x Band x 3 (for periodic peaks).
% MeasureLabel is either "Power", "PeriodicPower", or "Peak", "Slope" or "Intercept"



for StageIdx = 1:numel(ScoringLabels)


    for BandIdx = 1:numel(BandLabels)
        if ~isempty(ScoringLabels{StageIdx})
            Stage = [ScoringLabels{StageIdx}, '_'];
        else
            Stage = '';
        end

        if ~isempty(BandLabels{BandIdx})
            Band = ['_', BandLabels{BandIdx}];
        else
            Band = '';
        end

        % power
        if strcmp(MeasureLabel, 'Peak')
            Table.([Stage, MeasureLabel, 'Frequency', Band]) = Data(StageIdx, BandIdx, 1);
            Table.([Stage, MeasureLabel, 'Amplitude', Band]) = Data(StageIdx, BandIdx, 2);
            Table.([Stage, MeasureLabel, 'Bandwidth', Band]) = Data(StageIdx, BandIdx, 3);
        else
            Table.([Stage, MeasureLabel, Band]) = Data(StageIdx, BandIdx);
        end
    end
end