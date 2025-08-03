# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a MATLAB toolbox for detecting oscillations in EEG recordings by finding periodic bumps in power spectra that emerge from aperiodic signals. The toolbox implements spectral parameterization (FOOOF/SpecParam) to separate periodic from aperiodic components and detect specific oscillatory bands like iota (25-37 Hz).

## Core Architecture

### Package Structure
The main functionality is organized in the `+oscip` MATLAB package with sub-packages:
- `+sputils`: Spectral parameterization utilities (FOOOF/SpecParam implementation)
- `+utils`: General utility functions for data processing
- `+plot`: Visualization functions
- `+external`: Third-party code (sigm_fit)

### Key Workflows
1. **Power Spectrum Calculation**: `compute_power()` or `compute_power_on_epochs()` using Welch's method
2. **Spectral Smoothing**: `smooth_spectrum()` to reduce noise before FOOOF fitting
3. **FOOOF Fitting**: Two implementations available:
   - Python wrapper: `fit_fooof()` (original, requires Python FOOOF)
   - Native MATLAB: `fit_fooof_matlab()` or `specparam_matlab()` (newer implementation)
4. **Peak Detection**: `check_peak_in_band()` to identify oscillations in specific frequency ranges

### Main Entry Points
- `Example1_iota.m`: Complete workflow for detecting iota oscillations
- `fit_fooof_multidimensional()`: Process multiple channels/epochs simultaneously
- `default_settings()`: Configuration for peak detection parameters

## Development Commands

### Testing
```matlab
% Run main test suite
run('tests/test_specparam_matlab.m')

% Test utilities
run('tests/test_utils.m')
```

### Example Usage
```matlab
% Basic workflow (see Example1_iota.m for complete example)
[Power, Frequencies] = oscip.compute_power_on_epochs(Data, SampleRate, EpochLength);
SmoothPower = oscip.smooth_spectrum(Power, Frequencies, 2);
[~, ~, FooofFrequencies, PeriodicPeaks, ~] = oscip.fit_fooof_multidimensional(SmoothPower, Frequencies, [3 40]);
[isPeak, MaxPeak] = oscip.check_peak_in_band(PeriodicPeaks, [25 35], 1, oscip.default_settings());
```

## Dependencies

### Required
- FOOOF for MATLAB (Python wrapper): https://github.com/fooof-tools/fooof_mat
- Compatible Python version (3.8-3.10) with `fooof` package installed
- MATLAB Signal Processing Toolbox (for `pwelch`)

### Optional
- MATLAB Parallel Computing Toolbox (for faster processing)
- EEGLAB (for some plotting functions in examples)
- chART plotting toolbox (for Example0 visualizations)

### Python Setup (for FOOOF wrapper)
The toolbox supports both Python FOOOF wrapper and native MATLAB implementation. For Python FOOOF:
1. Install compatible Python version
2. Create virtual environment and install `fooof` package
3. Configure MATLAB Python environment with `pyenv()`

## Key Implementation Details

### Spectral Parameterization
- Native MATLAB implementation in `+sputils/fit_model.m` provides FOOOF-compatible results
- Handles aperiodic background fitting, peak detection, and model validation
- Error handling for failed fits with diagnostic information

### Peak Detection Settings
Critical parameters in `default_settings()`:
- `PeakBandwidthMin/Max`: Filter peaks by bandwidth (0.5-4 Hz typical for oscillations)
- `PeakAmplitudeMin`: Minimum peak amplitude threshold
- `DistributionBandwidthMin/Max`: For histogram-based peak frequency detection

### Data Formats
- Input: Channel × Time matrices (supports unpreprocessed data)
- Power: Channel × Frequency or Channel × Epoch × Frequency
- PeriodicPeaks: Channel × Epoch × 3 (frequency, amplitude, bandwidth)

## Testing Strategy

Tests validate MATLAB implementation against Python FOOOF results with configurable tolerance (`AcceptableDifference = 0.01`). Key test areas:
- Spectral parameter accuracy (slopes, intercepts, peak parameters)
- Settings compatibility between Python and MATLAB versions
- Utility function correctness (scoring alignment, data processing)

## Python vs MATLAB Implementation Differences

The MATLAB implementation aims to replicate Python FOOOF behavior but has several key differences that may cause minor result variations:

### Core Algorithm Differences
1. **Data validation timing**: Python checks for NaN/Inf values conditionally during fitting based on `_check_data` flag. MATLAB currently lacks this conditional check.

2. **Memory handling**: Python explicitly copies flattened spectrum (`np.copy(self._spectrum_flat)`) before peak fitting to prevent modification. MATLAB relies on internal copying within functions.

3. **Parameter flattening**: Python flattens gaussian parameters before passing to `gen_periodic()` using `np.ndarray.flatten()`. MATLAB may need explicit reshaping.

### Optimization Differences
1. **Algorithm selection**: Python uses `scipy.optimize.curve_fit` which defaults to Levenberg-Marquardt ('lm') without bounds, Trust Region Reflective ('trf') with bounds. MATLAB uses `lsqcurvefit` with explicit 'trust-region-reflective' algorithm.

2. **Tolerance parameters**: Python uses `ftol`, `xtol`, `gtol` parameters. MATLAB maps these to `FunctionTolerance`, `StepTolerance`, `OptimalityTolerance`.

3. **Error handling approach**: Python uses try/except with `ValueError` for edge cases (e.g., peak width estimation). MATLAB uses explicit NaN checks and conditionals.

### Peak Detection Differences
1. **Half-height search**: Python uses generator expressions with `next()` and `None` defaults for finding half-height indices. MATLAB uses `find()` with directional search ('first'/'last') - functionally equivalent but different implementation.

2. **Error handling**: Python's try/except approach for bandwidth estimation vs MATLAB's explicit conditional checks both achieve the same result but through different code paths.

### Minor Implementation Details
- Array indexing (Python 0-based vs MATLAB 1-based) handled correctly in both but with different syntax
- Both use identical mathematical formulations and default parameter values
- Optimization bounds and constraints implemented equivalently

These differences primarily affect code structure and error handling rather than core mathematical computations, but may contribute to small numerical variations between implementations.


## Instructions

The original python code can be found here:
C:\Users\colas\Code\Lapse-Causes\.env\Lib\site-packages\fooof


In test_for_claude.m there's code running both the python version of fooof and the current matlab version. figure out why they give different results. provide a summary of all the lines responsible.

of course, ignore anything that isn't strictly functional relevant, such as variable names.

The most likely culprit is some change in default parameters, or different handling of exception or edge cases. 

When running test_for_claude, I am strictly feeding both algorithms the same settings, so they should be the same unless they are changed somewhere downstream. catch that if you can.

be THOROUGH, look through all the little sub scripts and functions. consider defaults that python and matlab may have and that aren't necessarily explicit in the code. 

you should finish by providing changes that I can make to the matlab code that will yield identical plots. 

When you've got your answer, double check it that it's correct