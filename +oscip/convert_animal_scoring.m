function [NewScoring, ScoringIndexes, ScoringLabels] = convert_animal_scoring(b, NEpochs, NewEpochLength, OldEpochLength)
arguments
    b
    NEpochs
    NewEpochLength = 20;
    OldEpochLength = 4;
end

% turn string into numbers
sScoring = nan(1, numel(b));
sScoring(b=='w') = 0;
sScoring(b=='n') = -2;
sScoring(b=='r') = 1;
sScoring(b=='t') = -1;


NewScoring = nan(1, NEpochs);
Starts = 1:round(NewEpochLength/OldEpochLength):numel(b);
Ends = unique([Starts(2:end)-1, numel(b)]);

for EpochIdx = 1:NEpochs
    Epoch = sScoring(Starts(EpochIdx):Ends(EpochIdx));

    NewScoring(EpochIdx) = mode(Epoch);
    if any(isnan(Epoch))
        NewScoring(EpochIdx) = nan;
    end
end

ScoringIndexes = [-2 0 1];
ScoringLabels = {'NR', 'W', 'R'};

if any(b=='t')
    ScoringIndexes = [-2 -1 0 1];
    ScoringLabels = {'NR', 'T', 'W', 'R'};
end