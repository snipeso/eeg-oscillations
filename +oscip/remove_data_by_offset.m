function CleanData = remove_data_by_offset(Data, Offsets, MinOffset, MaxOffset)
% CleanData = remove_data_by_Offset(Data, Offsets, MinOffset, MaxOffset)
% Takes a Channel x Epoch x Frequency matrix of Data, and a Channel x Epoch
% Offsets matrix (output if fit_fooof_multidimentional), and sets to nan any
% values that are out of range.
% from eeg-oscillations, Snipes, 2024


CleanData = Data;
for ChannelIdx = 1:size(Data, 1)
    I = Offsets(ChannelIdx, :);
    BadEpochs = I < MinOffset | I> MaxOffset | isnan(I);
    CleanData(ChannelIdx, BadEpochs, :) = nan;
end
