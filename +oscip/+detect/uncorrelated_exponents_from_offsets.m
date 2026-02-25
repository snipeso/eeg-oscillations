function OutlierArtefacts = uncorrelated_exponents_from_offsets(Exponents, Offsets, Threshold, Artefacts)
% best to do this after having identified artefacts
arguments
Exponents
Offsets
Threshold = 10;
Artefacts = [];
end

if ~isempty(Artefacts)
    Exponents(Artefacts) = nan;
    Offsets(Artefacts) = nan;
end

OutlierArtefacts = false(size(Exponents));

% first do single channels
for ChIdx = 1:size(Exponents, 1)
    OutlierArtefacts(ChIdx, :) = oscip.utils.linear_outlier_detector(Offsets(ChIdx, :), Exponents(ChIdx, :), Threshold);
end

% then do all remaining datapoints together
Exponents(OutlierArtefacts) = nan;
Offsets(OutlierArtefacts) = nan;

AllOutliers = oscip.utils.linear_outlier_detector(Offsets, Exponents, Threshold);
OutlierArtefacts = OutlierArtefacts | AllOutliers;