function FooofModel = specparam_matlab(Frequencies, Power, FittingFrequencyRange, AdditionalParameters)


settings = oscip.sputils.check_settings(AdditionalParameters);


FooofModelOrig = oscip.specparam(Power', double(Frequencies), settings);

