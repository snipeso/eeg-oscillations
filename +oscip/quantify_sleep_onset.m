function  [SleepOnset, OnsetSpeed, WakeSlope, N3Slope, Trend, Time, Slopes] = quantify_sleep_onset(Slopes, Time, MinEpochs)
% This assumes that the recording starts with wake, and finds the first
% instance of sleep onset. Ideally, don't provide more data than the first
% cycle, otherwise it will not be happy
arguments
    Slopes
    Time
    MinEpochs = 5;
end

isNan = isnan(Slopes);
Slopes(isNan) = [];
Time(isNan) = [];

if numel(Slopes) < MinEpochs
    WakeSlope = nan;
    N3Slope = nan;
    SleepOnset = nan;
    OnsetSpeed = nan;

    Trend = nan(size(Slopes));
    warning('not enough data for sleep onset properties')
    return
end

% fit sigmoid function
[param,stat]= oscip.external.sigm_fit(Time, Slopes);

WakeSlope = param(1);
N3Slope = param(2);
SleepOnset = param(3);
OnsetSpeed = param(4);

Trend = stat.ypred;