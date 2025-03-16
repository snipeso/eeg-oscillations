function gaussian_params = fit_peaks(model)
% Iteratively fit peaks to flattened spectrum
%
% INPUTS:
%   model : struct
%       Model object containing model settings and results
%
% OUTPUTS:
%   gaussian_params : nx3 array
%       Parameters for gaussian fits, each row as [center, height, width]
%
% This MATLAB implementation is based on the original FOOOF project:
% https://github.com/fooof-tools/fooof
% Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0)
% Translated to MATLAB by Claude Sonnet 3.7, corrected by Sophia Snipes,
% 2025.



freqs = model.freqs;
flat_iter = model.spectrum_flat; % Use the flattened spectrum stored in the model
guess = [];

% Find peak: Loop through, finding candidate peaks and fitting with gaussians
while size(guess, 1) < model.max_n_peaks
    
    % Find candidate peak - the maximum point of the flattened spectrum
    [max_height, max_ind] = max(flat_iter);
    
    % Stop searching for peaks once height drops below threshold
    if max_height <= model.peak_threshold * std(flat_iter)
        break
    end
    
    % Get the guess parameters for gaussian fitting
    guess_freq = freqs(max_ind);
    guess_height = max_height;
    
    % Halt fitting process if candidate peak drops below minimum height
    if ~(guess_height > model.min_peak_height)
        break
    end
    
    % Data-driven first guess at standard deviation
    % Find half height index on each side of the center frequency
    half_height = 0.5 * max_height;
    
    % Find index of nearest value to half height on left side
    le_ind = find(flat_iter(1:max_ind) <= half_height, 1, 'last');
    if isempty(le_ind)
        le_ind = NaN;
    end
    
    % Find index of nearest value to half height on right side
    ri_ind = find(flat_iter(max_ind:end) <= half_height, 1, 'first') + max_ind - 1;
    if isempty(ri_ind)
        ri_ind = NaN;
    end
    
    % Estimate width of the peak from the shortest side
    if ~isnan(le_ind) && ~isnan(ri_ind)
        % Get the shortest side
        short_side = min(abs([le_ind, ri_ind] - max_ind));
        
        % Estimate std deviation from FWHM
        fwhm = short_side * 2 * model.freq_res;
        guess_std = fwhm / (2 * sqrt(2 * log(2))); % Convert FWHM to std
    else
        % Default to the average of the peak width limits if half height not found
        guess_std = mean(model.gauss_std_limits);
    end
    
    % Limit std to preset boundaries
    if guess_std < model.gauss_std_limits(1)
        guess_std = model.gauss_std_limits(1);
    elseif guess_std > model.gauss_std_limits(2)
        guess_std = model.gauss_std_limits(2);
    end
    
    % Add guessed parameters to the collection
    guess = [guess; guess_freq, guess_height, guess_std];
    
    % Subtract this guess gaussian from the data
    peak_gauss = oscip.sputils.gaussian_function(freqs, [guess_freq, guess_height, guess_std]);
    flat_iter = flat_iter - peak_gauss;
end

% Check peaks based on edges and overlap, dropping any that violate requirements
guess = drop_peak_cf(model, guess);
guess = drop_peak_overlap(model, guess);

% If there are peak guesses, fit the peaks and sort results
if ~isempty(guess)
    gaussian_params = oscip.sputils.fit_peak_guess(model, guess);
    [~, sort_inds] = sort(gaussian_params(:, 1)); % Sort by center frequency
    gaussian_params = gaussian_params(sort_inds, :);
else
    gaussian_params = [];
end

end

function guess = drop_peak_cf(model, guess)
% Check whether to drop peaks based on center's proximity to the edge of the spectrum

if isempty(guess)
    return;
end

cf_params = guess(:, 1);
bw_params = guess(:, 3) * model.bw_std_edge;

% Check if peaks are within drop threshold from the edge of the frequency range
keep_peak = abs(cf_params - model.freq_range(1)) > bw_params & ...
           abs(cf_params - model.freq_range(2)) > bw_params;

% Drop peaks that fail the center frequency edge criterion
guess = guess(keep_peak, :);

end

function guess = drop_peak_overlap(model, guess)
% Checks whether to drop gaussians based on amount of overlap

if isempty(guess)
    return;
end

% Sort the peak guesses by increasing frequency
[~, sort_inds] = sort(guess(:, 1));
guess = guess(sort_inds, :);

% Calculate bounds for checking amount of overlap
bounds = zeros(size(guess, 1), 2);
for i = 1:size(guess, 1)
    bounds(i, :) = [guess(i, 1) - guess(i, 3) * model.gauss_overlap_thresh, ...
                   guess(i, 1) + guess(i, 3) * model.gauss_overlap_thresh];
end

% Check for overlapping peaks
drop_inds = [];
for i = 1:(size(bounds, 1) - 1)
    if bounds(i, 2) > bounds(i+1, 1)
        % If overlap, get the index of the gaussian with the lowest height (to drop)
        if guess(i, 2) < guess(i+1, 2)
            drop_inds = [drop_inds, i];
        else
            drop_inds = [drop_inds, i+1];
        end
    end
end

% Remove duplicates and sort
drop_inds = unique(drop_inds);
keep_inds = setdiff(1:size(guess, 1), drop_inds);

% Keep only non-overlapping peaks
guess = guess(keep_inds, :);

end