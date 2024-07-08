function [Slopes, Intercepts, FooofFrequencies, PeriodicPeaks, PeriodicPower, Errors, RSquared] ...
    = fit_fooof_multidimentional(Power, Frequencies, FooofFrequencyRange, MaxError, MinRSquared, AdditionalParameters)
% [Slopes, Intercepts, FooofFrequencies, PeriodicPeaks, PeriodicPower, Errors, RSquared] ...
%   = fit_fooof_multidimentional(Power, Frequencies, FittingFrequencyRange, MaxError, MinRSquared, AdditionalParameters)
%
% Applies fooof fitting to Power that can be either Channel x Frequency or
% Channel x Epoch x Frequency
%
% Code by Sophia Snipes, 2024, for eeg-oscillations.
arguments
    Power
    Frequencies
    FooofFrequencyRange = [3 40];
    MaxError = .15;
    MinRSquared = .95;
    AdditionalParameters = struct();
end

% make sure frequency is last dimention
Power = oscip.utils.standardize_power_dimentions(Power, Frequencies);

% default frequencies
FooofFrequencies = oscip.utils.expected_fooof_frequencies(Frequencies, FooofFrequencyRange);

Dims = size(Power);

switch numel(Dims)

    case 2
        % default outputs
        PeriodicPower = nan(Dims(1), numel(FooofFrequencies));
        Slopes = nan(Dims(1));
        Intercepts = Slopes;
        Errors = Slopes;
        RSquared = Slopes;
        PeriodicPeaks = nan(Dims(1), 3);

        % run fooof
        for ChannelIdx = 1:Dims(1)
            [Slopes(ChannelIdx), Intercepts(ChannelIdx), ...
                FooofFrequencies, Peaks, PeriodicPower(ChannelIdx, :), ...
                Errors(ChannelIdx), RSquared(ChannelIdx)] ...
                = oscip.fit_fooof(squeeze(Power(ChannelIdx, :)), Frequencies, ...
                FooofFrequencyRange, MaxError, MinRSquared, AdditionalParameters);

            PeriodicPeaks(ChannelIdx, :) = oscip.select_max_peak(Peaks);
            disp(['finished ch', num2str(ChannelIdx)])
        end

    case 3
        % default outputs
        PeriodicPower = nan(Dims(1), Dims(2), numel(FooofFrequencies));
        Slopes =  nan(Dims(1), Dims(2));
        Intercepts = Slopes;
        Errors = Slopes;
        RSquared = Slopes;
        PeriodicPeaks = nan(Dims(1), Dims(2), 3);

        % run fooof
        for ChannelIdx = 1:Dims(1)
            Dimentions = Dims;
            nEpochs = Dimentions(2);

            installedParallelToolbox = license('test','distrib_computing_toolbox');

            if installedParallelToolbox
                parfor EpochIdx = 1:nEpochs
                    [Slopes(ChannelIdx, EpochIdx), Intercepts(ChannelIdx, EpochIdx), ...
                        ~, Peaks, PeriodicPower(ChannelIdx, EpochIdx, :), ...
                        Errors(ChannelIdx, EpochIdx), RSquared(ChannelIdx, EpochIdx)] ...
                        = oscip.fit_fooof(squeeze(Power(ChannelIdx, EpochIdx, :)), Frequencies, ...
                        FooofFrequencyRange, MaxError, MinRSquared, AdditionalParameters);

                    PeriodicPeaks(ChannelIdx, EpochIdx, :) = oscip.select_max_peak(Peaks);
                end

            else
                warning('This could be slow. if you have the option, install the parallel computing toolbox.')

                for EpochIdx = 1:nEpochs
                    [Slopes(ChannelIdx, EpochIdx), Intercepts(ChannelIdx, EpochIdx), ...
                        ~, Peaks, PeriodicPower(ChannelIdx, EpochIdx, :), ...
                        Errors(ChannelIdx, EpochIdx), RSquared(ChannelIdx, EpochIdx)] ...
                        = oscip.fit_fooof(squeeze(Power(ChannelIdx, EpochIdx, :)), Frequencies, ...
                        FooofFrequencyRange, MaxError, MinRSquared, AdditionalParameters);

                    PeriodicPeaks(ChannelIdx, EpochIdx, :) = oscip.select_max_peak(Peaks);
                end
            end
            disp(['finished ch', num2str(ChannelIdx)])
        end

    otherwise
        % default outputs
        PeriodicPower = [];
        Slopes =  [];
        Intercepts = Slopes;
        Errors = Slopes;
        RSquared = Slopes;
        PeriodicPeaks = [];

        warning('Power is empty')
end
