function Topography = interpolate_topography(Topography, Chanlocs, RemoveChannels)


if size(Topography, 1) ~= numel(Chanlocs)
    error('Wrong topography dimentions');
end

EEG = oscip.utils.format_eeglab(Topography, 1);
EEG.chanlocs = Chanlocs;
EEG.chanlocs(RemoveChannels) = [];
EEG.data(RemoveChannels, :) = [];
EEG= eeg_checkset(EEG);

EEG = pop_interp(EEG, Chanlocs);

Topography = EEG.data;