function Table = setup_blank_columns(Table, BandLabels, ScoringLabels)
% this function adds nan columns to a table. The columns will be named as
% "{Stage}_{Measure}_{Band}".
arguments
    Table
    BandLabels = {'Delta', 'Theta', 'Alpha', 'Sigma', 'Beta', 'Iota', 'Gamma'};
    ScoringLabels = {'N3', 'N2', 'N1', 'W', 'R'};
end

nRows = size(Table, 1);
BlankColumn = nan(nRows, 1);

for StageCell = ScoringLabels
    Stage = StageCell{1};

    % aperiodic measures
    Table.([Stage, '_Slope']) = BlankColumn;
    Table.([Stage, '_Intercept']) = BlankColumn;

    for BandCell = BandLabels'

        % power
        Band = BandCell{1};
        Table.([Stage, '_Power_', Band]) = BlankColumn;
        Table.([Stage, '_PeriodicPower_', Band]) = BlankColumn;
    end
end


for StageCell = ScoringLabels % repeated the loops so that the peak columns are all at the end
    Stage = StageCell{1};

    for BandCell = BandLabels'
        Band = BandCell{1};

        % periodic peaks
        Table.([Stage, '_PeakFrequency_', Band]) = BlankColumn;
        Table.([Stage, '_PeakAmplitude_', Band]) = BlankColumn;
        Table.([Stage, '_PeakBandwidth_', Band]) = BlankColumn;
    end
end