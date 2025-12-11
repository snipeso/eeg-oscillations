function sleep_onset(Exponents, Scoring, Time, TimeOnset, Trend, ExponentsOnset, TradSleepOnset, SleepOnset)


YLims = [min(Exponents), max(Exponents)];
ScoringPlot = -Scoring;
ScoringPlot = (ScoringPlot - min(ScoringPlot)) ./ (max(ScoringPlot)-min(ScoringPlot)) * diff(YLims) + YLims(1);

hold on
plot(Time, ScoringPlot, 'Color', [.7 .7 .7], 'LineWidth', 2)

if all(isnan(Exponents))
    return
end
scatter(Time, Exponents, 'MarkerEdgeColor', [.7 .7 .7], 'HandleVisibility','off')
scatter(TimeOnset, ExponentsOnset, 'filled', 'MarkerFaceColor',oscip.plot.color_picker(1), 'MarkerFaceAlpha',.5)

if isnan(TimeOnset)
    return
end
plot(TimeOnset, Trend, 'Color', 'k', 'LineWidth',2)
plot([TradSleepOnset, TradSleepOnset], YLims, '--', 'Color', [.5 .5 .5])
plot([SleepOnset, SleepOnset], YLims, ':',  'Color', oscip.plot.color_picker(1, '', 'red'), 'LineWidth',2)

legend({'Trad scoring', 'Exponents', 'sleep trajectory', 'trad sleep onset', 'new sleep onset'}, 'Location','northeast')
ylim(YLims)

xlabel('Time (h)')
ylabel('Sleep depth')
xlim([0, TimeOnset(end)+2])
set(gca, 'ydir', 'reverse')