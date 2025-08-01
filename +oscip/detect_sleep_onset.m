function [TradSleepOnset, SleepOnset, OnsetSpeed, WakeSlope, N3Slope, Trend, TimeOnset, Slopes] = detect_sleep_onset(Scoring, Slopes, Time, MinEpochs, SmoothSlopes)
% assumes -2 is n2, -3 is n3, 0 is wake
arguments
Scoring
Slopes
Time
MinEpochs = 5;
SmoothSlopes = 10;
end

% find deepest point of N3 between start of recording and first REM episode
FirstREM = find(Scoring==1, 1, 'first');
[~, MaxSleepDepthTime] = max(smooth(Slopes(1:FirstREM), SmoothSlopes));

% find first epoch that exists this deepest sleep
ScoringIndexes = 1:numel(Scoring);
EndSleepOnset = find(Scoring>-3 & ScoringIndexes>MaxSleepDepthTime, 1, 'first');

[SleepOnset, OnsetSpeed, WakeSlope, N3Slope, Trend, TimeOnset, Slopes] = oscip.quantify_sleep_onset(Slopes(1:EndSleepOnset), Time(1:EndSleepOnset), MinEpochs);


TradSleepOnset = Time(find(Scoring==-2,1, 'first'));
