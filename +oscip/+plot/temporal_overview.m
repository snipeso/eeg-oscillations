function temporal_overview(Power, Frequencies, EpochLength, Scoring, ScoringIndexes, ScoringLabels, Exponents, CLims, YLims, Title)
% creates a figure with two plots: a time x frequency spectrogram and a
% hypnogram below indicating the scoring.
% Power should be Epoch x Frequency matrix.
% Scoring should be a 1 x Epoch array. It is optional.
% ScoringIndexes should be a number array of all possible values that could
% be inside Scoring. e.g. [-3 -2 -1 0 1];
% ScoringLabels should be strings that correspond to each possible scoring
% index. e.g. {"N3", "N2", "N1", "W", "R"};
% Exponents is optional; it will plot in the hypnogram the actual Exponents for
% each epoch. should be a Channel x time matrix.
% CLims are the ranges of the colormap, but its also optional.
% YLims is the frequency range to display on the y axis.
%
% Code by Sophia Snipes, 2024, for eeg-oscillations.
arguments
    Power
    Frequencies
    EpochLength
    Scoring = nan(1, size(Power, 1));
    ScoringIndexes = 0;
    ScoringLabels = 'w';
    Exponents = [];
    CLims = [];
    YLims = [min(Frequencies), max(Frequencies)];
    Title = [];
end

nEpochs = size(Power, 1);
Time = linspace(0, nEpochs*EpochLength/60/60, nEpochs);


figure('Units','centimeters', 'Position',[0 0 20 10], 'Color','w')

if all(isnan(Power))
    return
end

%%% plot power
subplot(3, 1, 1:2)

oscip.plot.spectral_hypnogram(Power, Frequencies, Time, CLims, YLims)
xlabel('')
A1 = gca;
title(Title)

%%% plot scoring hypnogram
subplot(3, 1, 3)
hold on
A2 = gca;

% plot day/night patches
if size(Scoring, 1)==2 % if a second vector is provided with day/night info
    Daylight = nan(1, nEpochs);
    Daylight(Scoring(2, :)==1) = min(ScoringIndexes)-1;
  plot(Time, Daylight, 'Color', [1 1 .8], 'LineWidth',20)
end


% plot Exponents
if ~isempty(Exponents)
    Alpha = 1/size(Exponents, 1);
    plot(Time, -Exponents, 'Color', [.2 .2 .2 Alpha])
    ylabel('Exponent (a.u.)')
end

% plot scoring
oscip.plot.scoring_hypnogram(Scoring(1, :), Time, ScoringIndexes, ScoringLabels)
linkaxes([A1, A2], 'x')
end