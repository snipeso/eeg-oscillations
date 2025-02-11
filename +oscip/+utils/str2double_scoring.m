function Scoring = str2double_scoring(StringScoring, StringIndexes, DoubleIndexes)
arguments
    StringScoring
    StringIndexes = {'w', 'n', 'r'};
    DoubleIndexes = [0, -1, 1];
end

Scoring = nan(1, numel(StringScoring));

for ScoreIdx = 1:numel(StringIndexes)
    Scoring(StringScoring==StringIndexes{ScoreIdx}) = DoubleIndexes(ScoreIdx);
end