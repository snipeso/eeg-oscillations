function all_band_topoplots(Data, Chanlocs, ScoringLabels, BandLabels)

nStages = numel(ScoringLabels);
nBands = numel(BandLabels);

figure('Units','centimeters', 'Position',[0 0 4*nBands, 4*nStages])

for BandIdx = 1:nBands
    for StageIdx = 1:nStages

        subplotIdx = (StageIdx - 1) * nBands + BandIdx; 
        subplot(nStages, nBands, subplotIdx); 

        Topo = squeeze(mean(Data(:, :, StageIdx, BandIdx), 1, 'omitnan'));

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