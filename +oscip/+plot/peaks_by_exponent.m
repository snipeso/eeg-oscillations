function peaks_by_exponent(PeriodicPeaks, Exponents, EpochLength, Title, ScatterSizeScaling, Alpha, Colormap)
arguments
    PeriodicPeaks
    Exponents
    EpochLength
    Title = '';
    ScatterSizeScaling = 2;
    Alpha = .1;
    Colormap = parula;
end


% identify relevant epochs
Time = repmat([1:size(Exponents, 2)]/EpochLength/60, size(Exponents, 1), 1);
Time = Time(:);
Exponents = Exponents(:);
BW = PeriodicPeaks(:, :, 3);
F = PeriodicPeaks(:, :, 1);
P = PeriodicPeaks(:, :, 2);

BW = BW(:);
F = F(:);
P = P(:);

P = mat2gray(P)+.01;

figure
subplot(3, 1, 1:2)
scatter(Exponents, F, P*ScatterSizeScaling, Time, 'filled', 'MarkerFaceAlpha', Alpha);
% scatter(Exponents, F, P*ScatterSizeScaling, BW, 'filled', 'MarkerFaceAlpha', Alpha);
Ax1 = gca;
Bar = colorbar;
colormap(Colormap)
% colormap(hot)
% ylabel(Bar, 'Bandwidth (Hz)')
% clim([1 6])
ylabel(Bar, 'Time (min)')
ylabel('Frequency (Hz)')
xlim([.5 4])
% xlabel('Exponent (a.u.)')
title(Title)
Ax1_new = gca;

subplot(3, 1, 3)
histogram(Exponents, 'EdgeColor','none', 'FaceColor',[.5 .5 .5])
Ax2 = gca;
xlabel('Exponent (a.u.)')
set(gca, 'Position', [Ax2.Position([1, 2]), Ax1_new.Position(3), Ax2.Position(4)], 'FontSize', Ax1.FontSize)
box off
linkaxes([Ax1, Ax2], 'x')

% function peaks_by_exponent(Exponents, PeriodicPower, FrequenciesPeriodic, ChannelLabels)
%
% NChannels = size(Exponents, 1);
% figure('Units','centimeters', 'Position', [0 0 10*NChannels, 10])
% for ChannelIdx = 1:NChannels
%
%     WP = squeeze(PeriodicPower(ChannelIdx, :, :));
%     NotNan = ~isnan(WP(:, 1));
%     WP = WP(NotNan, :);
%
%     [SortedExponents, Order] = sort(Exponents(ChannelIdx, NotNan));
%     WPSorted = WP((~isnan(SortedExponents)), :);
%
%     subplot(1, NChannels, ChannelIdx)
%     contourf(SortedExponents(~isnan(SortedExponents)), FrequenciesPeriodic, ...
%         WPSorted', 100, 'linecolor', 'none')
%     clim(quantile(WP(:), [.01 .99]))
%     title(ChannelLabels{ChannelIdx})
%     xlim([1 3.5])
%     xlabel('Exponent (a.u.)')
%     ylabel('Frequency (Hz)')
%     box off
% end