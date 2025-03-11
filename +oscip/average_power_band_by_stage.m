function AverageData = average_power_band_by_stage(Data, Scoring, ScoringIndexes, Frequencies, Bands, MinEpochs)
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

BandPeriodicPower = oscip.utils.average_bands(Data, Bands, Frequencies);
AverageData = oscip.utils.average_stages(BandPeriodicPower, Scoring, ScoringIndexes, MinEpochs);

AverageData = squeeze(AverageData);