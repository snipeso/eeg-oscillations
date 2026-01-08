function AverageData = power_band_by_stage(Data, Scoring, ScoringIndexes, Frequencies, Bands, MinEpochs)
% Data is a Channel x Epoch x Frequency matrix, and AverageData is a
% Channel x Stage x Band matrix.
arguments
    Data
    Scoring
    ScoringIndexes
    Frequencies
    Bands
    MinEpochs = 4;
end

BandPeriodicPower = oscip.average.power_bands(Data, Bands, Frequencies);
AverageData = oscip.average.stages(BandPeriodicPower, Scoring, ScoringIndexes, MinEpochs);

AverageData = squeeze(AverageData);