function [BandByStage, PeakDetectionSettings] = peaks_by_stage(PeriodicPeaks, Scoring, BandByStage, PeakDetectionSettings)
arguments
    PeriodicPeaks
    Scoring
    BandByStage = table(); % "Stage" column is the stage as a number, "DefaultBand" is the band limits to check for that oscillation
    PeakDetectionSettings = [];
end



% all bands and all stages
if isempty(BandByStage)

    Stages = unique(Scoring);
    Stages(isnan(Stages)) = [];
    

    [DefaultBands, BandLabels] = oscip.utils.get_default_bands();
    BandByStage = table(repmat(BandLabels, numel(Stages), 1), repmat(DefaultBands, numel(Stages), 1), repelem(Stages, size(DefaultBands, 1))', 'VariableNames', {'Band', 'DefaultBands', 'Stages'});
else
    Stages = unique(BandByStage.DefaultBands);
    DefaultBands = unique(BandByStage.DefaultBand, "rows");
end


if isempty(PeakDetectionSettings)
    PeakDetectionSettings = oscip.default_settings();
    PeakDetectionSettings.PeakBandwidthMax = 4; % broader peaks are not oscillations
    PeakDetectionSettings.PeakBandwidthMin = .5; % Hz; narrow peaks are more often than not noise
end

nRows = size(BandByStage, 1);
BandByStage.CenterFrequency = nan(nRows, 1);
BandByStage.Amplitude = nan(nRows, 1);
BandByStage.Bandwidth = nan(nRows, 1);

for Stage = Stages
    for BandIdx = 1:size(DefaultBands, 1)
        Band = DefaultBands(BandIdx, :);
        TableIdx = BandByStage.Stages==Stage & all(BandByStage.DefaultBands==Band, 2);

        StageEpochs = ismember(Scoring, Stage);
        SameStagePeriodicPeaks = PeriodicPeaks(:, StageEpochs, :);
        
        if isempty(SameStagePeriodicPeaks)
            continue
        end

        [isPeak, MaxPeak] = oscip.check_peak_in_band(SameStagePeriodicPeaks, Band, 1, PeakDetectionSettings);
        
        % use 0 for amplitude if there was enough of the stage, but no peak
        % was detected
        if ~isPeak
            BandByStage.Amplitude(TableIdx) = 0;
            continue
        end

        BandByStage.CenterFrequency(TableIdx) = MaxPeak(1);
        BandByStage.Amplitude(TableIdx) = MaxPeak(2);
        BandByStage.Bandwidth(TableIdx) = MaxPeak(3);
    end
end



