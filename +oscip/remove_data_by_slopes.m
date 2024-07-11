function CleanData = remove_data_by_slopes(Data, Slopes, MinSlope, MaxSlope)
% CleanData = remove_data_by_slopes(Data, Slopes, MinSlope, MaxSlope)
% Takes a Channel x Epoch x Frequency matrix of Data, and a Channel x Epoch
% slopes matrix (output if fit_fooof_multidimentional), and sets to nan any
% values that are out of range.
% from eeg-oscillations, Snipes, 2024


CleanData = Data;
for ChannelIdx = 1:size(Data, 1)
    S = Slopes(ChannelIdx, :);
    BadEpochs = S < MinSlope | S> MaxSlope | isnan(S);
    CleanData(ChannelIdx, BadEpochs, :) = nan;
end
