function SmoothPower = smooth_spectrum(Power, Frequencies, SmoothSpan)
% SmoothPower = smooth_spectrum(Power, Frequencies, SmoothSpan)
% function for smoothing data. Power can be either a Channel x Epoch x
% Frequency matrix, or an N x Frequency matrix.
%
% % Code by Sophia Snipes, 2024, for eeg-oscillations.
Power = oscip.utils.standardize_power_dimentions(Power, Frequencies);
Dims = size(Power);

SmoothPower = nan(Dims);
switch numel(Dims)
    case 2 % Ch x E
        for ChannelIdx = 1:Dims(1)
            SmoothPower(ChannelIdx,  :) = smooth_single_spectrum(...
                Power(ChannelIdx, :), Frequencies, SmoothSpan);
        end
    case 3 % Ch x E x F
        for ChannelIdx = 1:Dims(1)
            for EpochIdx = 1:Dims(2)
                SmoothPower(ChannelIdx, EpochIdx, :) = smooth_single_spectrum(...
                    squeeze(Power(ChannelIdx, EpochIdx, :)), Frequencies, SmoothSpan);
            end
        end
    otherwise
        error('Incorrect dimentions for Power matrix')
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% functions


function SmoothPower = smooth_single_spectrum(Power, Frequencies, SmoothSpan)
% Data is a 1 x Freqs matrix

FreqRes = Frequencies(2)-Frequencies(1);
SmoothPoints = round(SmoothSpan/FreqRes);
SmoothPower = smooth(Power, SmoothPoints, 'lowess');
end