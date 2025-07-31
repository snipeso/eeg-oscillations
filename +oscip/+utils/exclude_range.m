function isOutside = exclude_range(Data, Range)
% Data is a Channel x Epoch matrix, Range is the min-max. IsOutside is a
% boolean with true indicating the value is outside of the provided range.

isOutside = false(size(Data));

if isempty(Range)
    return
end

isOutside(Data<Range(1) | Data>Range(2)) = true;