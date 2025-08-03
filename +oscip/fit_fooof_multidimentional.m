function [Exponents, Offsets, FrequenciesPeriodic, PeriodicPeaks, PeriodicPower, Errors, RSquared] ...
    = fit_fooof_multidimentional(Power, Frequencies, FooofFrequencyRange,AdditionalParameters)
% [Exponents, Offsets, FrequenciesPeriodic, PeriodicPeaks, PeriodicPower, Errors, RSquared] ...
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
    AdditionalParameters = struct();
end

% make sure frequency is last dimention
Power = oscip.utils.standardize_power_dimentions(Power, Frequencies);

% default frequencies
FrequenciesPeriodic = oscip.utils.expected_fooof_frequencies(Frequencies, FooofFrequencyRange);

Dims = size(Power);

nEpochs = Dims(2);
nChannels = Dims(1);

switch numel(Dims)

    case 2
        % default outputs
        PeriodicPower = nan(Dims(1), numel(FrequenciesPeriodic));
        Exponents = nan(Dims(1));
        Offsets = Exponents;
        Errors = Exponents;
        RSquared = Exponents;
        PeriodicPeaks = nan(Dims(1), 3);

        % run fooof
        for ChannelIdx = 1:Dims(1)
            [Exponents(ChannelIdx), Offsets(ChannelIdx), ...
                FrequenciesPeriodic, Peaks, PeriodicPower(ChannelIdx, :), ...
                Errors(ChannelIdx), RSquared(ChannelIdx)] ...
                = oscip.fit_fooof(squeeze(Power(ChannelIdx, :)), Frequencies, ...
                FooofFrequencyRange, AdditionalParameters);

            PeriodicPeaks(ChannelIdx, :) = oscip.select_max_peak(Peaks);
            disp(['finished ch', num2str(ChannelIdx)])
        end

    case 3
        % default outputs
        PeriodicPower = nan(Dims(1), Dims(2), numel(FrequenciesPeriodic));
        Exponents =  nan(Dims(1), Dims(2));
        Offsets = Exponents;
        Errors = Exponents;
        RSquared = Exponents;
        PeriodicPeaks = nan(Dims(1), Dims(2), 3);

        % check if there's parallel processing available
        installedParallelToolbox = license('test','distrib_computing_toolbox');

        % run fooof
        if installedParallelToolbox && Dims(2) > 50 && Dims(2) > Dims(1)

            % if epochs more than channels
            for ChannelIdx = 1:nChannels
                parfor EpochIdx = 1:nEpochs
                  % for EpochIdx = 1:nEpochs
                  %     disp('debug')
                    [Exponents(ChannelIdx, EpochIdx), Offsets(ChannelIdx, EpochIdx), ...
                        ~, Peaks, PeriodicPower(ChannelIdx, EpochIdx, :), ...
                        Errors(ChannelIdx, EpochIdx), RSquared(ChannelIdx, EpochIdx)] ...
                        = oscip.fit_fooof(squeeze(Power(ChannelIdx, EpochIdx, :)), Frequencies, ...
                        FooofFrequencyRange, AdditionalParameters);

                    PeriodicPeaks(ChannelIdx, EpochIdx, :) = oscip.select_max_peak(Peaks);
                end
                disp(['Finished ', num2str(ChannelIdx)])
            end
        elseif installedParallelToolbox && Dims(1) > 50 && Dims(1) >= Dims(2)

            % if channels more than epochs
            for EpochIdx = 1:nEpochs
                parfor ChannelIdx = 1:nChannels
                    [Exponents(ChannelIdx, EpochIdx), Offsets(ChannelIdx, EpochIdx), ...
                        ~, Peaks, PeriodicPower(ChannelIdx, EpochIdx, :), ...
                        Errors(ChannelIdx, EpochIdx), RSquared(ChannelIdx, EpochIdx)] ...
                        = oscip.fit_fooof(squeeze(Power(ChannelIdx, EpochIdx, :)), Frequencies, ...
                        FooofFrequencyRange, AdditionalParameters);

                    PeriodicPeaks(ChannelIdx, EpochIdx, :) = oscip.select_max_peak(Peaks);
                end
            end

        else
            warning('This could be slow. if you have the option, install the parallel computing toolbox.')

            for ChannelIdx = 1:nChannels
                for EpochIdx = 1:nEpochs
                    [Exponents(ChannelIdx, EpochIdx), Offsets(ChannelIdx, EpochIdx), ...
                        ~, Peaks, PeriodicPower(ChannelIdx, EpochIdx, :), ...
                        Errors(ChannelIdx, EpochIdx), RSquared(ChannelIdx, EpochIdx)] ...
                        = oscip.fit_fooof(squeeze(Power(ChannelIdx, EpochIdx, :)), Frequencies, ...
                        FooofFrequencyRange, AdditionalParameters);

                    PeriodicPeaks(ChannelIdx, EpochIdx, :) = oscip.select_max_peak(Peaks);
                end
                disp(['finished ch', num2str(ChannelIdx)])
            end

        end

    otherwise
        % default outputs
        PeriodicPower = [];
        Exponents =  [];
        Offsets = Exponents;
        Errors = Exponents;
        RSquared = Exponents;
        PeriodicPeaks = [];

        warning('Power is empty')
end
