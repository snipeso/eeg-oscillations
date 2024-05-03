function MaxPeak = select_max_peak(Peaks, Range, N)
% MaxPeak = select_max_peak(Peaks, Range, N)
% selects the N largest peaks within a given frequency range.
%
% Code by Sophia Snipes, 2024, for eeg-oscillations.
arguments
    Peaks
    Range = [];
    N = 1;
end

if isempty(Peaks)
    MaxPeak = nan(1, 3);
    return
end

% select peaks in the right frequency range
if isempty(Range)
   Range = [min(Peaks(:, 1)), max(Peaks(:, 1))];
end
inRange = Peaks(:, 1)>=Range(1) & Peaks(:, 1)<=Range(2);
Peaks = Peaks(inRange, :);

% handle not enough options to chose from
if isempty(Peaks)
    MaxPeak = nan(1, 3);
    return
elseif size(Peaks, 1) <= N
    MaxPeak = Peaks;
    return
end

% get top peaks by power
Peaks = sortrows(Peaks, 2, 'descend');
MaxPeak = Peaks(1:N, :);

if N>1 
    MaxPeak = sortrows(MaxPeak, 1, 'ascend'); % restore to being ordered by frequency
end

