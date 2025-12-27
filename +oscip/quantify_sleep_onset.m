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
    RMSE = nan;
    Trend = nan(size(Exponents));
    Exponents = nan(size(Time));
    warning('not enough data for sleep onset properties')
    return
end

Npad = numel(Time);
dt = Time(2) - Time(1);

Time_pad = [Time(1)-dt*(Npad:-1:1)'; Time(:); Time(end)+dt*(1:Npad)'];

ExponentsSmooth = movmean(Exponents, MinEpochs, 'omitnan');

MinPad = min(ExponentsSmooth);
MaxPad = max(ExponentsSmooth);
% MinPad = quantile(Exponents, .01);
% MaxPad = quantile(Exponents, .99);

% 
Exponents_pad = [repmat(MinPad,Npad,1);
                  Exponents(:);
                  repmat(MaxPad,Npad,1)];


% fit sigmoid function
[param,stat]= oscip.external.sigm_fit(Time_pad, Exponents_pad);

WakeExponent = param(1);
N3Exponent = param(2);
SleepOnset = param(3);
OnsetSpeed = param(4);


% Remove padding from predicted trend
Trend = stat.ypred(Npad+1 : Npad+numel(Exponents));

if SleepOnset < Time(1)
    warning('too early an onset')
    SleepOnset = nan;
    OnsetSpeed = nan;
    RMSE= nan;
    return
elseif SleepOnset>Time(end)
    warning('too late an onset')
    SleepOnset = nan;
    OnsetSpeed = nan;
    RMSE= nan;
    return
end

residuals = Exponents(:) - Trend(:);
RMSE = sqrt(mean(residuals.^2, 'omitnan'));
% RMSE = median(abs(residuals), 'omitnan');