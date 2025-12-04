function spectral_hypnogram(Power, Frequencies, Time, CLims, YLims)
% spectral_hypnogram(Power, Frequencies, Time, CLims, YLims)
% plots a time x frequency graph
arguments
    Power
    Frequencies
    Time = 1:size(Power, 1);
    CLims = [];
    YLims = [min(Frequencies), max(Frequencies)];
end

Power = Power'; % flip so its F x T

imagesc(Time, Frequencies, Power)
colormap("parula")
xlabel('Time (h)')

if ~isempty(CLims)
    clim(CLims)
else
    % clim(quantile(Power(:), [0 .999]));
    set(gca,'CLim', quantile(Power(:), [0 .999]))
end

set(gca, 'YDir', 'normal')
ylabel('Frequency (Hz)')
set(gca, 'TickLength', [0 0])

if~isempty(YLims)
    ylim(YLims)
end