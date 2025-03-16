function FooofModel = specparam_matlab(Frequencies, Power, FittingFrequencyRange, AdditionalParameters)


settings = oscip.sputils.check_settings(AdditionalParameters);
settings.freq_range = FittingFrequencyRange;

FooofModel = oscip.specparam(Power', double(Frequencies), settings);
