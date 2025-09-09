function AverageData = average_stages(Data, Scoring, ScoringIndexes, MinEpochs)
% Data is a Channel x Epoch x Something matrix. MinEpochs is the minimum
% number of epochs needed, otherwise the stage gets skipped. This gets
% applied to each channel seperately also considering NaNs, hwoever it
% assumes (for now) that the NANs that apply to the first element of the
% 3rd dimention applies to all the other elements of that dimention.


Dims = size(Data);
nStages = numel(ScoringIndexes);

if numel(Dims)==3
    AverageData = nan(Dims(1), nStages, Dims(3));
elseif numel(Dims)== 2
    AverageData = nan(Dims(1), nStages);
end

for StageIdx = 1:nStages
    Epochs = Scoring==ScoringIndexes(StageIdx);
    if nnz(Epochs) < MinEpochs
        continue
    end

    Subset = Data(:, Epochs, :);
    nNans = sum(isnan(Subset(:, :, 1)), 2);
    Subset(nNans>=MinEpochs, :, :) = nan;
    AverageData(:, StageIdx, :) = mean(Subset, 2, 'omitnan');
end