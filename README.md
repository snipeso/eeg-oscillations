# eeg-oscillations
This a little toolbox to detect what are the main oscillations present in EEG recordings. It does so by finding periodic bumps in the power spectrum emerging from the aperiodic signal. These scripts work for a single spectrum per recording, but work best when providing many spectra, e.g. for different channels and/or different epochs. This can be run directly on raw data.

## How to run
1. set up FOOOF for matlab (see below)
2. Make sure the folder containing +oscip is added to the matlab path 
3. Run one of the three example scripts 


### How to detect iota
Try first the example script [Example1](./Example1_iota.m). Below are the minimum steps necessary:

1. Detect power: `[Power, Frequencies] = oscip.compute_power_on_epochs(Data, SampleRate, EpochLength)`. Data needs to be a Channel x Time matrix. It can even be completely unpreprocessed, although it helps if it has been preprocessed. A good epoch length is 20 or 30 (seconds). If you don't want epochs, you can run `[Power, Frequencies] = oscip.compute_power(Data, SampleRate)`, but then you really need the data preprocessed. You can also calculate power on your own if you prefer, but later results may vary.
2. Smooth power: `Power = oscip.smooth_spectrum(Power, Frequencies, 2)`. This helps avoid spurious peaks that emerge from spectra calculated over too-short epochs. 
3. Run FOOOF on all the data: `[~, ~, FrequenciesPeriodic, PeriodicPeaks, PeriodicPower] = oscip.fit_fooof_multidimentional(Power, Frequencies, [3 40])`. This loops through channels and epochs, and expects power to be Channel x Epoch x Frequency or Channel x Frequency. If you only have one spectrum, you can just run `[~, ~, FrequenciesPeriodic, PeriodicPeaks, PeriodicPower] = oscip.fit_fooof(Power, Frequencies, [3 40])`.

If you ran the multidimentional function, PeriodicPeaks is a Channel x Epoch x 3 matrix, with the third dimention containing peak frequency, peak amplitude, and peak bandwidth for the periodic peak with the largest amplitude for a given channel&epoch. If you ran just `fit_fooof`, then periodic peaks is a P x 3 matrix, with every peak detected in the spectrum listed.

To detect whether iota is present in the spectrum, especially if its in a multidipentioanl PeriodicPeaks matrix, run the following:

```
Band = [25 35];
nPeaks = 1;
PeakDetectionSettings = oscip.default_settings();
PeakDetectionSettings.PeakBandwidthMax = 4; % broader peaks are not oscillations
PeakDetectionSettings.PeakBandwidthMin = .5; % Hz; narrow peaks are more often than not noise

[isPeak, MaxPeak] = oscip.check_peak_in_band(PeriodicPeaks, Band, nPeaks, PeakDetectionSettings);
```


## Available functions


## Requirements
The only other repository needed is FOOOF. Below are the instructions for installing the FOOOF code for MATLAB, but maybe follow first the instructions provided by the FOOOF repository directly.
The code runs a lot faster if you have the Matlab Parallel processing toolbox.

The example script [ApplyImmediately.m](./Example0_ApplyImmediately.m) has some plots that rely on EEGLAB and my plotting toolbox [chART](https://github.com/snipeso/chart). 


### to run fooof scripts on windows

1. (Browser) install fooof for matlab: https://github.com/fooof-tools/fooof_mat
2. (Powershell / Windows search) make sure your computer has a version of python that works for your version of matlab (3.8 to 2.10 atm). Check [here](https://ch.mathworks.com/support/requirements/python-compatibility.html?s_tid=srchtitle_site_search_1_python%20compatibility) for which version of python you need for which version of matlab.
    - To install an older version, you need to go to the python release that includes a binary exectuable, which will be called `Windows installer (64-bit)`, like here: https://www.python.org/downloads/release/python-31011/. Not all releases come with it.
3. (Powershell), create a virtual enviroment ` python3.exe -m venv C:\Users\colas\Code\Lapse-Causes\.env` (use your own path to code directory)
4. (Powershell) activate that enviromentment `C:\Users\colas\Code\Lapse-Causes\.env\Scripts\Activate.ps1`
5. (env Powershell) install fooof package `pip install fooof`
6. (MATLAB) set up the python enviroment for your current session `pyenv('Version', 'C:\Users\colas\Code\Lapse-Causes\.env\Scripts\python', 'ExecutionMode','OutOfProcess')`
7. (MATLAB) Add the fooof scripts to matlab path `C:\Users\colas\Code\fooof_mat\fooof_mat`
 


## Example data
This repo comes with 4 example files from 2 participants, one wake (~2h watching TV) and one sleep (4 h). Data is at 200 Hz sampling rate. Wake data was filtered from .5 to 40 Hz, sleep data was only notch filtered at 50 Hz. Wake data was average referenced, sleep data was referenced to the mastoids. These differences are not pertinent to this analysis.

Each file contains:
- `EEG`: an EEGLAB structure, with data saved in a channel x time matrix (EEG.data), sample rate (EEG.srate), and channel information (EEG.chanlocs).
- `Scoring`: an array with values from -3 to 1, indicating sleep stages for 20 s epochs
- `EpochLength`: the epoch length of the scoring (20 s)
- `ScoringIndexes`: the range of possible values inside Scoring ([-3 -2 -1 0 1])
- `ScoringLabels`: cell array of the stages associated with each scoring index ({'N3', 'N2', 'N1', 'W', 'R'})

