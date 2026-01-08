function BandData = power_bands(Data, Bands, Frequencies)
% BandData = average_bands(Data, Bands, Frequencies)
%
% Data is Channel x Epoch x Frequency matrix

Dims = size(Data);

BandLabels = fieldnames(Bands);
nBands = numel(BandLabels);
BandData = nan(Dims(1), Dims(2), nBands);

for BandIdx = 1:nBands
    Band = Bands.(BandLabels{BandIdx});
    if any(isnan(Band))
        continue
    end
    Band = dsearchn(Frequencies', Band');
    BandData(:, :, BandIdx) = mean(Data(:, :, Band(1):Band(2)), 3, 'omitnan');
end