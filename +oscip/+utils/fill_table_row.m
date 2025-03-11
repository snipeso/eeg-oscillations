function Table = fill_table_row(Table, BandLabels, ScoringLabels, Data, MeasureLabel)
% Data is a Stage x Band matrix or a Stage x Band x 3 (for periodic peaks). 
% MeasureLabel is either "Power", "PeriodicPower", or "Peak", "Slope" or "Intercept" 


for StageIdx = 1:numel(ScoringLabels)
    Stage = ScoringLabels{StageIdx};

    if ismember(MeasureLabel, {'Slope', 'Intercept'})
         Table.([Stage, '_', MeasureLabel]) = Data(StageIdx);
        continue
    end

    for BandIdx = 1:numel(BandLabels)

        % power
        Band = BandLabels{BandIdx};
        if strcmp(MeasureLabel, 'Peak')
            Table.([Stage, '_', MeasureLabel, 'Frequency_', Band]) = Data(StageIdx, BandIdx, 1);
            Table.([Stage, '_', MeasureLabel, 'Amplitude_', Band]) = Data(StageIdx, BandIdx, 1);
            Table.([Stage, '_', MeasureLabel, 'Bandwidth_', Band]) = Data(StageIdx, BandIdx, 1);
        else
            Table.([Stage, '_', MeasureLabel, '_', Band]) = Data(StageIdx, BandIdx);
        end
    end
end