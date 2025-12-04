function [PeaksByStageByBand, StagePower, Frequencies] = ...
    peaks_by_band_by_stage(StagePower, Frequencies, Bands, MinPeakProminance, MinPeakDistance)
arguments
    StagePower % should be channel x stage x frequency
    Frequencies   
    Bands 
    MinPeakProminance = .01;
    MinPeakDistance = 1;
   
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

        PeakRow = detect_peaks(squeeze(StagePower(ChannelIdx, StageIdx, :))', ...
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
        PeaksByStageByBand(StageIdx, BandIdx, :) = select_largest_peak(Peaks);
    end
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% functions

function PeakRow = detect_peaks(PeriodicPower, FrequenciesPeriodic, MinPeakProminance, MinPeakDistance, ChannelIdx, ScoringIdx)
% just for finding the peak frequency, adjust so that all values are
% above 0
AdjustedPower = PeriodicPower- min(quantile(PeriodicPower, .1), 0);

[~, locs, w, p] = oscip.detect.peaks(AdjustedPower, FrequenciesPeriodic, MinPeakProminance, MinPeakDistance);

% % re-calculate amplitudes
pks = PeriodicPower(ismember(FrequenciesPeriodic, locs)); % no longer uses adjusted spectra, so that values are more comparable across channels later

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


function Peak = select_largest_peak(PeaksTable)


if ~isempty(PeaksTable)
    Peaks = sortrows(PeaksTable, 'Amplitude', 'descend');

    Peak = table2array(Peaks(1, {'Frequency', 'Amplitude', 'Bandwidth', 'Prominance', 'Channel'}));
else
    Peak = nan(1, 5);
end
end


