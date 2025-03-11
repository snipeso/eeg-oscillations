function eeglab_topoplot(Data, Chanlocs, isSignificant, CLims, CLabel, Direction)
arguments
    Data
    Chanlocs
    isSignificant = [];
    CLims = 'minmax';
    CLabel = '';
    Direction = 'Linear';
end
% eeglab_topoplot(Data, Chanlocs, Stats, CLims, CLabel)
% pretty way of using EEGLAB's topoplot function. This is not my own plot.
% Maybe one day it will be.
% Data is a Ch x 1 matrix. If CLims is empty, uses "minmax". Colormap is
% string.
% if isSignificant is not empty, will plot little white markers for "true"
% Direction is either 'Linear' or 'Divergent'

Resolution = 300;
MarkerSize = 2;
Colormap = oscip.plot.magma();

if strcmp(Direction, 'Divergent')
    Colormap = oscip.plot.rdbu();
end

if strcmp(Direction, 'Divergent') && isempty(CLims)
    Lim = max(abs(Data));
    CLims = [-Lim, Lim];
elseif isempty(CLims) || strcmp(CLims, 'minmax')
    CLims = quantile(Data, [0 1]);

end

Indexes = 1:numel(Chanlocs);


if isempty(isSignificant)
    topoplot(Data, Chanlocs, 'style', 'map', 'headrad', 'rim', 'whitebk', 'on', ...
        'electrodes', 'on',  'maplimits', CLims, 'gridscale', Resolution, 'colormap', Colormap);
else
    topoplot(Data, Chanlocs, 'maplimits', CLims, 'whitebk', 'on', 'colormap', Colormap,  ...
        'style', 'map',  'plotrad', .73, 'headrad', 'rim', 'gridscale', Resolution, ...
        'electrodes', 'on', 'emarker2', {Indexes(isSignificant==1), 'o', 'w', MarkerSize*2, .05});
end

xlim([-.55 .55])
ylim([-.55 .6])

A = gca;
set(A.Children, 'LineWidth', 1)

A.Children(1).MarkerSize = MarkerSize*2;


if isstring(CLims) && strcmp(Direction, 'Divergent')
    CLims = clim;
    CLims = [-abs(max(CLims)), abs(max(CLims))];
end

if ~isempty(CLabel)
    h = colorbar;
     ylabel(h, CLabel)
else
    clim(CLims)
end


% set(gca, 'Colormap', Colormap)
colormap(Colormap)

