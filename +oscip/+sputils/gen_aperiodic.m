function ap_vals = gen_aperiodic(freqs, aperiodic_params, aperiodic_mode)
% Generate aperiodic values
%
% INPUTS:
%   freqs : 1d array
%       Frequency values to create aperiodic component for
%   aperiodic_params : array
%       Parameters that define the aperiodic component
%       Fixed mode: [offset, exponent]
%       Knee mode: [offset, knee, exponent]
%   aperiodic_mode : string
%       Which aperiodic fitting mode to use
%       Options: 'fixed' or 'knee'
%
% OUTPUTS:
%   ap_vals : 1d array
%       Values for aperiodic component at the input frequencies
%
% This MATLAB implementation is based on the original FOOOF project:
% https://github.com/fooof-tools/fooof
% Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0)
% Translated to MATLAB by Claude Sonnet 3.7, corrected by Sophia Snipes,
% 2025.



if strcmp(aperiodic_mode, 'fixed')
    % Fixed: offset, exponent [2 parameters]
    offset = aperiodic_params(1);
    exponent = aperiodic_params(2);
    ap_vals = offset - log10(freqs.^exponent);
elseif strcmp(aperiodic_mode, 'knee')
    % Knee: offset, knee, exponent [3 parameters]
    offset = aperiodic_params(1);
    knee = aperiodic_params(2);
    exponent = aperiodic_params(3);
    ap_vals = offset - log10(knee + freqs.^exponent);
else
    error('Unrecognized aperiodic mode: %s', aperiodic_mode);
end

end