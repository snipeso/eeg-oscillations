function Power = standardize_power_dimentions(Power, Frequencies)
% Power = standardize_power_dimentions(Power, Frequencies)
% handles mistakes in ordering data. Makes sure frequencies are the last
% dimention
%
% Code by Sophia Snipes, 2024, for eeg-oscillations.

Dims = size(Power);
nFrequencies = numel(Frequencies);
Indexes = 1:numel(Dims);
FreqIdx = Indexes(Dims==nFrequencies);

if numel(FreqIdx)>1 % if by some miracle more than one dimention is the same size as the frequency array
    FreqIdx = FreqIdx(end); % assume its the last one
elseif numel(FreqIdx)<1
    error('No dimention in Power the same size as frequency array')
end

NotFreqIdx = Indexes(Indexes~=FreqIdx);

% make sure frequency is last dimention
if ~all(Indexes ==[NotFreqIdx, FreqIdx])
    warning('reordering Power matrix when smoothing')
    Power = permute(Power, [NotFreqIdx, FreqIdx]);
end
end