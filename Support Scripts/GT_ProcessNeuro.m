function [neuro, neuroFs] = GT_ProcessNeuro(RawData, neurType, trialDuration_Seconds)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%________________________________________________________________________________________________________________________
%
%   Purpose: Filter and resample the analog neural data based on the desired neural type.
%________________________________________________________________________________________________________________________
%
%   Inputs: RawData.mat (struct) containing notes and the neural data.
%           neurType (string) of the desired neural band. See switch statement below for valid bands.
%           trialDuration_Seconds - value of the time of imaging, typically 300 seconds.
%
%   Outputs: neuro (double) array of the processed neural data.
%            neurFs (double) of the downsample Fs.
%
%   Last Revised: April 15, 2019
%Added band pass ranges for sleep scoring of hippocampal stereotrode
%recordings from:
%Chen, Z. & Wilson, M. A. Deciphering Neural Codes of Memory during
%Sleep. Trends Neurosci. 40, 260–275 (2017). Box 1.
%and
%Bergel, A., Def, T., Demené, C., Tanter, M. & Cohen, I. 
%Local hippocampal fast gamma rhythms precede brain-wide hyperemic patterns during spontaneous rodent REM sleep.
%Nat. Commun. (2018). doi:10.1038/s41467-018-07752-3
%and
%Sullivan, D., Mizuseki, K., Sorgi, A. & Buzsaki, G.
%Comparison of Sleep Spindles and Theta Oscillations in the Hippocampus.
%J. Neurosci. 34, 662–674 (2014).
%
%-KWG
%________________________________________________________________________________________________________________________

% Trim the analog neural signal to the proper length based on the trial duration.
analogFs = RawData.an_fs;
expectedLength = trialDuration_Seconds*analogFs;
neuralData = RawData.Neuro(1:min(expectedLength, length(RawData.Neuro)));

% Set the passband based on the function's string input
switch neurType
    case 'MUApower'
        fpass = [300 3000];
    case 'EMGpower'
        fpass = [300 5000];
        neuralData=RawData.MUA;
    case 'SullivanRipple'
        fpass = [95 200];
    case 'BergelRipple'
        fpass = [150 250];
    case 'ChenHighGam'
        fpass = [60 120];
    case 'BergelFastGam'
        fpass = [100 150];
    case 'BergelMidGam'
        fpass = [50 100];
    case 'BergelLowGam'
        fpass = [20 50];
    case 'ChenLowGam'
        fpass = [35 50];
    case 'Gam'
        fpass = [40 95];
    case 'Beta'
        fpass = [13 30];
    case 'Alpha'
        fpass = [8 12];
    case 'SullivanSpindle'
        fpass = [10 17];
    case 'Theta'
        fpass = [4 8];
    case 'BergelTheta'
        fpass = [4 10];
     case 'ChenTheta'
        fpass = [4 9];
    case 'Delta'
        fpass = [0.3 4];
    case 'ChenSlowWave'
        fpass = [0.5 1];
end

% filter (bandpass), resample (to 30 Hz), and filter (smooth) the squared signal (neural 'power')
% based on the input string
if ismember(neurType, [{'MUApower'}, {'Gam'}, {'Beta'}, {'Alpha'}, {'Theta'}, {'Delta'},{'SullivanSpindle'},{'SullivanRipple'},{'BergelTheta'}])
    neuroFs = 30;
    [z, p, k] = butter(4, fpass/(analogFs/2));
    [sos, g] = zp2sos(z, p, k);
    filtNeuro = filtfilt(sos, g, neuralData - mean(neuralData));
    
    [z1, p1, k1] = butter(4, 10/(analogFs/2), 'low');
    [sos1, g1] = zp2sos(z1, p1, k1);
    longNeuro = filtfilt(sos1, g1, filtNeuro.^2);
   
    % WARNING. Certain 3rd-party image processing packages have been caught using identical function names
    % as some of the resample function's dependencies. If this line pops an error, check to make sure the proper
    % sub-function is being called.
    neuro = max(resample(longNeuro, neuroFs, analogFs), 0);
elseif strcmpi(neurType,'EMGpower')
    neuroFs = analogFs;
    [z, p, k] = butter(4, fpass/(analogFs/2));
    [sos, g] = zp2sos(z, p, k);
    neuro=filtfilt(sos, g, neuralData - mean(neuralData)).^2;
%     filtNeuro = filtfilt(sos, g, neuralData - mean(neuralData));
%     [z1, p1, k1] = butter(4, 2/(analogFs/2), 'low');%changed from 10Hz to 2Hz lowpass filter of neural data
%     [sos1, g1] = zp2sos(z1, p1, k1);
%     neuro = filtfilt(sos1, g1, filtNeuro.^2);
end

end
