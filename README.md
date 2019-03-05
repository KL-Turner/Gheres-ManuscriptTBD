# Automated sleep scoring analysis with GUI inputs

 **1) Clone (git clone https://github.com/KL-Turner/Gheres-Manuscript.git) or manually download the entire contents of the Gheres-Manuscript repository.**  
 **2) Add contents to your Matlab filepath by putting it in the MATLAB folder or by putting it in the documents folder and running:**
     **- Windows: addpath(genpath('C:\Users\YourProfileName\Documents\Gheres-Manuscript'))**
     **- macOS (Unix): addpath(genpath('/Users/YourProfileName/Documents/Gheres-Manuscript'))**
 **3) Clone (git clone https://github.com/KL-Turner/Gheres-Manuscript.git) or manually download the entire contents of the Gheres-Manuscript repository.**  

| ![](https://github.com/KL-Turner/Gheres-Manuscript/blob/master/GUI_photo.PNG) |
|:--:|
| *Figure 1: Graphical User Input front interface* |

| Analysis Parameter                 | Accepted Values                                 | Default Value           | Description                                                |
| :---                               | :---                                            | :---                    | :---                                                       |
| Hippocampal LFP                    | x > 1                                           | 4 fold-change           | Minumum fold-change above resting baseline per time bin.   |
| Ball Velocity                      | y >= 0                                          | 3 events                | Maximum number of binarized events per time bin.           |
| Heart Rate                         | 5 <= z <= 16                                    | 7 Hz                    | Maximum allowed heart rate.                                |
| Estimated awake duration           | 5 min <= t1 (mult. of 5) <= total min per day   | 30 minutes              | Time (min) used to calculate resting baseline values.      |
| Minimum require sleep duration     | 5 sec <= t2 (mult. of 5) <= 300 sec             | 30 seconds              | Minumumm time (sec) required for a successful sleep epoch. |
| Analysis identifier                | Any character string                            | SleepParams_Test01      | Identifier for results to be saved in current directory.   |


    Acknowledgements
    multiWaitbar.m Author: Ben Tordoff
    colors.m Author: John Kitchin http://matlab.cheme.cmu.edu/cmu-matlab-package.html
    Chronux subfunctions http://chronux.org/
    Several functions utilize varying bits of code written by Dr. Patrick J. Drew and Dr. Aaron T. Winder
