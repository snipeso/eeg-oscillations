function [TradSleepOnset, SleepOnset, OnsetSpeed, WakeSlope, N3Slope, Trend] = detect_sleep_onset(Scoring, Slopes, Time, SmoothSlopes)
% assumes -2 is n2, -3 is n3, 0 is wake
arguments
Scoring
Slopes
Time
SmoothSlopes = 10;
end

% find deepest point of N3 between start of recording and first REM episode
FirstREM = find(Scoring==1, 1, 'first');
[~, MaxSleepDepthTime] = min(smooth(Slopes(1:FirstREM), SmoothSlopes));

% find first epoch that exists this deepest sleep
ScoringIndexes = 1:numel(Scoring);
EndSleepOnset = find(Scoring>-3 & ScoringIndexes>MaxSleepDepthTime, 1, 'first');

[SleepOnset, OnsetSpeed, WakeSlope, N3Slope, Trend] = quantify_sleep_onset(Slopes(1:EndSleepOnset), Time);


TradSleepOnset = Time(find(Scoring==-2,1, 'first'));
