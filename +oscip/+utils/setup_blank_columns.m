function Table = setup_blank_columns(Table, BandLabels, ScoringLabels, Measures)
% this function adds nan columns to a table. The columns will be named as
% "{Stage}_{Measure}_{Band}".
arguments
    Table
    BandLabels = {'Delta', 'Theta', 'Alpha', 'Sigma', 'Beta', 'Iota', 'Gamma'};
    ScoringLabels = {'N3', 'N2', 'N1', 'W', 'R'};
    Measures = {'Exponent', 'Offset', 'Power', 'PeriodicPower', 'Peak', 'SleepOnset'};
end

nRows = size(Table, 1);
BlankColumn = nan(nRows, 1);

PeakMeasures = {'PeakFrequency', 'PeakAmplitude', 'PeakBandwidth', 'PeakProminance', 'PeakChannel'};
SleepOnsetMeasures = {'SleepOnset', 'OnsetSpeed', 'WakeExponent', 'N3Exponent', 'OnsetRMSE', 'TransitionExponent'};

for MeasureIdx = 1:numel(Measures)
    Measure = Measures{MeasureIdx};

    for StageCell = ScoringLabels % not all measures have a stage or band, so they will be overwritten a few times; doesn't really cost time, and this makes the code cleaner

        if isempty(StageCell{1})
            Stage = '';
        else
            Stage = [StageCell{1}, '_'];
        end

        for BandCell = BandLabels'
            if isempty(BandCell{1})
                Band = '';
            else
                Band = ['_', BandCell{1}];
            end

            switch Measure
                case {'Peak'}
                    for PeakIdx = 1:numel(PeakMeasures)
                        Band = BandCell{1};
                        PeakMeasure = PeakMeasures{PeakIdx};
                        Table.([Stage, PeakMeasure, '_', Band]) = BlankColumn;
                    end

                case {'SleepOnset'}
                    for SOMIdx = 1:numel(SleepOnsetMeasures)
                        SleepOnsetMeasure = SleepOnsetMeasures{SOMIdx};
                        Table.(SleepOnsetMeasure) = BlankColumn;
                    end

                otherwise
                    Table.([Stage, Measure, Band]) = BlankColumn;
            end
        end
    end
end