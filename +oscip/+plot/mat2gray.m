function I = mat2gray(A, limits)
%MAT2GRAY Rescale matrix to range [0 1]
%
%   I = MAT2GRAY(A)
%   I = MAT2GRAY(A, [LOW HIGH])
%
%   Equivalent to Image Processing Toolbox mat2gray.

    arguments
        A
        limits (1,2) double = [min(A(:)) max(A(:))]
    end

    A = double(A);
    low  = limits(1);
    high = limits(2);

    if high == low
        I = zeros(size(A));
        return
    end

    I = (A - low) ./ (high - low);

    % Clamp to [0 1] (matches toolbox behavior when limits provided)
    I(I < 0) = 0;
    I(I > 1) = 1;
end