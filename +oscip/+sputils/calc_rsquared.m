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

if isempty(model.modeled_spectrum_)
    model.r_squared_ = NaN;
    return;
end

% Calculate R^2
r_val = corrcoef(model.power_spectrum, model.modeled_spectrum_);
model.r_squared_ = r_val(1, 2) ^ 2;

end