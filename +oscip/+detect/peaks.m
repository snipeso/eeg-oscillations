function [pks, locs, w, p] = peaks(Signal, X, MinPeakProminance, MinPeakDistance)

% find peaks using matlab's function
[pks, locs, ~, p] = findpeaks(Signal(:)', X(:)', ...
    'MinPeakProminence', MinPeakProminance, 'MinPeakDistance', MinPeakDistance);

% find each peaks' full width to half maximum
w = fwhm(X, Signal, locs);

% remove any peaks that have another peak within its' FWHM of higher
% amplitude
remove = has_larger_peaks_in_fwhm(Signal, X, locs, w, pks);
pks(remove) = [];
locs(remove) = [];
w(remove) = [];
p(remove) = [];

end

function toRemove = has_larger_peaks_in_fwhm(Signal, X, locs, w, pks)


toRemove = false(size(locs));
for p_idx = 1:numel(locs) % can start from 2 because nothing is bigger than first
    Range = locs(p_idx) + [-w(p_idx)/4; w(p_idx)/4];
    RangeX = dsearchn(X', Range);
    Segment = Signal(RangeX(1):RangeX(2));
    if any(Segment>pks(p_idx))
        toRemove(p_idx) = true;
    end
end
end



function [FWHM, x_left, x_right] = fwhm(x, y, peakloc)
% x: vector of x-axis values (time, freq, etc.), length N
% y: vector of signal values, same length
%
% Returns:
%   FWHM      = classical full-width at half maximum
%   x_left    = left half-max crossing
%   x_right   = right half-max crossing#
% modified from chatGPT, checked by Sophia Snipes

FWHM = nan(1, numel(peakloc));
x_left = FWHM;
x_right = FWHM;

for PeakIdx = 1:numel(peakloc)
    % --- Half-maximum value -----------------------------------------------
    idx=dsearchn(x', peakloc(PeakIdx));
    peakVal = y(idx);
    halfMax = peakVal / 2;

    % --- Find left crossing -----------------------------------------------
    % Find first index to the left that falls below half-max
    leftIdx = max([find(y(1:idx) < halfMax, 1, 'last'), 1]);
    % Linear interpolation for exact x
    x_l = x(leftIdx);

    % --- Find right crossing ----------------------------------------------
    rightIdx = min([idx - 1 + find(y(idx:end) < halfMax, 1, 'first'), numel(x)]);
    x_r = x(rightIdx);

    % --- Full width --------------------------------------------------------
    FWHM(PeakIdx) = 2*min(peakloc(PeakIdx)-x_l, x_r-peakloc(PeakIdx));

    x_right(PeakIdx) = x_r;
    x_left(PeakIdx) = x_l;
end
end
