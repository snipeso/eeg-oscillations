function ScoringInTime = scoring2time(Scoring, EpochLength, SampleRate, NPoints)

ScoringInTime = nan(1, NPoints);

ScoringRep = repmat(Scoring, EpochLength*SampleRate, 1);
ScoringRep = reshape(ScoringRep, [], 1);
ScoringInTime(1:numel(ScoringRep)) = ScoringRep;
ScoringInTime = ScoringInTime(1:NPoints);