function fooof_fit(PeriodicPower, PeriodicPeaks, FrequenciesPeriodic)

figure
hold on
plot(FrequenciesPeriodic, PeriodicPower, 'LineWidth',1.5, 'Color','k')
for PPIdx = 1:size(PeriodicPeaks, 1)
    plot([PeriodicPeaks(PPIdx, 1), PeriodicPeaks(PPIdx, 1)], [0 PeriodicPeaks(PPIdx, 2)], 'Color', [1, 0 0], 'LineWidth',2)
    
    
    Start= PeriodicPeaks(PPIdx, 1)-PeriodicPeaks(PPIdx, 3)/2;
    End = PeriodicPeaks(PPIdx, 1)+PeriodicPeaks(PPIdx, 3)/2;
    plot([Start, End], [PeriodicPeaks(PPIdx, 2)/2 PeriodicPeaks(PPIdx, 2)/2], 'Color', [.5 .5 .5], 'LineWidth',2)
end
xlabel('Frequency (Hz)')
ylabel('Periodic power')
set(gcf, 'Color','w')
axis tight