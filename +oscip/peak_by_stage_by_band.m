function PeriodicPeaksByStage = peak_by_stage_by_band(PeriodicPeaks, Bands, Scoring, ScoringIndexes, Settings)
arguments
    PeriodicPeaks
    Bands
    Scoring
    ScoringIndexes
    Settings = oscip.default_settings();
end

nStages = numel(ScoringIndexes);
BandLabels = fieldnames(Bands);
nBands = numel(BandLabels);

PeriodicPeaksByStage = nan(nStages, nBands, 3);

for StageIdx  =1:nStages
    Stage = ScoringIndexes(StageIdx);
    for BandIdx = 1:nBands
        Band = Bands.(BandLabels{BandIdx});
        Epochs = Scoring==Stage;
        
        [~, PeriodicPeaksByStage(StageIdx, BandIdx, :)] = oscip.check_peak_in_band(PeriodicPeaks(:, Epochs, :), Band, 1, Settings);
        
    end
end