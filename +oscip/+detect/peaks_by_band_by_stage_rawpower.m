function [PeaksByStageByBand, PeaksTable, PeriodicStagePower, FrequenciesPeriodic] = peaks_by_band_by_stage_rawpower(EpochPower, Frequencies, Scoring, ScoringIndexes, Bands, MinEpochs, FittingFrequencyRange, MinPeakProminance, MinPeakDistance, AdditionalParameters)
arguments
    EpochPower % should be channel x epoch x frequency or epoch x frequency
    Frequencies
    Scoring
    ScoringIndexes
    Bands
    MinEpochs = 10;
    FittingFrequencyRange = [2 45];
    MinPeakProminance = .01;
    MinPeakDistance = 1;
    AdditionalParameters = [];
end

if isempty(AdditionalParameters)
    AdditionalParameters = struct();
    AdditionalParameters.min_peak_height = MinPeakProminance; % not strictly needed, but at least consistent
end

Dims = size(EpochPower);

if numel(Dims)==2
    EpochPower = permute(EpochPower, [3 1 2]);
end

StagePower = oscip.utils.average_stages(EpochPower, Scoring, ScoringIndexes, MinEpochs);
StagePower = oscip.smooth_spectrum_median(StagePower, Frequencies, 2);
StagePower = oscip.smooth_spectrum(StagePower, Frequencies, 2);

PeriodicStagePower = nan(Dims(1), numel(ScoringIndexes));
PeaksTable = table();
for ChannelIdx = 1:Dims(1)
    for StageIdx = 1:numel(ScoringIndexes)
        [~, ~, FrequenciesPeriodic, ~, PeriodicPower]  = oscip.fit_fooof_matlab(...
            squeeze(StagePower(ChannelIdx, StageIdx, :)), Frequencies, FittingFrequencyRange, AdditionalParameters);

        % just for finding the peak frequency, adjust so that all values are
        % above 0
        AdjustedPower = PeriodicPower- min(quantile(PeriodicPower, .1), 0);

        [~, locs, w, p] = oscip.detect.peaks(AdjustedPower, FrequenciesPeriodic, MinPeakProminance, MinPeakDistance);

        % % re-calculate amplitudes
        pks = PeriodicPower(ismember(FrequenciesPeriodic, locs)); % no longer uses adjusted spectra, so that values are more comparable across channels later

        % figure
        % findpeaks(AdjustedPower, FrequenciesPeriodic, 'MinPeakProminence', MinPeakProminance, 'MinPeakDistance', MinPeakDistance, 'Annotate','extents');
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

        Peaks = select_peaks_in_stage_band(PeaksTable, Bands.(BandLabels{BandIdx}), ScoringIndexes(StageIdx));
        % Peaks = select_most_prominant_peaks_by_channel(Peaks);
        PeaksByStageByBand(StageIdx, BandIdx, :) = select_largest_peak(Peaks);
    end
end
end

function Peaks = select_peaks_in_stage_band(PeaksTable, Range, ScoringIndex)

Peaks = PeaksTable(PeaksTable.Stage== ScoringIndex & ...
    PeaksTable.Frequency >= Range(1) & PeaksTable.Frequency < Range(2), :);
end


function Peaks = select_most_prominant_peaks_by_channel(PeaksTable)

Peaks = table();

for ChannelIdx = unique(PeaksTable.Channel)'
    PeaksChannel = sortrows(PeaksTable(PeaksTable.Channel==ChannelIdx, :), 'Prominance', 'descend');
    Peaks = [Peaks; PeaksChannel(1, :)];
end
end

function Peak = select_largest_peak(PeaksTable)


if ~isempty(PeaksTable)
    Peaks = sortrows(PeaksTable, 'Amplitude', 'descend');

    Peak = table2array(Peaks(1, {'Frequency', 'Amplitude', 'Bandwidth', 'Prominance', 'Channel'}));
else
    Peak = nan(1, 5);
end
end


