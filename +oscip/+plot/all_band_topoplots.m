function all_band_topoplots(Data, Chanlocs, ScoringLabels, BandLabels)
% Data is either a P x Ch x Stage x Band matrix, or a Ch x Stage x Band.

nStages = numel(ScoringLabels);
nBands = numel(BandLabels);
Dims = size(Data);

figure('Units','centimeters', 'Position',[0 0 5*nBands, 5*nStages])

for BandIdx = 1:nBands
    for StageIdx = 1:nStages

        subplotIdx = (StageIdx - 1) * nBands + BandIdx;
        subplot(nStages, nBands, subplotIdx);

        if numel(Dims)==4
            Topo = squeeze(mean(Data(:, :, StageIdx, BandIdx), 1, 'omitnan'));
        elseif numel(Dims)==3
            Topo = squeeze(Data(:, StageIdx, BandIdx));
        else
            error('wrong dimentions of Data')
        end

        if all(isnan(Topo))
            continue
        end
        oscip.plot.eeglab_topoplot(Topo, Chanlocs, [], quantile(Topo, [.01, 1]), '', 'Linear')

        if StageIdx==1
            title(BandLabels{BandIdx})
        end

        if BandIdx==1
            oscip.plot.vertical_text(ScoringLabels{StageIdx})
        end
    end

end