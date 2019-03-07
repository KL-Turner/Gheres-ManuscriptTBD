# Automated sleep scoring analysis with GUI inputs

 * Clone (git clone https://github.com/KL-Turner/Gheres-Manuscript.git) or manually download the entire contents of the Gheres-Manuscript repository.
 * Add contents to your Matlab filepath by putting it in the MATLAB folder or by putting it in the documents folder and running in the Matlab command window:
    * Windows: addpath(genpath('C:\Users\YourProfileName\Documents\Gheres-Manuscript'))
    * macOS (Unix): addpath(genpath('/Users/YourProfileName/Documents/Gheres-Manuscript')) - Note; the GUI is not yet fully optimized for cross-platform functionality. It is fully functional, does not display as cleanly in macOS.
 * Change Matlab working directory to data location.
 * Run GT_MainScript.m, which can be ran independently or called as a function with no inputs. 

# Running the function

| ![]https://github.com/KL-Turner/Gheres-Manuscript/blob/master/Misc/GUI_photo.PNG |
|:--:|
| *Figure 1: Graphical User Input (GUI) front interface* |

Adjust the analysis parameters appropriately in the GUI, or run the default settings. The default settings are outline in the table below, along with a brief description of what each value corresponds to.

| Analysis Parameter                 | Accepted Values                                 | Default Value           | Description                                                |
| :---                               | :---                                            | :---                    | :---                                                       |
| Hippocampal LFP                    | x > 1                                           | 4 fold-change           | Minumum fold-change above resting baseline per time bin.   |
| Ball Velocity                      | y >= 0                                          | 3 events                | Maximum number of binarized events per time bin.           |
| Heart Rate                         | 5 <= z <= 16                                    | 7 Hz                    | Maximum allowed heart rate.                                |
| Estimated awake duration           | 5 min <= t1 (mult. of 5) <= total min per day   | 30 minutes              | Time (min) used to calculate resting baseline values.      |
| Minimum require sleep duration     | 5 sec <= t2 (mult. of 5) <= 300 sec             | 30 seconds              | Minumumm time (sec) required for a successful sleep epoch. |
| Analysis identifier                | Any character string                            | SleepParams_Test01      | Identifier for results to be saved in current directory.   |

There are various options that can be toggled on or off. 
   * Three scoring parameters (default on) that can be turned off to evaluate how much confidence you gain/lose with each parameter. 
   * Two options that will determine whether the results of the analysis are saved and/or create/save summary figures of the found sleep epochs.
   * Four options to re-run the parts of the analysis that will normally only run during the first iteration. This can be utilized to change things that are hard-coded into the original analysis, such as using periods of 10 seconds or more to determine rest, using a certain filter order, set of tapers/pass band/window size, etc. 

| Analysis Toggle Option (on/off)    | Default Value   | Description                                                                                                          |
| :---                               | :---            | :---                                                                                                                 |
| Hippocampal LFP                    | on              | Use the Hippocampal LFP (Delta/Theta Rhythms) in scoring analysis (recommended).                                     |
| Ball Velocity                      | on              | Use the ball velocity in scoring analysis (recommended).                                                             |
| Heart Rate                         | on              | Use the heart rate in scoring analysis (optional).                                                                   |
| Save SleepData.mat Structure       | on              | Save structure containing results under the Analysis indentifier label.                                              |
| Save Single Trial Summary Figures  | off             | If sleep events are found, create a summary figure and save it in a folder under the Analysis indentifier label.     |
| Anaylze Processed Data**           | off             | Re-run the block that calculates individual neural bands and binarizes the ball velocity threshold.                  |
| Anaylze Data Categorization**      | off             | Re-run the block that categorizes the behavior using ball velocity and whisker puff times.                           |
| Anaylze Spectrograms**             | off             | Re-run the block that analyzes the spectrogram of the neural data.                                                   |
| Anaylze Resting Baselines**        | off             | Re-run the block that calculates the resting baselines during resting periods (default periods >= 10 seconds)        |

Hit the green 'GO.' button to begin the analysis. A set loading bars will be displayed that keeps track the analysis' progression. The only prompts occur in block one, where the user is requested an input to define the ball velocity's acceleration threshold. Follow the prompts to set and then confirm the threshold value. This will occur for each unique day of imaging.

| ![]https://github.com/KL-Turner/Gheres-Manuscript/blob/master/Misc/ProgressBar_Photo.PNG |
|:--:|
| *Figure 2: Loading bars showing analysis progression* |

# Displayed results

# Error messages


# Acknowledgements
* multiWaitbar.m Author: Ben Tordoff https://www.mathworks.com/matlabcentral/fileexchange/26589-multiwaitbar-label-varargin
* colors.m Author: John Kitchin http://matlab.cheme.cmu.edu/cmu-matlab-package.html
* Chronux subfunctions http://chronux.org/
* Several functions utilize varying bits of code written by Dr. Patrick J. Drew and Dr. Aaron T. Winder https://github.com/DrewLab

###### send bugs and/or caffeinated-liquids to klt8@psu.edu