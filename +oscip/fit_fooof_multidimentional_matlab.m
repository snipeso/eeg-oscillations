function [Slopes, Intercepts, FooofFrequencies, PeriodicPeaks, PeriodicPower, Errors, RSquared] ...
    = fit_fooof_multidimentional_matlab(Power, Frequencies, FooofFrequencyRange, MaxError, MinRSquared, AdditionalParameters)
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

nEpochs = Dims(2);
nChannels = Dims(1);

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
                = oscip.fit_fooof_matlab(squeeze(Power(ChannelIdx, :)), Frequencies, ...
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

        % check if there's parallel processing available
        installedParallelToolbox = license('test','distrib_computing_toolbox');

        % run fooof
        if installedParallelToolbox && Dims(2) > 50 && Dims(2) > Dims(1)

            % if epochs more than channels
            for ChannelIdx = 1:nChannels
                parfor EpochIdx = 1:nEpochs
                  % for EpochIdx = 1:nEpochs
                  %     disp('debug')
                    [Slopes(ChannelIdx, EpochIdx), Intercepts(ChannelIdx, EpochIdx), ...
                        ~, Peaks, PeriodicPower(ChannelIdx, EpochIdx, :), ...
                        Errors(ChannelIdx, EpochIdx), RSquared(ChannelIdx, EpochIdx)] ...
                        = oscip.fit_fooof_matlab(squeeze(Power(ChannelIdx, EpochIdx, :)), Frequencies, ...
                        FooofFrequencyRange, MaxError, MinRSquared, AdditionalParameters);

                    PeriodicPeaks(ChannelIdx, EpochIdx, :) = oscip.select_max_peak(Peaks);
                end
                disp(['Finished ', num2str(ChannelIdx)])
            end
        elseif installedParallelToolbox && Dims(1) > 50 && Dims(1) >= Dims(2)

            % if channels more than epochs
            for EpochIdx = 1:nEpochs
                parfor ChannelIdx = 1:nChannels
                    [Slopes(ChannelIdx, EpochIdx), Intercepts(ChannelIdx, EpochIdx), ...
                        ~, Peaks, PeriodicPower(ChannelIdx, EpochIdx, :), ...
                        Errors(ChannelIdx, EpochIdx), RSquared(ChannelIdx, EpochIdx)] ...
                        = oscip.fit_fooof_matlab(squeeze(Power(ChannelIdx, EpochIdx, :)), Frequencies, ...
                        FooofFrequencyRange, MaxError, MinRSquared, AdditionalParameters);

                    PeriodicPeaks(ChannelIdx, EpochIdx, :) = oscip.select_max_peak(Peaks);
                end
            end

        else
            warning('This could be slow. if you have the option, install the parallel computing toolbox.')

            for ChannelIdx = 1:nChannels
                for EpochIdx = 1:nEpochs
                    [Slopes(ChannelIdx, EpochIdx), Intercepts(ChannelIdx, EpochIdx), ...
                        ~, Peaks, PeriodicPower(ChannelIdx, EpochIdx, :), ...
                        Errors(ChannelIdx, EpochIdx), RSquared(ChannelIdx, EpochIdx)] ...
                        = oscip.fit_fooof_matlab(squeeze(Power(ChannelIdx, EpochIdx, :)), Frequencies, ...
                        FooofFrequencyRange, MaxError, MinRSquared, AdditionalParameters);

                    PeriodicPeaks(ChannelIdx, EpochIdx, :) = oscip.select_max_peak(Peaks);
                end
                disp(['finished ch', num2str(ChannelIdx)])
            end

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
