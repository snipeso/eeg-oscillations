function SpecModel = specparam_python(power_spectrum, freqs, params)
% SPECPARAM_PYTHON Calls the Python version of specparam to fit the model
% This function serves as a wrapper to call the original Python implementation
%
% USAGE:
%   SpecModel = specparam_python(power_spectrum, freqs, params)
%
% INPUTS:
%   power_spectrum : 1d array
%       Power values for the spectrum, which must be input in linear space.
%   freqs : 1d array
%       Frequency values for the power spectrum.
%   params : struct, optional
%       Parameters for model fitting.
%
% OUTPUTS:
%   SpecModel : struct
%       A structure with the model fit results and parameters in the same format as specparam.m.

% Set default parameters if not provided
if nargin < 3 || isempty(params)
    params = struct();
end

% Initialize default output structure with input data
SpecModel = struct();
SpecModel.freqs = freqs;
SpecModel.power_spectrum = log10(power_spectrum);
SpecModel.freq_range = [min(freqs), max(freqs)];
SpecModel.freq_res = freqs(2) - freqs(1);

try
    % Check if Python is available
    try
        % Try to import the modules
        py.importlib.import_module('specparam');
        py.importlib.import_module('numpy');
    catch ME
        if contains(ME.message, 'No module named')
            error(['Required Python module not found: ', ME.message, ...
                '\nMake sure Python and required packages (specparam, numpy) are installed.']);
        else
            rethrow(ME);
        end
    end
    
    % Convert MATLAB arrays to Python numpy arrays
    % Convert to double and reshape to ensure proper conversion
    freqs_double = double(freqs(:)');
    power_spectrum_double = double(power_spectrum(:)');
    py_freqs = py.numpy.array(freqs_double);
    py_power_spectrum = py.numpy.array(power_spectrum_double);
    
    % Initialize arguments with defaults
    peak_width_limits = py.tuple({0.5, 12.0});
    max_n_peaks = py.float('inf');  % Using py.float for infinity 
    min_peak_height = py.float(0.0);
    peak_threshold = py.float(2.0);
    aperiodic_mode = 'fixed';
    verbose = py.bool(true);
    
    % Replace with user-provided values if available
    if isfield(params, 'peak_width_limits')
        % Handle peak_width_limits as a tuple
        if length(params.peak_width_limits) == 2
            peak_width_limits = py.tuple({py.float(params.peak_width_limits(1)), py.float(params.peak_width_limits(2))});
        end
    end
    
    if isfield(params, 'max_n_peaks')
        if isinf(params.max_n_peaks)
            max_n_peaks = py.float('inf');
        else
            max_n_peaks = py.int(params.max_n_peaks);
        end
    end
    
    if isfield(params, 'min_peak_height')
        min_peak_height = py.float(params.min_peak_height);
    end
    
    if isfield(params, 'peak_threshold')
        peak_threshold = py.float(params.peak_threshold);
    end
    
    if isfield(params, 'aperiodic_mode')
        aperiodic_mode = params.aperiodic_mode;
    end
    
    if isfield(params, 'verbose')
        verbose = py.bool(logical(params.verbose));
    end
    
    % Create model with individual parameters
    fm = py.specparam.SpectralModel(...
        pyargs('peak_width_limits', peak_width_limits, ...
              'max_n_peaks', max_n_peaks, ...
              'min_peak_height', min_peak_height, ...
              'peak_threshold', peak_threshold, ...
              'aperiodic_mode', aperiodic_mode, ...
              'verbose', verbose));
    
    % Fit the model
    fm.fit(py_freqs, py_power_spectrum);
    
    % Extract model results directly from fm properties
    SpecModel.freq_range = double(py.array.array('d', fm.freq_range));
    SpecModel.freq_res = double(fm.freq_res);
    
    % Extract aperiodic parameters
    SpecModel.aperiodic_params = convert_pyarray_to_matlab(fm.aperiodic_params);
    SpecModel.aperiodic_mode = char(fm.aperiodic_mode);
    
    % Extract modeled spectrum
    SpecModel.modeled_spectrum = convert_pyarray_to_matlab(fm.modeled_spectrum);
    
    % Extract peak parameters
    if ~isempty(fm.peak_params)
        SpecModel.peak_params = convert_pyarray_to_matlab(fm.peak_params);
    else
        SpecModel.peak_params = [];
    end
    
    % Extract gaussian parameters
    if ~isempty(fm.gaussian_params)
        SpecModel.gaussian_params = convert_pyarray_to_matlab(fm.gaussian_params);
    else
        SpecModel.gaussian_params = [];
    end
    
    % Extract number of peaks found
    SpecModel.n_peaks_ = double(fm.n_peaks_);
    
    % Extract error metrics
    SpecModel.r_squared = double(fm.r_squared);
    SpecModel.error = double(fm.error);
    
    % Extract internal components for plotting
    SpecModel.ap_fit = convert_pyarray_to_matlab(py.getattr(fm, '_ap_fit'));
    SpecModel.peak_fit = convert_pyarray_to_matlab(py.getattr(fm, '_peak_fit'));
    
    % Set flags
    SpecModel.fit_error = false;
    SpecModel.has_model = logical(fm.has_model);
    
catch ME
    % Set default/empty fields for error case
    SpecModel.aperiodic_params = [NaN, NaN];
    SpecModel.gaussian_params = [];
    SpecModel.peak_params = [];
    SpecModel.r_squared = NaN;
    SpecModel.error = NaN;
    SpecModel.modeled_spectrum = [];
    SpecModel.fit_error = true;
    SpecModel.errormsg = ['Python error: ', ME.message];
    SpecModel.errordetails = struct(...
        'message', ME.message, ...
        'identifier', ME.identifier, ...
        'stack', ME.stack ...
    );
end

end

function matlab_array = convert_pyarray_to_matlab(py_array)
% Helper function to convert Python numpy ndarray to MATLAB array
try
    % Get array shape
    shape = double(py.array.array('d', py_array.shape));
    
    % Convert to MATLAB array
    flat_array = double(py.array.array('d', py_array.flatten()));
    
    % Reshape if it's a 2D array
    matlab_array = reshape(flat_array, shape(2), shape(1))';
catch
    % Fallback method if above fails
    matlab_array = double(py.array.array('d', py_array));
end
end