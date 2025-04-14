% this is code to look at periodic power on continuous data. Uses a sliding
% window approach, so the signal is technically smeared in time, but it
% should be good for things like the infraslow.
% this code is slooow, so be judicious about what data you run it on

clear
clc
close all

Filepath = '\ExampleData';
Filename = 'P09_Sleep_NightPre.mat';

load(fullfile(cd, Filepath, Filename), 'EEG')

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

% run fooof
FittingRange = [3 45];
MaxError = .15;
MinRSquared  = .95;
[Slopes, Intercepts, FooofFrequencies, PeriodicPeaks, PeriodicPower, Errors, RSquared] ...
    = oscip.fit_fooof_multidimentional(SmoothResampled, ResampledFrequencies, FittingRange, MaxError, MinRSquared);

% plot
figure

% raw data
Ax1 = subplot(4, 1, 1);
t = linspace(0, size(EEG.data, 1)/EEG.srate, size(EEG.data, 1));
plot(t, EEG.data)
legend({EEG.chanlocs.labels})

% log power
Bands.Theta = [4 8];
Bands.Sigma = [11 15];
Bands.Iota = [30 35];

BandPower = oscip.utils.average_bands(log(SmoothResampled), Bands, ResampledFrequencies);
Ax2 = subplot(4, 1, 2);
plot(Time, squeeze(BandPower))
legend(fieldnames(Bands))

% periodic power
BandPeriodicPower = oscip.utils.average_bands(PeriodicPower, Bands, FooofFrequencies);
Ax3 = subplot(4, 1, 3);
plot(Time, BandPeriodicPower)
legend(fieldnames(Bands))

% slope
Ax4 = subplot(4, 1, 4);
plot(Time, squeeze(Slopes))

xlabel('Time (s)')
linkaxes([Ax1, Ax2, Ax3, Ax3], 'x')

