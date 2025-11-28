function [PeaksByStageByBand, PeaksTable] = peaks_by_band_bt_stage_rawpower(EpochPower, Frequencies, Scoring, ScoringIndexes, MinEpochs, FittingFrequencyRange, MinPeakProminance, AdditionalParameters)
arguments
    EpochPower % should be channel x epoch x frequency or epoch x frequency
    Frequencies
    Scoring
    ScoringIndexes
    MinEpochs = 10;
    FittingFrequencyRange = [2 45];
    MinPeakProminance = .001;
    AdditionalParameters = [];
end

if isempty(AdditionalParameters)
    AdditionalParameters = struct();
    AdditionalParameters.peak_width_limits = [0.5 20];
    AdditionalParameters.min_peak_height = .01;
end

Dims = size(EpochPower);
if numel(Dims)==3
    EpochPower = squeeze(mean(EpochPower, 1, 'omitnan'));
end

StagePower = oscip.utils.average_stages(EpochPower, Scoring, ScoringIndexes, MinEpochs);

PeaksTable = table();
for StageIdx = 1:numel(ScoringIndexes)
    [~, ~, FrequenciesPeriodic, ~, PeriodicPower]  = oscip.fit_fooof_matlab(...
        StagePower(StageIdx, :), Frequencies, FittingFrequencyRange, AdditionalParameters);
    [pks, locs, w, p] = findpeaks(PeriodicPower, FrequenciesPeriodic, 'MinPeakProminence', MinPeakProminance, 'WidthReference','halfheight');

    T = table();
    T.Stage = repmat(ScoringIndexes(StageIdx), numel(pks), 1);
    T.Frequency = locs';
    T.Amplitude = pks';
    T.Bandwidth = w';
    T.Prominance = p';

    PeaksTable = cat(1, PeaksTable, T);
end