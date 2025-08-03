function band_timecourse(Power, FrequenciesPeriodic, EpochLength, Bands, SmoothEpochs, Scoring, ScoringIndexes, ScoringLabels)
arguments
    Power
    FrequenciesPeriodic
    EpochLength
    Bands
    SmoothEpochs = 20;
    Scoring = nan(1, size(Power, 1));
    ScoringIndexes = 0;
    ScoringLabels = 'w';
end

% Bands is a table, with "Band" indicating the label, "CenterFrequency"
% being the custom range, and "DefaultBand" being the default freuqency
% range


% make sure data is epochs x frequency
nDims = size(Power);
if numel(nDims)==3 && nDims(1)>1
    Power = squeeze(mean(Power, 1, 'omitnan'));
else
    Power = squeeze(Power);
end

nEpochs = size(Power, 1);
Time = linspace(0, nEpochs*EpochLength/60/60, nEpochs);


figure('Units','centimeters', 'Position',[0 0 20 10], 'Color','w')
nBands = size(Bands, 1);

Colors = oscip.plot.color_picker(nBands);

subplot(3, 1, 1:2)
hold on

for BandIdx = 1:nBands
    CF = Bands.CenterFrequency(BandIdx);
    if isnan(CF)
        Band = Bands.DefaultBands(BandIdx,:);
        Alpha = .15;
    else
        BW = Bands.Bandwidth(BandIdx)/2;
        Band = CF + [-BW BW];
        Alpha = 1;
    end

    B = dsearchn(FrequenciesPeriodic', Band');
    BandPower = squeeze(mean(Power(:, B(1):B(2)), 2, 'omitnan'))';
    if SmoothEpochs >=2
        BandPower = smooth(BandPower, SmoothEpochs);
    end
    plot(Time, BandPower, 'Color', [Colors(BandIdx, :), Alpha], 'LineWidth',2)
end
legend(Bands.Band)
set(legend, 'ItemTokenSize', [10 10])
A1 = gca;


% plot scoring
subplot(3, 1, 3)

oscip.plot.scoring_hypnogram(Scoring(1, :), Time, ScoringIndexes, ScoringLabels)
axis tight
A2 = gca;

linkaxes([A1, A2], 'x')
