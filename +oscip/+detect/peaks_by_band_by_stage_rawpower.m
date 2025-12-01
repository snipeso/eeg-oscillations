function [PeaksByStageByBand, PeaksTable, PeriodicStagePower, FrequenciesPeriodic] = peaks_by_band_by_stage_rawpower(EpochPower, Frequencies, Scoring, ScoringIndexes, Bands, MinEpochs, FittingFrequencyRange, MinPeakProminance, MinPeakDistance, AdditionalParameters)
arguments
    EpochPower % should be channel x epoch x frequency or epoch x frequency
    Frequencies
    Scoring
    ScoringIndexes
    Bands
    MinEpochs = 10;
    FittingFrequencyRange = [2 45];
    MinPeakProminance = .001;
    MinPeakDistance = 1;
    AdditionalParameters = [];
end

if isempty(AdditionalParameters)
    AdditionalParameters = struct();
    % AdditionalParameters.peak_width_limits = [0.5 20]; % not needed since specparam peaks not used?
    AdditionalParameters.min_peak_height = .01;
end

Dims = size(EpochPower);
% if numel(Dims)==3
%     EpochPower = squeeze(mean(EpochPower, 1, 'omitnan'));
% else
if numel(Dims)==2
    EpochPower = permute(EpochPower, [3 1 2]);
end

StagePower = oscip.utils.average_stages(EpochPower, Scoring, ScoringIndexes, MinEpochs);

PeriodicStagePower = nan(Dims(1), numel(ScoringIndexes));
PeaksTable = table();
for ChannelIdx = 1:Dims(1)
    for StageIdx = 1:numel(ScoringIndexes)
        [~, ~, FrequenciesPeriodic, ~, PeriodicPower]  = oscip.fit_fooof_matlab(...
            squeeze(StagePower(ChannelIdx, StageIdx, :)), Frequencies, FittingFrequencyRange, AdditionalParameters);

        % just for finding the peak frequency, adjust so that all values are
        % above 0
        AdjustedPower = PeriodicPower- min(quantile(PeriodicPower, .1), 0);
        [~, locs, ~, p] = findpeaks(AdjustedPower, FrequenciesPeriodic, 'MinPeakProminence', MinPeakProminance, 'WidthReference','halfheight', 'MinPeakDistance', MinPeakDistance);
        
        % re-calculate amplitudes and bandwidths
        pks = PeriodicPower(ismember(FrequenciesPeriodic, locs)); % no longer uses adjusted spectra, so that values are more comparable across channels later
        w  =  oscip.detect.fwhm(FrequenciesPeriodic,  AdjustedPower, locs);

        % figure
        % findpeaks(AdjustedPower, FrequenciesPeriodic, 'MinPeakProminence', MinPeakProminance, 'WidthReference','halfheight', 'Annotate','extents')
        T = table();
        T.Frequency = locs';
        T.Amplitude = pks';
        T.Bandwidth = w';
        T.Prominance = p';
        T.Channel =  repmat(ChannelIdx, numel(pks), 1);
        T.Stage = repmat(ScoringIndexes(StageIdx), numel(pks), 1);

        PeaksTable = cat(1, PeaksTable, T);
        PeriodicStagePower(ChannelIdx, StageIdx, 1:numel(FrequenciesPeriodic)) = PeriodicPower;
    end
end

PeaksTable(PeaksTable.Prominance < MinPeakProminance, :) = [];

% assemble into table of stage x band
BandLabels = fieldnames(Bands);
PeaksByStageByBand = nan(numel(ScoringIndexes), numel(BandLabels), 5);
for StageIdx = 1:numel(ScoringIndexes)
    for BandIdx = 1:numel(BandLabels)
        Range = Bands.(BandLabels{BandIdx});
        Peaks = sortrows(PeaksTable(PeaksTable.Stage==ScoringIndexes(StageIdx) & ...
            PeaksTable.Frequency >= Range(1) & PeaksTable.Frequency < Range(2), :), 'Amplitude', 'descend');
        if ~isempty(Peaks)
        PeaksByStageByBand(StageIdx, BandIdx, :) = Peaks{1, 1:5};
        end
    end
end

