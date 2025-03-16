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



if isempty(model.modeled_spectrum_)
    model.error_ = NaN;
    return;
end

% Calculate MSE
model.error_ = mean((model.power_spectrum - model.modeled_spectrum_).^2);

end