function AverageData = average_stages(Data, Scoring, ScoringIndexes, MinEpochs)
% Data is a Channel x Epoch x Something matrix. MinEpochs is the minimum
% number of epochs needed, otherwise the stage gets skipped.

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

    AverageData(:, StageIdx, :) = mean(Data(:, Epochs, :), 2, 'omitnan');
end