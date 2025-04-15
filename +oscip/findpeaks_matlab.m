function PeriodicPeaks = findpeaks_matlab(PeriodicPower, Frequencies, SmoothSpan)
% periodic peaks is a n x 4 matrix of center frequency, amplitude,
% bandwidth and prominance
arguments
    PeriodicPower
    Frequencies
    SmoothSpan = 5; % should be fairly big
end


SmoothPower = oscip.smooth_spectrum(PeriodicPower, Frequencies, SmoothSpan);
[pks, locs, w, p] = findpeaks(SmoothPower, Frequencies, 'Annotate','extents', 'WidthReference','halfheight');

PeriodicPeaks = [locs', pks', w', p'];

% figure
% findpeaks(SmoothPower, Frequencies, 'Annotate','extents', 'WidthReference','halfheight');