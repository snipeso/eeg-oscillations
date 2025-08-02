function model = calc_rsquared(model)
% Calculate the r-squared value between the original and modeled power spectra
%
% INPUTS:
%   model : struct
%       Model object containing model settings and results
%
% OUTPUTS:
%   model : struct
%       Updated model object with r-squared value
%
% This MATLAB implementation is based on the original FOOOF project:
% https://github.com/fooof-tools/fooof
% Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0)
% Translated to MATLAB by Claude Sonnet 3.7, NOTcorrectedYET by Sophia Snipes,
% 2025.

if isempty(model.modeled_spectrum)
    model.r_squared = NaN;
    return;
end

% Calculate R^2
r_val = corrcoef(model.power_spectrum, model.modeled_spectrum);
model.r_squared = r_val(1, 2) ^ 2;

end