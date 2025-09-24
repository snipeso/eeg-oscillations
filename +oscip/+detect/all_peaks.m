function AllPeaks = all_peaks(Power, Frequencies, SmoothFactor, ColInfo, ExcludeHarmonics, HarmonicsRange)
% Power is a Ch (or P or S) x F matrix
% SmoothFactor is how much to smooth the spectrum to improve peak
% detection. Recommendation 2-5 Hz. If power spectrum is already smooth,
% leave this empty.
% ColInfo can either be a string or a row of a table, which will get
% repeated for each entry encoding the first dimention of the power matrix
% ExcludeHarmonics is true/false, and if true will remove smaller peaks
% that are multiples of higher amplitude lower frequency peaks
% HarmonicsRange is the frequency around the multiple of the lwoer
% frequency in which to consider a higher frequency peak a harmonic.
% Peaks is a N x 4 matrix of center frequency, amplitude, bandwidth, and
% prominance
arguments
    Power
    Frequencies
    SmoothFactor = [];
    ColInfo = 'Row';
    ExcludeHarmonics = true;
    HarmonicsRange = 1; % Hz
end

AllPeaks = table();

for ChIdx = 1:size(Power, 1)

    Peaks = oscip.utils.findpeaks_matlab(Power(ChIdx, :), Frequencies, SmoothFactor);

    if ExcludeHarmonics
        Peaks = exclude_harmonics(Peaks, HarmonicsRange);
    end

    Table = peaks_to_table(Peaks, ColInfo, ChIdx);

    AllPeaks = [AllPeaks; Table]; %#ok<AGROW>
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Peaks = exclude_harmonics(Peaks, HarmonicsRange)

PeaksCF = Peaks(:, 1);
PeaksAmp = Peaks(:, 2);

isHarmonic = false(numel(PeaksCF), 1);
for PeakIdx = 1:numel(PeaksCF)
    Harmonic2xMidpoint = PeaksCF(PeakIdx) * 2;
    Harmonic2x = Harmonic2xMidpoint-HarmonicsRange <= PeaksCF & ...
        PeaksCF <=Harmonic2xMidpoint+HarmonicsRange & ...
        PeaksAmp<PeaksAmp(PeakIdx); % only if its smaller than the reference peak; haven't seen any harmonics that were bigger

    Harmonic3xMidpoint = PeaksCF(PeakIdx) * 3;
    Harmonic3x = Harmonic3xMidpoint-HarmonicsRange <= PeaksCF & ...
        PeaksCF <=Harmonic3xMidpoint+HarmonicsRange & ...
        PeaksAmp<PeaksAmp(PeakIdx);

    isHarmonic = isHarmonic | Harmonic2x | Harmonic3x;
end

Peaks(isHarmonic, :) = [];

end


function Table = peaks_to_table(Peaks, ColInfo, ChIdx)

if isstring(ColInfo) || ischar(ColInfo)
    Table = table();
    Table.(ColInfo) = ChIdx*ones(size(Peaks, 1), 1);
else
    ColInfoWithChannel = ColInfo;
    ColInfoWithChannel.Row = ChIdx;
    Table = repmat(ColInfo, size(Peaks, 1), 1);
end

Table.Frequency = Peaks(:, 1);
Table.Power = Peaks(:, 2);
Table.BandWidth = Peaks(:, 3);
Table.Prominance = Peaks(:, 4);

end
