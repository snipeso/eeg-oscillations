function [Outliers, xfit, yfit] = linear_outlier_detector(X, Y, Threshold)
arguments
    X
    Y
    Threshold = 10
end

Dims = size(X);

% identify linear fit between two data series
X = X(:);
Y = Y(:);

if nnz(~isnan(X)) <5 || nnz(~isnan(Y)) <5 
    Outliers = false(Dims);
    return
end

b = robustfit(X, Y); % fits y ≈ b(1) + b(2)*x, downweights outliers
yfit = b(1) + b(2)*X;
xfit = X; % for output

% calculate normalized residuals
Residuals = Y(:) - yfit;
Z = (Residuals-median(Residuals, 'omitnan'))./mad(Residuals, 1);

% identify outliers
Outliers = abs(Z)>Threshold;

Outliers = reshape(Outliers, Dims);