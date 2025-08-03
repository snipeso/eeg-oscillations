function CleanData = remove_data_by_exponent(Data, Exponents, MinExponent, MaxExponent)
% CleanData = remove_data_by_Exponents(Data, Exponents, MinExponent, MaxExponent)
% Takes a Channel x Epoch x Frequency matrix of Data, and a Channel x Epoch
% Exponents matrix (output if fit_fooof_multidimentional), and sets to nan any
% values that are out of range.
% from eeg-oscillations, Snipes, 2024


CleanData = Data;
for ChannelIdx = 1:size(Data, 1)
    S = Exponents(ChannelIdx, :);
    BadEpochs = S < MinExponent | S> MaxExponent | isnan(S);
    CleanData(ChannelIdx, BadEpochs, :) = nan;
end
