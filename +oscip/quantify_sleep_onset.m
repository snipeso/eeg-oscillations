function  [SleepOnset, OnsetSpeed, WakeSlope, N3Slope, Trend] = quantify_sleep_onset(Slopes, Time)
% This assumes that the recording starts with wake, and finds the first
% instance of sleep onset. Ideally, don't provide more data than the first
% cycle, otherwise it will not be happy

% fit sigmoid function
[param,stat]=sigm_fit(Time, Slopes);

WakeSlope = param(1);
N3Slope = param(2);
SleepOnset = param(3);
OnsetSpeed = param(4);

Trend = stat.ypred;