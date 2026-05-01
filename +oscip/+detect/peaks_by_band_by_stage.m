function [PeaksByStageByBand, StagePower, Frequencies] = ...
    peaks_by_band_by_stage(StagePower, Frequencies, Bands, MinPeakProminance, MinPeakDistance, MinChannels, MaxDiffFrequency, MaxDiffAmplitude)
arguments
    StagePower % should be channel x stage x frequency
    Frequencies
    Bands
    MinPeakProminance = .01;
    MinPeakDistance = 1;
    MinChannels = 4;
    MaxDiffFrequency = 0.5; % Hz
    MaxDiffAmplitude = 1/2;
end

% make sure dimentions are all ok
Dims = size(StagePower);

if numel(Dims)==2
    StagePower = permute(StagePower, [3 1 2]);
end

% find all the peaks in all the spectra
PeaksTable = table();
for ChannelIdx = 1:Dims(1)
    for StageIdx = 1:Dims(2)

        PeakRow = detected_peaks_row(squeeze(StagePower(ChannelIdx, StageIdx, :))', ...
            Frequencies, MinPeakProminance, MinPeakDistance, ChannelIdx, StageIdx);
        PeaksTable = cat(1, PeaksTable, PeakRow);
    end
end

% find largest peak in each band
BandLabels = fieldnames(Bands);
PeaksByStageByBand = nan(Dims(2), numel(BandLabels), 5);
for StageIdx = 1:Dims(2)
    for BandIdx = 1:numel(BandLabels)

        Peaks = select_peaks_in_stage_band(PeaksTable, Bands.(BandLabels{BandIdx}), StageIdx);

        % if StageIdx==5 && BandIdx==5
        %     A=1;
        % end

        PeaksByStageByBand(StageIdx, BandIdx, :) = select_largest_peak(Peaks, MinChannels, MaxDiffFrequency, MaxDiffAmplitude);


    end
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% functions

function PeakRow = detected_peaks_row(PeriodicPower, FrequenciesPeriodic, MinPeakProminance, MinPeakDistance, ChannelIdx, ScoringIdx)
% just for finding the peak frequency, adjust so that all values are
% above 0
% AdjustedPower = PeriodicPower- min(quantile(PeriodicPower, .1), 0); % Legacy approach to shift power

[pks, locs, w, p] = oscip.detect.peaks(PeriodicPower, FrequenciesPeriodic, MinPeakProminance, MinPeakDistance);

% % re-calculate amplitudes (LEGACY)
% pks = PeriodicPower(ismember(FrequenciesPeriodic, locs)); % no longer uses adjusted spectra, so that values are more comparable across channels later

PeakRow = table();
PeakRow.Frequency = locs';
PeakRow.Amplitude = pks';
PeakRow.Bandwidth = w';
PeakRow.Prominance = p';
PeakRow.Channel =  repmat(ChannelIdx, numel(pks), 1);
PeakRow.Stage = repmat(ScoringIdx, numel(pks), 1);
end

function Peaks = select_peaks_in_stage_band(PeaksTable, Range, ScoringIndex)

Peaks = PeaksTable(PeaksTable.Stage== ScoringIndex & ...
    PeaksTable.Frequency >= Range(1) & PeaksTable.Frequency < Range(2), :);
end


function Peak = select_largest_peak(PeaksTable, MinChannels, MaxDiffFrequency, MaxDiffAmplitude)

Peak = nan(1, 5);
PeaksTable = sortrows(PeaksTable, 'Amplitude', 'descend');

while isnan(Peak(1)) && size(PeaksTable, 1) > MinChannels
    PeakCandidate = table2array(PeaksTable(1, {'Frequency', 'Amplitude', 'Bandwidth', 'Prominance', 'Channel'}));
    PeaksTable(1, :) = []; % remove highest peak from pool

    % check that there's peaks with the same frequency and close enough
    % amplitude
    PTClose = abs(PeaksTable.Frequency-PeakCandidate(1))<=MaxDiffFrequency & ...
        (PeakCandidate(2)-PeaksTable.Amplitude)./PeakCandidate(2) <= MaxDiffAmplitude;

    if nnz(PTClose) >= MinChannels
        Peak = PeakCandidate;
    end
end
end


