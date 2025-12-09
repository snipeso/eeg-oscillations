function [TradSleepOnset, SleepOnset, OnsetSpeed, WakeExponent, N3Exponent, RMSE, PreSleepSD, Trend, TimeOnset, ExponentsOnset] = ...
    sleep_onset(Scoring, Exponents, Time, MinEpochs)
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
PreSleepSD = nan;

if ~any(Scoring<-1)
    warning("This poor person didn't sleep at all")
    return
end

if all(isnan(Exponents))
    warning('no data')
    return
end

% find approximately sleep onset

[EndDeepestSleep, DeepestEpoch] = end_deepest_sleep2(Exponents, Scoring, MinEpochs);
DeepestStage = Scoring(DeepestEpoch);
StartLastWake = closest_wake2(Exponents, EndDeepestSleep, MinEpochs);
% StartLastWake = 1;

OnsetExponents = Exponents(StartLastWake:EndDeepestSleep);
OnsetScores = Scoring(StartLastWake:EndDeepestSleep);
if nnz(~isnan(OnsetExponents)) < MinEpochs
    warning('Not enough clean data')
    return
end

[SleepOnset, OnsetSpeed, WakeExponent, N3Exponent, RMSE, Trend, TimeOnset, ExponentsOnset] = ...
    oscip.quantify_sleep_onset(OnsetExponents, Time(StartLastWake:EndDeepestSleep), MinEpochs);

% PreSleepSD = std(Exponents(1:dsearchn(Time', SleepOnset)), 1, 'omitnan');

EndWindow = dsearchn(Time', TimeOnset(end));
TrendAll = Trend(1)*ones(1, EndWindow);
TrendAll(dsearchn(Time', TimeOnset')) = Trend;
TrendAll(isnan(Exponents(1:EndWindow))) = nan;

residuals = Exponents(1:EndWindow) - TrendAll;
PreSleepSD = sqrt(mean(residuals.^2, 'omitnan'));

TradSleepOnset = Time(find(Scoring==-2, 1, 'first'));
end


function  [End, DeepestEpoch] = end_deepest_sleep2(Exponents, Scoring, MinEpochs)

N3Thresholds = quantile(Exponents, [.8 .99]);

Exponents = Exponents(1:find(Scoring==1, 1, 'first')); % only up until the first REM bout
EpochIndexes = 1:numel(Exponents);

DeepestEpoch = find(Exponents>N3Thresholds(2), 1, 'first'); % use quantile instead of absolute minimum in case of noise outliers

if isempty(DeepestEpoch)
    [~, DeepestEpoch] = max(Exponents);
end

EnoughDeepEpoch = DeepestEpoch+MinEpochs;
End = min(find(Exponents<N3Thresholds(1) & EpochIndexes>DeepestEpoch, 1, 'first')-1, EnoughDeepEpoch);
end

function Start = closest_wake2(Exponents, End, MinEpochs)


ExponentsFirstCycle = Exponents(1:End);
WakeThresholds = quantile(ExponentsFirstCycle, [.05 .3]);
ExponentIndexes = 1:numel(ExponentsFirstCycle);

MaxWake = find(ExponentsFirstCycle < WakeThresholds(1), 1, 'last');

if isempty(MaxWake)
    [~, MaxWake] = min(ExponentsFirstCycle);
end

EnoughWake = MaxWake-MinEpochs;
Start = max(find(ExponentsFirstCycle > WakeThresholds(2) & ExponentIndexes < MaxWake, 1, 'last')+1, EnoughWake);
if isempty(Start)
    Start = 1;
end
end


function [End, DeepestStage] = end_deepest_sleep(Scoring, Exponents, MinEpochs)

% find time of first N3
EpochIndexes = 1:numel(Scoring);
OverallDeepestStage = min(Scoring);
[Starts, Ends] = oscip.utils.data2windows(Scoring==OverallDeepestStage);
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
if any(N3Durations >= MinEpochs)
    End = Ends(find(N3Durations>=MinEpochs, 1, 'first'));
    return
end
[~, LargestBoutIdx] = max(N3Durations);
End = Ends(LargestBoutIdx);
end
