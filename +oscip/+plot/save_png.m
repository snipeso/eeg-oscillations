function save_png(Destination, Title)

set(gcf, 'InvertHardcopy', 'off', 'Color', 'W')
print(fullfile(Destination, [Title, '.png']), '-dpng')