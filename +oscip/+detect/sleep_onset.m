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
MinEpochs = 5;
SmoothExponents = 10;
end

% find deepest point of N3 between start of recording and first REM episode
if ~any(Scoring<0)
    warning("This poor person didn't sleep at all")
    TradSleepOnset = nan;
    SleepOnset = nan;
    OnsetSpeed = nan;
    WakeExponent = nan;
    N3Exponent = nan;
    Trend = nan;
    TimeOnset = nan;
    Exponents = nan;
    return
elseif ~any(Scoring==1)
else 
FirstREM = find(Scoring==1, 1, 'first');
[~, MaxSleepDepthTime] = max(smooth(Exponents(1:FirstREM), SmoothExponents));
end

% find first epoch that exits this deepest sleep
ScoringIndexes = 1:numel(Scoring);
EndSleepOnset = find(Scoring>-3 & ScoringIndexes>MaxSleepDepthTime, 1, 'first');

[SleepOnset, OnsetSpeed, WakeExponent, N3Exponent, RMSE, Trend, TimeOnset, ExponentsOnset] = ...
    oscip.quantify_sleep_onset(Exponents(1:EndSleepOnset), Time(1:EndSleepOnset), MinEpochs);



TradSleepOnset = Time(find(Scoring==-2,1, 'first'));
