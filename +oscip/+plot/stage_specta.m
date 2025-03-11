function stage_specta(Data, Frequencies, ScoringLabels, GroupIndexes, UniqueGroupIndexes, GroupLabels, xLog, yLog, xLim)
arguments
    Data
    Frequencies
    ScoringLabels
    GroupIndexes = ones(size(Data, 1), 1);
    UniqueGroupIndexes = 1;
    GroupLabels = '';
    xLog = true;
    yLog = true;
    xLim = [.5 40];
end

nStages = numel(ScoringLabels);
nGroups = numel(GroupLabels);

if xLog
    xLog = 'log';
else
    xLog = 'linear';
end

if yLog
    yLog = 'log';
else
    xLog = 'linear';
end

Colors = oscip.plot.color_picker(nGroups);

ax = gobjects(1, nStages); % Preallocate array for axes handles

figure('Units','centimeters', 'Position',[0 0 20 10])
for StageIdx = 1:nStages
    subplot(1, nStages, StageIdx)
    hold on
    for GroupIdx = 1:nGroups
        Power = squeeze(mean(Data(ismember(GroupIndexes, UniqueGroupIndexes(GroupIdx)), StageIdx, :), 1, 'omitnan'));
        plot(Frequencies, Power, "Color", Colors(GroupIdx, :), 'LineWidth', 2)
    end
    set(gca, 'xScale', xLog, 'yscale', yLog, 'XLim', xLim)
    title(ScoringLabels{StageIdx})
    if StageIdx==1
        if ~isempty(GroupLabels)
            legend(GroupLabels)
        end
        xlabel('Frequency (Hz)')
        ylabel('Power')
    else
        set(gca, 'YColor', 'none');
    end
    ax(StageIdx) = gca; % Store the current axes handle
end

linkaxes(ax, 'y');
