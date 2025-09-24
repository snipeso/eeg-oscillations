function PeriodicPeaks = findpeaks_matlab(PeriodicPower, Frequencies, SmoothSpan)
% periodic peaks is a n x 4 matrix of center frequency, amplitude,
% bandwidth and prominance
arguments
    PeriodicPower
    Frequencies
    SmoothSpan = 5; % should be fairly smooth. if empty, will skip smoothing here
end

if ~isempty(SmoothSpan)
    SmoothPower = oscip.smooth_spectrum(PeriodicPower, Frequencies, SmoothSpan);
else
    SmoothPower = PeriodicPower;
end

Dims = size(SmoothPower);
if Dims(1)>1 && Dims(2)>1
    error('findpeaks needs only 1 spectrum')
end

if Dims(2)==1
    SmoothPower = SmoothPower';
end

[pks, locs, w, p] = findpeaks(SmoothPower, Frequencies, 'Annotate','extents', 'WidthReference','halfheight');

PeriodicPeaks = [locs', pks', w', p'];

% figure
% findpeaks(SmoothPower, Frequencies, 'Annotate','extents', 'WidthReference','halfheight');