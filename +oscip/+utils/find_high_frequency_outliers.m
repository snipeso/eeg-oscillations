function Outliers = find_high_frequency_outliers(Spectra, Frequencies, Band, IQ_Factor)
arguments
    Spectra;
    Frequencies;
    Band = [20 45];
    IQ_Factor = 10;
end


GammaBand = dsearchn(Frequencies', Band(:));

Gamma = mean(Spectra(:, GammaBand(1):GammaBand(2)), 2);

Quantiles = quantile(Gamma, [.25, .5 .75]);

Threshold = Quantiles(2)+(Quantiles(3)-Quantiles(1))*IQ_Factor;

Outliers = Gamma > Threshold;

end
