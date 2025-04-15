function isOutside = exclude_range(Data, Range)
% Data is a Channel x Epoch matrix, Range is the min-max;

isOutside = false(size(Data));
isOutside(Data<Range(1) | Data>Range(2)) = true;