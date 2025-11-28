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
leftIdx = find(y(1:idx) < halfMax, 1, 'last');
% Linear interpolation for exact x
x_l = interp1(y(leftIdx:leftIdx+1), x(leftIdx:leftIdx+1), halfMax);

% --- Find right crossing ----------------------------------------------
rightIdx = idx - 1 + find(y(idx:end) < halfMax, 1, 'first');
x_r = interp1(y(rightIdx-1:rightIdx), x(rightIdx-1:rightIdx), halfMax);

% --- Full width --------------------------------------------------------
FWHM(PeakIdx) = 2*min(x_l, x_r);
x_right(PeakIdx) = x_r;
x_left(PeakIdx) = x_l;
end
