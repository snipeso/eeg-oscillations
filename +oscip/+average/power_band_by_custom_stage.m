function AverageData = power_band_by_custom_stage(Data, Scoring, ScoringIndexes, Frequencies, Bands, MinEpochs)
% Data is a Channel x Epoch x Frequency matrix, and AverageData is a
% Channel x Stage x Band matrix. Bands is a 1 x nStages struct, with
% different ranges for each stage.
arguments
    Data
    Scoring
    ScoringIndexes
    Frequencies
    Bands
    MinEpochs = 4;
end


AverageStages = oscip.utils.average_stages(Data, Scoring, ScoringIndexes, MinEpochs);


nStages = size(Bands, 2);

BandLabels = fieldnames(Bands);
nBands = numel(BandLabels);

AverageData = nan(size(AverageStages, 1), size(AverageStages, 2), nBands);

for StageIdx = 1:nStages
    AverageData(:, StageIdx, :) = oscip.average.power_bands(AverageStages(:, StageIdx, :), Bands(1, StageIdx), Frequencies);
end

