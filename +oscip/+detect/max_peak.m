function [Peak, isHarmonic] = max_peak(Power, Frequencies, ...
    Band, ExcludeHarmonics, FittingFrequencyRange, MinPeakProminance, ...
    HarmonicsRange, HarmonicsMultiplier, AdditionalParameters)
% power is 1 x Frequency
arguments
    Power
    Frequencies
    Band
    ExcludeHarmonics = false;
    FittingFrequencyRange = [2 45];
    MinPeakProminance = .001;
    HarmonicsRange = 0.25; % Hz; lower frequencies have to be within +/- this range to consider the target frequency a harmonic
    HarmonicsMultiplier = 2;
    AdditionalParameters = struct();
end

if isempty(AdditionalParameters)
    AdditionalParameters = struct();
    AdditionalParameters.peak_width_limits = [0.5 20];
    AdditionalParameters.min_peak_height = .01;
end

Peak = nan(1, 4);
isHarmonic = nan;

[~, ~, FrequenciesPeriodic, ~, PeriodicPower] ...
    = oscip.fit_fooof_matlab(Power, Frequencies, FittingFrequencyRange, AdditionalParameters);
[pks, locs, w, p] = findpeaks(PeriodicPower, FrequenciesPeriodic, 'MinPeakProminence', MinPeakProminance);

% find prototype
[PeaksAmplitude, PeaksFrequency, PeaksWidth, PeaksProminance] = peaks_in_band(pks, locs, w, p, Band);
[~, MaxFreq] = max(PeaksProminance);

if isempty(MaxFreq)
    return
end

Frequency = PeaksFrequency(MaxFreq);

if ~ExcludeHarmonics

    pksH1 = peaks_in_band(pks, locs, w, p, Frequency/2 + [-HarmonicsRange HarmonicsRange]);
    pksH2 = peaks_in_band(pks, locs, w, p, Frequency/3 + [-HarmonicsRange HarmonicsRange]);
    Harmonics = [pksH1, pksH2];

    if any(Harmonics > HarmonicsMultiplier*PeaksAmplitude(MaxFreq))
        isHarmonic = true;
        return
    end

    isHarmonic = false;
end

Peak(1) = Frequency;
Peak(2) = PeaksAmplitude(MaxFreq);
Peak(3) = PeaksWidth(MaxFreq);
Peak(4) = PeaksProminance(MaxFreq);
end


function [pks, locs, w, p] = peaks_in_band(pks, locs, w, p, Range)
rm = locs<Range(1) | locs > Range(2);
pks(rm) = [];
locs(rm) = [];
p(rm) = [];
w(rm) = [];
end

