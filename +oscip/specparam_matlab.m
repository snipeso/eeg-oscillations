function FooofModel = specparam_matlab(Frequencies, Power, FittingFrequencyRange, AdditionalParameters)
arguments
    Frequencies
    Power
    FittingFrequencyRange = [min(Frequencies), max(Frequencies)]
    AdditionalParameters = oscip.default_settings()
end


settings = oscip.sputils.check_settings(AdditionalParameters);
settings.freq_range = FittingFrequencyRange;

Dims = size(Power);
if numel(Dims)>2 || ~any(Dims==1)
    error('power spectrum wrong for specparam')
end


FooofModel = oscip.specparam(double(Power(:))', double(Frequencies), settings);
