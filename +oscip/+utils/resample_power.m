function [ResampledPower, ResampledFrequencies] = resample_power(Power, Frequencies, nFrequencies)
% Power can be a channel x epoch x freuquency

disp('Resampling power spectra')

Dims = size(Power);

ResampledFrequencies = linspace(Frequencies(1), Frequencies(end), nFrequencies);


ResampledPower = nan(Dims(1), Dims(2), numel(ResampledFrequencies));
for ChannelIdx = 1:Dims(1)
    for EpochIdx = 1:Dims(2)

        if all(isnan(Power(ChannelIdx, EpochIdx, :)))
            continue
        end
        ResampledPower(ChannelIdx, EpochIdx, :) = interp1(Frequencies, squeeze(Power(ChannelIdx, EpochIdx, :)), ResampledFrequencies, 'linear');

    end
end