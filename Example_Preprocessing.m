% Simple Preprocessing Example
% Uses sleep-prep (sprep) and eeg-oscillations (oscip) repositories

% Set parameters
LineNoise = 50;
EpochLength = 30;

%% Load in file

Filepath = '';
load(Filepath, 'EEG', 'Scoring', 'Time') % EEG is an EEGLAB structure, Scoring is an array of scoring indices per epoch, and time a vector indicating the score times in the night
%
badchannels = [129]; % indices of channels that aren't EEG signal; if there's a blank reference channel like129, remove at this stage, it will be added back later

EEG = pop_select(EEG, 'nochannel', badchannels);

%% Detect artefacts in time domain

% process EEG just enough to focus just on artifacts in ranges of interest
EEG_arti = pop_eegfiltnew(EEG, 0.5, []); % filter to frequency range of interest; this is so big artifact detection detects artefacts in relevant ranges
EEG_arti = sprep.eeg.line_filter(EEG_arti, LineNoise, false); % same, ignore artifacts that are just from excessive line noise. NB: this could be done directly on the EEG, but for fairness with other analyses, these mods to the EEG are only for the artefact detection


% detect artefacts by the sample point, using default thresholds
ArtefactsBig = sprep.detect.big_artefacts(EEG_arti);
ArtefactsFlat = sprep.detect.flatishlines(EEG_arti);
ArtefactsDisconnected = sprep.detect.disconnected_channels(EEG_arti, EpochLength);

% set the really big artefacts to zero because they can spread their evil
% to other channels during rereferencing for later artefact detection
% based on average reference (for when final analysis is average reference)
EEG_arti = sprep.eeg.zero_artefacts(EEG_arti, ArtefactsBig);
ArtefactsMuscle = sprep.detect.muscle_bursts(EEG_arti);

% assemble artefact info
AllArtefacts = {ArtefactsMuscle, ArtefactsBig,  ArtefactsFlat, ArtefactsDisconnected};
ArtefactLabels = {'Muscle',  'Big', 'Flat', 'Unplugged'};
AllArtefactsDS = sprep.resample_artefacts(AllArtefacts, EEG.srate, EpochLength, size(EEG.data, 2), TotEpochs);
ActualArtefacts = sprep.merge_artefacts(AllArtefactsDS);


%% plot artefact diagnostics
sprep.diagnose.removed_data(AllArtefacts, ArtefactLabels, Time*60*60, Destination, ['Artefacts', File]);

figure('Units','centimeters', 'Position',[0 0 6 6])
nArtefacts = sum(Artefacts, 2)./size(Artefacts, 2);
chART.plot.eeglab_topoplot(nArtefacts, Chanlocs)




%% Light processing

EEG = sprep.eeg.add_cz(EEG);

% set artefacts to nan so they don't affect rereferencing
EEG = sprep.eeg.zero_artefacts(EEG, Artefacts, nan, EpochLength);

% rereference to average
EEG.data = EEG.data - mean(EEG.data, 1, 'omitnan');



%% Compute spectral power


% calculate power
WindowLength = 4;
Overlap = .5;
[EpochPower, Frequencies] = oscip.compute_power_on_epochs(EEG.data, ...
    EEG.srate, EpochLength, WindowLength, Overlap, false);

% check if scoring has different number of epochs than actual EEG
[Scoring, nExtra] = oscip.utils.fix_off_by_one_scoring(Scoring, size(EpochPower, 2), 2);

if nExtra>0
    Time(:, end+nExtra) = Time(end)+Time(2);
    Artefacts(:, end+nExtra) = true;
elseif nExtra<0
    Time = Time(1:end+nExtra);
    Artefacts = Artefacts(:, 1:end+nExtra);
end

MedianSmoothSpan = 3;
MeanSmoothSpan = 2;

% smooth signal so FOOOF works more smoothly
SmoothPower = oscip.smooth_spectrum_median(EpochPower, Frequencies, MedianSmoothSpan); % this also jumps over quick spikes in the power spectrum from small types of line noise
SmoothPower = oscip.smooth_spectrum(SmoothPower, Frequencies, MeanSmoothSpan); % better for fooof if the spectra are smooth, since it needs to fit fewer gaussians

%% run specparam

FrequencyRange = [2 45];

AdditionalParameters = struct();
AdditionalParameters.peak_width_limits = [0.5 20];

[Exponents, Offsets, FrequenciesPeriodic, PeriodicPeaks, PeriodicPower, Errors, RSquared] ...
    = oscip.fit_fooof_multidimentional_matlab(SmoothPower, Frequencies, FrequencyRange, AdditionalParameters);


Parameters.FOOOF.RangeExponents = [0.5 4];
Parameters.FOOOF.RangeOffsets = [-1 5];
Parameters.FOOOF.MaxError = .15;
Parameters.FOOOF.MinRSquared = .95;
Parameters.FOOOF.ExponentVarianceThreshold = 0.6;
Parameters.FOOOF.peak_width_limits = [.5 20];


BadExponents = oscip.utils.exclude_range(Exponents, ParametersFOOOF.RangeExponents);
BadOffsets = oscip.utils.exclude_range(Offsets, ParametersFOOOF.RangeOffsets);
BadR = oscip.utils.exclude_range(RSquared, [ParametersFOOOF.MinRSquared, nan]);
BadError = oscip.utils.exclude_range(Errors, [nan, ParametersFOOOF.MaxError]);

ActualArtefacts = BadExponents | BadOffsets | BadR | BadError;

ExponentOutliers = oscip.detect.outlier_exponents(Exponents, ParametersFOOOF.ExponentVarianceThreshold, ActualArtefacts); % outliers once already removed artefacts
ActualArtefacts = ActualArtefacts | ExponentOutliers;

CorrelationOutliers = oscip.detect.uncorrelated_exponents_from_offsets(Offsets, Exponents, ParametersFOOOF.zResidualThreshold, ActualArtefacts);
ActualArtefacts = ActualArtefacts | CorrelationOutliers;

AllArtefacts = {BadExponents, BadOffsets, BadR, BadError, ExponentOutliers, CorrelationOutliers};
ArtefactLabels = {'Exponents', 'Offsets', 'R', 'Error', 'ExpOutliers', 'CorrOutliers'};


Artefacts = PowerStruct.Artefacts | ActualArtefactsSpec;


%% polish up artefact selection a bit

% remove clean data if it's a small gap in between artefacts
MinGapEpochs = 2;
Artefacts = sprep.close_channel_gaps(Artefacts, MinGapEpochs);

% remove all of channel if there's not enough clean data
MinEpochs = 60;
Artefacts(sum(~Artefacts, 2)<MinEpochs, :) = true;


% identify epochs where channels don't have enough clean neighbors
Artefacts = sprep.adjust_artefacts_for_holes(Artefacts, EEG.chanlocs);

% remove epochs without enough channels
MaxChannelsToInterpolate = 20;
Artefacts(:, sum(Artefacts, 1)>MaxChannelsToInterpolate) = true;
