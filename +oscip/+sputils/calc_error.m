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

if isempty(model.modeled_spectrum_)
    model.error_ = NaN;
    return;
end

% Calculate MSE
model.error_ = mean((model.power_spectrum - model.modeled_spectrum_).^2);

end