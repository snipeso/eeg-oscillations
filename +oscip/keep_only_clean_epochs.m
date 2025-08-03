function [CleanData, Artefacts] = keep_only_clean_epochs(Data, Exponents, Offsets, RSquared, Errors, ...
    Artefacts, RangeExponents, RangeOffsets, MinRSquared, MaxError, Frequencies, MaxArtefacts)
% sets to nan all data points which would have other factors outside of
% physiological ranges. Takes as input:
% - Data: a channel x epoch x something matrix. The output will be this
% data, but artifacts will be replaced with NaNs
% - Exponents/Offsets/RSquared/Errors: a channel x epoch matrix. Could be left empty.
% - RangeExponents: a 1 x 2 array of the min/max Exponent considered
% physiological. Defaults are [0 4].
% - RangeOffsets: Defaults are [0 5];
% - Frequencies: optional (only if providing power). Used to detect epochs
% that have too high frequency relative to the standard deviations of the
% whole channel
% - MinCleanChannels: the minimum proportion of clean channels needed
% before the whole epoch is discarded. Should be value between 0 and 1.
% - Artifacts: optional. If manual scoring of artifacts has already been
% done, this will start from that information
%
% How to use:
% 1) Only removed artefacts: PeriodicPower = oscip.keep_only_clean_epochs(PeriodicPower, [], [], [], [], Artefacts);
% 2) Automatically remove anything not in range: PeriodicPower = oscip.keep_only_clean_epochs(PeriodicPower, Exponents, Offsets, RSquared, Errors)
% 3) Apply to Exponents: Exponents = oscip.keep_only_clean_epochs(Exponents, Exponents, Offsets, RSquared, Errors)
arguments
    Data
    Exponents = [];
    Offsets = [];
    RSquared = [];
    Errors = [];
    Artefacts = [];
    RangeExponents = [0 4.5];
    RangeOffsets = [0 5];
    MinRSquared = .98;
    MaxError = .1;
    Frequencies = [];
    MaxArtefacts = .3;
end

Dims = size(Data);

CleanData = Data;

%%% identify artifacts, create blanks if data not provided

% remove data based on aperiodic activity
% CleanData = oscip.utils.remove_bad_aperiodic(CleanData, Exponents, ...
%     Offsets, RangeExponents, RangeOffsets, MinCleanChannels);


if ~isempty(Exponents)
    BadExponents = oscip.utils.exclude_range(Exponents, RangeExponents);
else
    BadExponents = false(Dims(1:2));
end

if ~isempty(Offsets)
    BadOffsets = oscip.utils.exclude_range(Offsets, RangeOffsets);
else
    BadOffsets = false(Dims(1:2));
end

if ~isempty(RSquared)
    BadR = oscip.utils.exclude_range(RSquared, [MinRSquared, nan]);
else
    BadR = false(Dims(1:2));
end

if ~isempty(Errors)
    BadError = oscip.utils.exclude_range(Errors, [nan, MaxError]);
else
    BadError = false(Dims(1:2));
end

if isempty(Artefacts)
    Artefacts = false(Dims(1:2));
end

%%% join all artefact types together
Artefacts = Artefacts | BadExponents | BadOffsets | BadR | BadError;

if ~isempty(Frequencies)
    for ChIdx = 1:Dims(1)
        % remove epochs that have too high frequencies (this handles edge-cases
        % that Exponent-Offset thresholds don't cover, where the Exponent and
        % Offset are within physiological ranges, but their combination is
        % such that there is still a lot of high-frequency noise)
        Outliers = oscip.utils.find_high_frequency_outliers(squeeze(Data(ChIdx, :, :)), Frequencies);
        Artefacts(ChIdx, :) = Artefacts(ChIdx, :) | Outliers';
    end
end

% removes either the epoch or the channel, depending on which has more
% worse data. It's not perfect, but it's decent.
if ~isempty(MaxArtefacts)
    Artefacts = oscip.utils.remove_channel_or_window(Artefacts, MaxArtefacts);
end

%%% remove artefacts from data
for ChIdx = 1:Dims(1)
    CleanData(ChIdx, Artefacts(ChIdx, :), :) = nan;
end

