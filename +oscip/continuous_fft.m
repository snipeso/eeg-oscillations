function [Power, Frequencies, Time] = continuous_fft(Data, SampleRate, WindowLength, WindowShifts)
% data is a Channel x time matrix. WindowShifts is the time gap in seconds
% with which to slide the power window. WindowLength is in seconds the
% window on which to compute power.

Dims = size(Data);

[Frequencies, nFrequencies, WindowPoints] = oscip.utils.expected_frequencies(WindowLength, SampleRate);

halfWindowPoints = WindowPoints/2;

NewTimePoints = 1:WindowShifts*SampleRate:Dims(2);

Power = nan(Dims(1), numel(NewTimePoints), nFrequencies);

disp('Running FFT on moving window')

for ChannelIdx = 1:Dims(1)
    for TimeIdx = 1:numel(NewTimePoints)-1
        Midpoint = NewTimePoints(TimeIdx);
        Start = Midpoint-halfWindowPoints;
        End = Midpoint+halfWindowPoints-1;
        if Start < 1
            continue
        end

        if End > Dims(2)
            continue
        end

        DataSnippet = Data(ChannelIdx, Start:End);
        [P, ~] = oscip.compute_power_fft(DataSnippet, SampleRate);
         % [P, ~] = oscip.compute_power(DataSnippet, SampleRate, WindowLength, 0);
        Power(ChannelIdx, TimeIdx, :) = P;
    end
end

Time = linspace(0, Dims(2)/SampleRate, numel(NewTimePoints));
