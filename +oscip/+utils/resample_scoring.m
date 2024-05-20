function NewScoring = resample_scoring(OldScoring, OldEpochLength, NewEpochLength, SampleRate, NPoints, nNewEpochs)


% assign a score to each timepoint in the recording
ScoringInTime = oscip.utils.scoring2time(OldScoring, OldEpochLength, SampleRate, NPoints);

% new epoch start and end times
Starts = unique([1:NewEpochLength:numel(ScoringInTime), numel(ScoringInTime)]);
Ends = Starts(2:end)-1;
Starts = Starts(1:end-1);

if ~exist("nNewEpochs", 'var') || isempty(nNewEpochs)
    nNewEpochs = numel(Starts);
end
NewScoring = nan(1, nNewEpochs);


% group scores into epochs, assign based on most frequent score for each timepoint
for EpochIdx = 1:nNewEpochs
    Epoch = ScoringInTime(Starts(EpochIdx):Ends(EpochIdx));

    NewScoring(EpochIdx) = mode(Epoch);
    if any(isnan(Epoch))
        NewScoring(EpochIdx) = nan;
    end
end