function [TradSleepOnset, SleepOnset, OnsetSpeed, WakeExponent, N3Exponent, RMSE, Trend, TimeOnset, ExponentsOnset] = ...
    sleep_onset(Scoring, Exponents, Time, MinEpochs, SmoothExponents)
% Calculates detailed measures of sleep onset. Uses traditional scoring to
% first identify the window of sleep onset, then characterizes it with
% aperiodic exponents (or any measure you pass it). It fits a sigmoid,
% which provides 4 measures (see below).
%
% Inputs:
% Scoring is a 1 x nEpochs array which assumes -2 is n2, -3 is n3, 0 is wake, 1 is REM.
% Exponents needs to be a 1 x nEpochs array.
% Time is just to provide a traditional measure of sleep onset time.
% MinEpochs (e.g. 5) is self explanatory.
% SmoothExponents is a number of epochs over which to run a mean smoother;
% not strictly necessary but helpful.
%
% Outputs:
% TradSleepOnset is in whatever units Time was, and is the time to first N2
% SleepOnset is the the midpoint of the sigmoid as it passes from min to
% max values.
% OnsetSpeed captures the steepdness of the sigmoid, so how quickly the
% person fell asleep once sleep onset kicked in.
% WakeExponent and N3Exponent are the min and max exponent values the
% sigmoid ended up in.
% RMSE (root mean square error) quantifies how well the sigmoid fit the
% data.
% Trend is the sigmoid fitted (for plotting)
% TimeOnset and ExponentsOnset are the chunks of data used to calculate
% sleep onset.


arguments
    Scoring
    Exponents
    Time
    MinEpochs = 10;
    SmoothExponents = 10;
end

% defaults
TradSleepOnset = nan;
SleepOnset = nan;
OnsetSpeed = nan;
WakeExponent = nan;
N3Exponent = nan;
Trend = nan;
RMSE = nan;
TimeOnset = nan;
ExponentsOnset = nan;

if ~any(Scoring<-1)
    warning("This poor person didn't sleep at all")
    return
end

% find approximately sleep onset
[EndDeepestSleep, DeepestStage] = end_deepest_sleep(Scoring, MinEpochs);
StartLastWake = closest_wake(Scoring, EndDeepestSleep, MinEpochs);

OnsetExponents = Exponents(StartLastWake:EndDeepestSleep);
OnsetScores = Scoring(StartLastWake:EndDeepestSleep);
if all(isnan(OnsetExponents(OnsetScores==0))) || all(isnan(OnsetExponents(OnsetScores==DeepestStage))) 
    warning('Not enough clean data')
    return
end

[SleepOnset, OnsetSpeed, WakeExponent, N3Exponent, RMSE, Trend, TimeOnset, ExponentsOnset] = ...
    oscip.quantify_sleep_onset(OnsetExponents, Time(StartLastWake:EndDeepestSleep), MinEpochs);

TradSleepOnset = Time(find(Scoring==-2,1, 'first'));
end



function Start = closest_wake(Scoring, End, MinWake)

FirstCycle = Scoring(1:End);

if ~any(FirstCycle==0)
    Start = 1;
    return
end

% ignore really short flickers of N1
[Starts, Ends] = oscip.utils.data2windows(FirstCycle==-1);

Ends(Starts==1) = [];
Starts(Starts==1) = []; % skip if edge

for StartIdx = 1:numel(Starts)
    if Ends(StartIdx)-Starts(StartIdx) <2 && FirstCycle(Starts(StartIdx)-1) == 0 && FirstCycle(Ends(StartIdx)+1) == 0
        FirstCycle(Starts(StartIdx):Ends(StartIdx)) = 0;
    end
end

if ~any(FirstCycle==0)
    warning('no wake?!')
    WakeStage = max(Scoring);
else
    WakeStage = 0;
end

[Starts, Ends] = oscip.utils.data2windows(FirstCycle==WakeStage);
WakeDurations  = Ends-Starts;

Start = Starts(find(WakeDurations>MinWake, 1, 'last'));
end

function [End, DeepestStage] = end_deepest_sleep(Scoring, MinEpochs)

% find time of first N3
    EpochIndexes = 1:numel(Scoring);
OverallDeepestStage = min(Scoring);
[~, Ends] = oscip.utils.data2windows(Scoring==OverallDeepestStage);
EndN3 = Ends(1);

% identify window of first sleep cycle

FirstREM = find((Scoring==1 | Scoring==0) & EpochIndexes>EndN3, 1, 'first'); % also wake, because first REM bout can be skipped

FirstCycle = Scoring(1:FirstREM);


% find end of longest deepest bout
DeepestStage = min(FirstCycle);
if OverallDeepestStage < DeepestStage
    warning('Patient has narcolepsy!')
end

[Starts, Ends] = oscip.utils.data2windows(FirstCycle==DeepestStage);
N3Durations = Ends-Starts;
if any(N3Durations) >= MinEpochs
    End = Ends(find(N3Durations>=MinEpochs, 1, 'first'));
    return
end
[~, LargestBoutIdx] = max(N3Durations);
End = Ends(LargestBoutIdx);
end
