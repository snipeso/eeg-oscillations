# eeg-oscillations
This a little toolbox to detect what are the main oscillations present in EEG recordings. It does so by finding periodic bumps in the power spectrum emerging from the aperiodic signal. These scripts work for a single spectrum per recording, but work best when providing many spectra, e.g. for different channels and/or different epochs. This can be run directly on raw data.

##


## Requirements
The only other repository needed is FOOOF. Below are the instructions for installing the toolbox, but maybe follow first the ones provided by the FOOOF repository directly.

### to run fooof scripts on windows

1. (Browser) install fooof for matlab: https://github.com/fooof-tools/fooof_mat
2. (Powershell / Windows search) make sure your computer has a version of python that works for your version of matlab (3.8 to 2.10 atm)
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

