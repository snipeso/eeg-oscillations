function CleanData = remove_data_by_intercept(Data, Intercepts, MinIntercept, MaxIntercept)
% CleanData = remove_data_by_intercept(Data, Intercepts, MinIntercept, MaxIntercept)
% Takes a Channel x Epoch x Frequency matrix of Data, and a Channel x Epoch
% intercepts matrix (output if fit_fooof_multidimentional), and sets to nan any
% values that are out of range.
% from eeg-oscillations, Snipes, 2024


CleanData = Data;
for ChannelIdx = 1:size(Data, 1)
    I = Intercepts(ChannelIdx, :);
    BadEpochs = I < MinIntercept | I> MaxIntercept | isnan(I);
    CleanData(ChannelIdx, BadEpochs, :) = nan;
end
