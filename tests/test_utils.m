

%% test1: fix off by one
clc

Scoring = [1 1 1 1 -3 -3 1 -3 -2 -1 0];
MinimumDiscrepancy = 3;

% scoring much less than data
nEpochs = numel(Scoring)-5;
disp('much less')
 ResizedScoring = oscip.utils.fix_off_by_one_scoring(Scoring, nEpochs, MinimumDiscrepancy);

 disp(ResizedScoring)

% scoring a little less than data
disp('little less, edge')
 ResizedScoring = oscip.utils.fix_off_by_one_scoring(Scoring, numel(Scoring)-3, MinimumDiscrepancy);

 disp(ResizedScoring)

 disp('1 off')
 ResizedScoring = oscip.utils.fix_off_by_one_scoring(Scoring, numel(Scoring)-1, MinimumDiscrepancy);

 disp(ResizedScoring)

% scoring equal to data
disp('exact')
 ResizedScoring = oscip.utils.fix_off_by_one_scoring(Scoring, numel(Scoring), MinimumDiscrepancy);

 disp(ResizedScoring)

% scoring a little more than data
disp('1 off positive')
 ResizedScoring = oscip.utils.fix_off_by_one_scoring(Scoring, numel(Scoring)+1, MinimumDiscrepancy);

 disp(ResizedScoring)

% scoring a lot more than data
disp('much more nEpochs')
 ResizedScoring = oscip.utils.fix_off_by_one_scoring(Scoring, numel(Scoring)+10, MinimumDiscrepancy);

 disp(ResizedScoring)






