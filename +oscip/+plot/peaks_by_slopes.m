function peaks_by_slopes(Slopes, WhitenedPower, FooofFrequencies, ChannelLabels)

NChannels = size(Slopes, 1);
figure('Units','centimeters', 'Position', [0 0 10*NChannels, 10])
for ChannelIdx = 1:NChannels

    WP = squeeze(WhitenedPower(ChannelIdx, :, :));
    NotNan = ~isnan(WP(:, 1));
    WP = WP(NotNan, :);

    [SortedSlopes, Order] = sort(Slopes(ChannelIdx, NotNan));
    WPSorted = WP((~isnan(SortedSlopes)), :);

    subplot(1, NChannels, ChannelIdx)
    contourf(SortedSlopes(~isnan(SortedSlopes)), FooofFrequencies, ...
        WPSorted', 100, 'linecolor', 'none')
    clim(quantile(WP(:), [.01 .99]))
    title(ChannelLabels{ChannelIdx})
    xlim([1 3.5])
    xlabel('Slope (a.u.)')
    ylabel('Frequency (Hz)')
    box off
end