function ResizedScoring = fix_off_by_one_scoring(Scoring, nDataEpochs, MinimumDiscrepancy)
arguments
    Scoring
    nDataEpochs
    MinimumDiscrepancy = 2;
end
%  ResizedScoring = fix_off_by_one_scoring(Scoring, nDataEpochs, MinimumDiscrepancy)
%
% This function adjusts the length of the Scoring array to match the number
% of epochs actually resulting from the EEG data, to handle common
% off-by-one errors.
% Scoring is a 1 x n array. nDataEpochs is an integer, best calculated as
% `size(Power, 2)`. MinimumDiscrepancy is optional (default=2) and if the
% actual size of the scoring is off by more than this difference from
% nDataEpochs, it will return an array of NaNs as long as nDataEpochs.
%
% from eeg-oscillations, Snipes, 2025.

nScoringEpochs = numel(Scoring);

ResizedScoring = nan(1, nDataEpochs);
if nScoringEpochs > nDataEpochs + MinimumDiscrepancy || nScoringEpochs < nDataEpochs - MinimumDiscrepancy
    warning(['Mismatch of scoring and epochs greater than ', num2str(MinimumDiscrepancy) '; returning NaN scoring'])
    return
end

% adjust size
if nDataEpochs<nScoringEpochs
    ResizedScoring = Scoring(1:nDataEpochs);
else
    ResizedScoring(1:nScoringEpochs) = Scoring;
end


