function spectral_hypnogram(Power, Frequencies, Time, CLims, YLims)
 % spectral_hypnogram(Power, Frequencies, Time, CLims, YLims)
 % plots a time x frequency graph

Power = Power'; % flip so its F x T

imagesc(Time, Frequencies, Power)
colormap("parula")
xlabel('Time (h)')

if ~isempty(CLims)
    clim(CLims)
end

set(gca, 'YDir', 'normal')
ylabel('Frequency (Hz)')
set(gca, 'TickLength', [0 0])

if~isempty(YLims)
    ylim(YLims)
end