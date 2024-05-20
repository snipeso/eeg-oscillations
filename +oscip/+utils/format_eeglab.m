function EEG = format_eeglab(Data, SampleRate)

EEG = struct();
EEG.data = Data;
EEG.srate = SampleRate;

EEG.chanlocs = [];
EEG.xmax = size(Data, 2)/EEG.srate;
EEG.xmin = 0;
EEG.trials = 1;
EEG.pnts = size(EEG.data, 2);
EEG.nbchan = size(EEG.data, 1);
EEG.event = [];
EEG.setname = '';
EEG.icasphere = '';
EEG.icaweights = '';
EEG.icawinv = '';
EEG.etc = [];