function [TradSleepOnset, SleepOnset, OnsetSpeed, WakeExponent, N3Exponent, Trend, TimeOnset, Exponents] = detect_sleep_onset(Scoring, Exponents, Time, MinEpochs, SmoothExponents)
% assumes -2 is n2, -3 is n3, 0 is wake
arguments
Scoring
Exponents
Time
MinEpochs = 5;
SmoothExponents = 10;
end

% find deepest point of N3 between start of recording and first REM episode
FirstREM = find(Scoring==1, 1, 'first');
[~, MaxSleepDepthTime] = max(smooth(Exponents(1:FirstREM), SmoothExponents));

% find first epoch that exists this deepest sleep
ScoringIndexes = 1:numel(Scoring);
EndSleepOnset = find(Scoring>-3 & ScoringIndexes>MaxSleepDepthTime, 1, 'first');

[SleepOnset, OnsetSpeed, WakeExponent, N3Exponent, Trend, TimeOnset, Exponents] = oscip.quantify_sleep_onset(Exponents(1:EndSleepOnset), Time(1:EndSleepOnset), MinEpochs);


TradSleepOnset = Time(find(Scoring==-2,1, 'first'));
