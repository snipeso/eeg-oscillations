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
