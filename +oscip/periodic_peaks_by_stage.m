function Table = periodic_peaks_by_stage(PeriodicPower, FooofFrequencies, Scoring, ScoringIndexes, MetadataTableRow, MinEpochs, SmoothSpectrum)
arguments
    PeriodicPower % a time x frequency matrix
    FooofFrequencies
    Scoring
    ScoringIndexes
    MetadataTableRow = table(); % optional, contains participant information and any other metadata for easy indexing
    MinEpochs = 3;
    SmoothSpectrum = []; % if power was from average of lots of channels,this can be small; if it was from only a few channels, this should be big, like 5
end

% get a Stage x frequency matrix
StagedPeriodicPower = oscip.utils.average_stages(PeriodicPower', Scoring, ScoringIndexes, MinEpochs)'; % the little dimention switch is because the second dimention should always be epochs

% set up blanks
MetadataTableRow.Stage = nan;
MetadataTableRow.Frequency = nan;
MetadataTableRow.BandWidth = nan;
MetadataTableRow.Power = nan;

Table = table();


for StageIdx = 1:numel(ScoringIndexes)

    % from average spectra of each stage, find all the peaks
    AllPeriodicPeaks = oscip.utils.findpeaks_matlab(StagedPeriodicPower(StageIdx, :), FooofFrequencies, SmoothSpectrum);

    % set up as table
    MetadataTableRow.Stage = ScoringIndexes(StageIdx);
    T = repmat(MetadataTableRow, size(AllPeriodicPeaks, 1), 1);
    T.Frequency = AllPeriodicPeaks(:, 1);
    T.Power = AllPeriodicPeaks(:, 2);
    T.BandWidth = AllPeriodicPeaks(:, 3);
    T.Prominance = AllPeriodicPeaks(:, 4);

    % append to larger table
    Table = cat(1, Table, T);
end