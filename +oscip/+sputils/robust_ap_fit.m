function aperiodic_params = robust_ap_fit(model)
% Fit the aperiodic component of the power spectrum robustly, ignoring outliers
%
% INPUTS:
%   model : struct
%       Model object containing model settings and results
%
% OUTPUTS:
%   aperiodic_params : array
%       Parameters for aperiodic fit (offset, exponent) or (offset, knee, exponent)

freqs = model.freqs;
power_spectrum = model.power_spectrum;

% Do a quick, initial aperiodic fit
popt = sputils.simple_ap_fit(model, power_spectrum);
initial_fit = sputils.gen_aperiodic(freqs, popt, model.aperiodic_mode);

% Flatten power_spectrum based on initial aperiodic fit
flatspec = power_spectrum - initial_fit;

% Flatten outliers, defined as any points that drop below 0
flatspec(flatspec < 0) = 0;

% Use percentile threshold to extract and re-fit
perc_thresh = prctile(flatspec, model.ap_percentile_thresh * 100);
perc_mask = flatspec <= perc_thresh;
freqs_ignore = freqs(perc_mask);
spectrum_ignore = power_spectrum(perc_mask);

% If we have enough points to fit
if length(freqs_ignore) > 2
    % Second aperiodic fit - using results of first fit as guess parameters
    model_ignore = model;
    model_ignore.freqs = freqs_ignore;
    aperiodic_params = sputils.simple_ap_fit(model_ignore, spectrum_ignore);
else
    % If too few points for robust fit, fall back to simple fit
    aperiodic_params = popt;
end

end