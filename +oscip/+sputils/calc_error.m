function model = calc_error(model)
% Calculate the error of the model fit
%
% INPUTS:
%   model : struct
%       Model object containing model settings and results
%
% OUTPUTS:
%   model : struct
%       Updated model object with error value
%
% This MATLAB implementation is based on the original FOOOF project:
% https://github.com/fooof-tools/fooof
% Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0)
% Translated to MATLAB by Claude Sonnet 3.7, corrected by Sophia Snipes,
% 2025.

if ~isfield(model, 'error_metric') || isempty(model.error_metric)
    warning('missing error metric, using default MAE')
    metric = 'MAE';
else
    metric = model.error_metric;
end


if isempty(model.modeled_spectrum)
    model.error = NaN;
    return;
end

% Calculate residuals
residuals = model.power_spectrum - model.modeled_spectrum;

% Calculate error based on specified metric
switch upper(metric)
    case 'MAE'
        % Mean Absolute Error (FOOOF default)
        model.error = mean(abs(residuals));

    case 'MSE'
        % Mean Squared Error
        model.error = mean(residuals.^2);

    case 'RMSE'
        % Root Mean Squared Error
        model.error = sqrt(mean(residuals.^2));
    otherwise
        warning('invalid error metric for specparam, leaving blank')
        model.error = nan;
end
end