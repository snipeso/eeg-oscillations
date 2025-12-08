function  [SleepOnset, OnsetSpeed, WakeExponent, N3Exponent, RMSE, Trend, Time, Exponents] = ...
    quantify_sleep_onset(Exponents, Time, MinEpochs)
% This assumes that the recording starts with wake, and finds the first
% instance of sleep onset. Ideally, don't provide more data than the first
% cycle, otherwise it will not be happy
arguments
    Exponents
    Time
    MinEpochs = 5;
end

isNan = isnan(Exponents);
Exponents(isNan) = [];
Time(isNan) = [];

if numel(Exponents) < MinEpochs
    WakeExponent = nan;
    N3Exponent = nan;
    SleepOnset = nan;
    OnsetSpeed = nan;

    Trend = nan(size(Exponents));
    warning('not enough data for sleep onset properties')
    return
end

% fit sigmoid function
[param,stat]= oscip.external.sigm_fit(Time, Exponents);

WakeExponent = param(1);
N3Exponent = param(2);
SleepOnset = param(3);
OnsetSpeed = param(4);


Trend = stat.ypred;

if SleepOnset < Time(1)
    error('too early an onset')
    SleepOnset = nan;
    OnsetSpeed = nan;
    RMSE= nan;
end

residuals = Exponents(:) - Trend(:);
RMSE = sqrt(mean(residuals.^2));