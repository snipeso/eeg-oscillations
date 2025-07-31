function AverageData = average_stage_split_by_time(Data, Scores, TimeSplitType, nSplits, MinEpochs, EpochLength)
% Data is Channel x Epoch matrix
% AverageData is a Channel x nSplits matrix.
% Scores is a boolean of all the scores to consider for the analysis. E.g.
% for NREM, provide Scoring<0.
% TimeSplitType can be either: 'Hour', 'Quantile', 'Custom';
% if "Hour", it will divide the data into chunks as big as indicated in
% nSplits (so 1 is 1h, .5 is 30 min, etc); the number of nSplits will
% depend on the length of the data
% if "Quantile" it will divide the amount of time in the selected stage in
% nSplit number of quantiles
% if "Custom", then Scores has to be a vector with integers indicating the
% different sections of the data to average. nSplits can be empty
% split by cycles for example, which you can calculate on your own.
% Epoch length is only needed if using "Hour"
arguments
    Data
    Scores = true(1, size(Data,2));
    TimeSplitType = 'Quantile';
    nSplits = 5;
    MinEpochs = 2;
    EpochLength = 30;
end


% assign a bin for each epoch, depending on requested data division
switch TimeSplitType
    case 'Quantile'
        CountEpochs = cumsum(Scores);
        Quantiles = quantile(CountEpochs, linspace(0, 1, nSplits+1));
        BinScores = discretize(CountEpochs, Quantiles);

    case 'Hour'
        Hour = ceil(nSplits*60/EpochLength); % this is the number of epochs that make up the requested time to cluster
        CountEpochs = cumsum(Scores);
        BinScores = discretize(CountEpochs, 1:Hour:max(CountEpochs));
        warning('untested code in avreage_stage_split_by_time')

    case 'Custom'
    BinScores = Scores;

    otherwise
        error('incorrect split type for oscip average split time')
end

Bins = unique(BinScores);

AverageData = nan(size(Data, 1), numel(Bins));

for BinTypeIdx = 1:numel(Bins)
    BinIndexes = BinScores==Bins(BinTypeIdx); % this is in case some values are skipped in Custom
    if nnz(BinIndexes==1) < MinEpochs
        continue
    end

    AverageData(:, BinTypeIdx) = mean(Data(:, BinIndexes), 2, 'omitnan');
end



