function SpecModel = specparam(power_spectrum, freqs, params)
% SPECPARAM Parameterizes a power spectrum as combination of aperiodic and periodic components
%
% USAGE:
%   SpecModel = specparam(power_spectrum, freqs, params)
%
% INPUTS:
%   power_spectrum : 1d array
%       Power values for the spectrum, which must be input in linear space.
%   freqs : 1d array
%       Frequency values for the power spectrum.
%   params : struct, optional
%       Parameters for model fitting. Fields include:
%           peak_width_limits : 2-element array, default: [0.5, 12]
%               Limits on possible peak width, in Hz, as [lower_bound, upper_bound].
%           max_n_peaks : numeric, default: Inf
%               Maximum number of peaks to fit.
%           min_peak_height : numeric, default: 0
%               Absolute threshold for detecting peaks in the spectrum.
%           peak_threshold : numeric, default: 2
%               Relative threshold for detecting peaks (in standard deviations).
%           aperiodic_mode : string, default: 'fixed'
%               Which approach to take for fitting the aperiodic component.
%               Options: 'fixed' or 'knee'
%           verbose : numeric, default: 1
%               Whether to print out status updates.
%
% OUTPUTS:
%   SpecModel : struct
%       A structure with the model fit results and parameters.
%
% WARNING: frequency and power values inputs must be in linear space.
%          Passing in logged frequencies and/or power spectra will produce incorrect results.
%
% This MATLAB implementation is based on the original FOOOF project:
% https://github.com/fooof-tools/fooof
% Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0)
% Translated to MATLAB by Claude Sonnet 3.7, NOTcorrectedYET by Sophia Snipes,
% 2025.



% Set default parameters if not provided
if nargin < 3 || isempty(params)
    params = struct();
end

% Initialize model parameters with defaults
model = oscip.sputils.init_model_params(params);

% Select frequencies and power, depending on specified frequency range
if isempty(model.freq_range)
    model.freq_range = [min(freqs), max(freqs)];
end

range = [find(freqs>=model.freq_range(1), 1, 'first'), find(freqs<=model.freq_range(2), 1, 'last')];
model.freqs = freqs(range(1):range(2));
model.power_spectrum = log10(power_spectrum(range(1):range(2)));

model.freq_res = freqs(2) - freqs(1);

% Check for issues with frequency resolution vs. peak width limits
if model.verbose && 1.5 * model.freq_res >= model.peak_width_limits(1)
    fprintf(['Warning: Lower-bound peak width limit is close to the frequency resolution.\n' ...
        'This may lead to suboptimal fits.\n' ...
        'Current settings: frequency resolution is %1.2f & lower bound is %1.2f\n'], ...
        model.freq_res, model.peak_width_limits(1));
end

% Run model fit
SpecModel = oscip.sputils.fit_model(model);
end