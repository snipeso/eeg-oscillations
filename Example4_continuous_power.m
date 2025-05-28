% this is code to look at periodic power on continuous data. Uses a sliding
% window approach, so the signal is technically smeared in time, but it
% should be good for things like the infraslow.
% this code is slooow, so be judicious about what data you run it on

clear
clc
close all

Filepath = '\ExampleData';
Filename = 'P09_Sleep_NightPre.mat';

load(fullfile(cd, Filepath, Filename), 'EEG','Scoring')

% select only necessary channels
EEG = pop_select(EEG, 'channel', [2 5]); % select central channels

% calculate power
WindowLength = 30; % in seconds
TimeResolution = 1; % in seconds
[Power, Frequencies, Time] = oscip.continuous_fft(EEG.data, EEG.srate, WindowLength, TimeResolution);

% average power (optional, again to save time)
Power = mean(Power, 1);

% smooth power (reeeally important, since step before uses pure FFT instead
% of p-welch, so its hideous). Median smoother is fast.
SmoothSpan = 1; % in Hz.
SmoothPower = oscip.smooth_spectrum_median(Power, Frequencies, SmoothSpan);

% resample power, to make Fooof and other computations faster
nFrequencies = 500;
[ResampledPower, ResampledFrequencies] = oscip.utils.resample_power(SmoothPower, Frequencies, nFrequencies);


% Smooth signal a lot before fooof
SmoothSpan = 5; % somewhere between 3 and 5
SmoothResampled = oscip.smooth_spectrum(ResampledPower, ResampledFrequencies, SmoothSpan);

%%
% run fooof
FittingRange = [3 45];
MaxError = .15;
MinRSquared  = .95;
[Slopes, Intercepts, FooofFrequencies, PeriodicPeaks, PeriodicPower, Errors, RSquared] ...
    = oscip.fit_fooof_multidimentional(SmoothResampled, ResampledFrequencies, FittingRange, MaxError, MinRSquared);


%%
MaxArtefacts = 1;
RangeSlopes = [0 4];
RangeIntercepts = [0 5];

 PeriodicPower = oscip.keep_only_clean_epochs(PeriodicPower, Slopes, Intercepts, RSquared, Errors, ...
            RangeSlopes, RangeIntercepts, MinRSquared, MaxError, [], MaxArtefacts);
  Slopes = oscip.keep_only_clean_epochs(Slopes, Slopes, Intercepts, RSquared, Errors, ...
            RangeSlopes, RangeIntercepts, MinRSquared, MaxError, [], MaxArtefacts);


%%

EEG = pop_eegfiltnew(EEG, .5);
EEG = pop_eegfiltnew(EEG, [], 45);

%%
% plot
figure

% raw data
Ax1 = subplot(4, 1, 1);
t = linspace(0, size(EEG.data, 2)/EEG.srate, size(EEG.data, 2));

plot(t, EEG.data)
legend({EEG.chanlocs.labels})


% log power
Bands.Theta = [4 8];
Bands.Sigma = [11 15];
Bands.Iota = [30 35];

BandPower = oscip.utils.average_bands(log(SmoothResampled), Bands, ResampledFrequencies);
Ax2 = subplot(5, 1, 2);
plot(Time, squeeze(BandPower))
legend(fieldnames(Bands))

% periodic power
BandPeriodicPower = oscip.utils.average_bands(PeriodicPower, Bands, FooofFrequencies);
Ax3 = subplot(5, 1, 3);
Data = oscip.smooth_spectrum(permute(BandPeriodicPower, [3 2 1]),Time, 10);
plot(Time, Data)
legend(fieldnames(Bands))

% slope
Ax4 = subplot(5, 1, 4);
Data = squeeze(oscip.smooth_spectrum(Slopes,Time, 10));
plot(Time, Data)
legend({'Slopes'})

% scoring
Ax5 = subplot(5, 1, 5);
THypno = linspace(0, numel(Scoring)*20, numel(Scoring));
plot(THypno, Scoring)
xlabel('Time (s)')
linkaxes([Ax1, Ax2, Ax3, Ax4, Ax5], 'x')

