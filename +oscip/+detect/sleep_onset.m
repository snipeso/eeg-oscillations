function [TradSleepOnset, SleepOnset, OnsetSpeed, WakeExponent, N3Exponent, RMSE, Trend, TimeOnset, ExponentsOnset] = ...
    sleep_onset(Scoring, Exponents, Time, MinWakeEpochs, SmoothExponents)
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
    MinWakeEpochs = 10;
    SmoothExponents = 10;
end

% defaults
TradSleepOnset = nan;
SleepOnset = nan;
OnsetSpeed = nan;
WakeExponent = nan;
N3Exponent = nan;
Trend = nan;
TimeOnset = nan;
ExponentsOnset = nan;

if ~any(Scoring<0)
    warning("This poor person didn't sleep at all")
    return
end

% find approximately sleep onset
EndDeepestSleep = end_deepest_sleep(Scoring);
StartLastWake = closest_wake(Scoring, EndDeepestSleep, MinWakeEpochs);

[SleepOnset, OnsetSpeed, WakeExponent, N3Exponent, RMSE, Trend, TimeOnset, ExponentsOnset] = ...
    oscip.quantify_sleep_onset(Exponents(StartLastWake:EndDeepestSleep), Time(StartLastWake:EndDeepestSleep), MinWakeEpochs);

TradSleepOnset = Time(find(Scoring==-2,1, 'first'));
end



function Start = closest_wake(Scoring, End, MinWake)

FirstCycle = Scoring(1:End);

if ~any(FirstCycle==0)
    warning('no wake?!')
    WakeStage = max(Scoring);
else
    WakeStage = 0;
end

[Starts, Ends] = data2windows(FirstCycle==WakeStage);
WakeDurations  = Ends-Starts;

Start = Starts(find(WakeDurations>MinWake, 1, 'last'));

end

function End = end_deepest_sleep(Scoring)

% identify window of first sleep cycle

if ~any(Scoring==1)
    warning('No REM, so looking at whole night')
    FirstREM = numel(Scoring);
else

    FirstREM = find(Scoring==1, 1, 'first');
end
FirstCycle = Scoring(1:FirstREM);


% find end of longest deepest bout
DeepestStage = min(FirstCycle);
OverallDeepestStage = min(Scoring);
if OverallDeepestStage < DeepestStage
    warning('Patient has narcolepsy!')
end

[Starts, Ends] = data2windows(FirstCycle==DeepestStage);
[~, LargestBoutIdx] = max(Ends-Starts);
End = Ends(LargestBoutIdx);
end
