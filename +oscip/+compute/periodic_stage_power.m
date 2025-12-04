function [PeriodicStagePower, FrequenciesPeriodic] = periodic_stage_power(EpochPower, Frequencies, Scoring, ScoringIndexes, MinEpochs, FittingFrequencyRange, MedianSmoother, MeanSmoother, AdditionalParameters)
arguments
    EpochPower
    Frequencies
    Scoring
    ScoringIndexes
    MinEpochs = 10;
    FittingFrequencyRange = [2 45];
    MedianSmoother = 2; % Hz; could also be [] if want to skip
    MeanSmoother = 2;
    AdditionalParameters = struct();
end
%
% takes raw power, divides it into sleep stages, and applies smoothers if
% requested, then runs specparam to obtain periodic power. This provides
% the spectra needed for peak detection.

%%% average spectra by sleep stage
Dims = size(EpochPower);

if numel(Dims)==2
    EpochPower = permute(EpochPower, [3 1 2]);
end

StagePower = oscip.utils.average_stages(EpochPower, Scoring, ScoringIndexes, MinEpochs);


%%% smooth spectra
if ~isempty(MedianSmoother)
    StagePower = oscip.smooth_spectrum_median(StagePower, Frequencies, MedianSmoother);
end

if ~isempty(MeanSmoother)
    StagePower = oscip.smooth_spectrum(StagePower, Frequencies, MeanSmoother);
end

%%% get periodic power
PeriodicStagePower = nan(Dims(1), numel(ScoringIndexes));
for ChannelIdx = 1:Dims(1)
    for StageIdx = 1:numel(ScoringIndexes)
        [~, ~, FrequenciesPeriodic, ~, PeriodicPower]  = oscip.fit_fooof_matlab(...
            squeeze(StagePower(ChannelIdx, StageIdx, :)), Frequencies, FittingFrequencyRange, AdditionalParameters);

        PeriodicStagePower(ChannelIdx, StageIdx, 1:numel(FrequenciesPeriodic)) = PeriodicPower;
    end
end