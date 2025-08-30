function Artefacts = outlier_exponents(Exponents, Threshold, Artefacts)
arguments
    Exponents
    Threshold = 0.6;
    Artefacts = false(size(Exponents));
end
% hello

Exponents(Artefacts) = nan;

Deviations = abs(Exponents-median(Exponents, 1, 'omitnan'));

Artefacts = Deviations>Threshold;