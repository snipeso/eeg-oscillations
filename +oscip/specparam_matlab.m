function FooofModel = specparam_matlab(Frequencies, Power, FittingFrequencyRange, AdditionalParameters)
arguments
    Frequencies
    Power
    FittingFrequencyRange = [min(Frequencies), max(Frequencies)]
    AdditionalParameters = struct()
end
%  FooofModel = specparam_matlab(Frequencies, Power, FittingFrequencyRange, AdditionalParameters)
%
% This is just a little friendly wrapper for the specparam code, asking for
% power and frequencies, running some checks, then running oscip.specparam.
% It basically just skips having to figure out the specapram settings
% structure.
% 
% By Sophia Snipes, 2025, for eeg-oscillations

settings = oscip.sputils.check_settings(AdditionalParameters);
settings.freq_range = FittingFrequencyRange;

Dims = size(Power);
if numel(Dims)>2 || ~any(Dims==1)
    error('power spectrum wrong for specparam')
end


FooofModel = oscip.specparam(double(Power(:))', double(Frequencies), settings);
