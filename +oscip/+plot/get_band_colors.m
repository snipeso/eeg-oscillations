function BandColors = get_band_colors(BandLabels)

% TODO: make more flexible, decide which is the highlight color etc.

nBands = numel(BandLabels);

BandColors = nan(nBands, 3);
for BandIdx = 1:nBands
    switch BandLabels{BandIdx}
        case 'Iota'
            BandColors(BandIdx, :) = oscip.plot.color_picker(1, '', 'red');
        case 'Beta'
            BandColors(BandIdx, :) = oscip.plot.color_picker(1, '', 'yellow');
        case 'Theta'
            BandColors(BandIdx, :) = oscip.plot.color_picker(1, '', 'green');
        case 'Alpha'
            BandColors(BandIdx, :) = oscip.plot.color_picker(1, '', 'blue');
        case 'Sigma'
            BandColors(BandIdx, :) = oscip.plot.color_picker(1, '', 'purple');
        otherwise
            BandColors(BandIdx, :) = oscip.plot.color_picker(1);
    end
end
