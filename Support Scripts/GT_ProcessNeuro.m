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
%   Last Revised: March 8th, 2019
%________________________________________________________________________________________________________________________

% Trim the analog neural signal to the proper length based on the trial duration.
analogFs = RawData.an_fs;
expectedLength = trialDuration_Seconds*analogFs;
neuralData = RawData.Neuro(1:min(expectedLength, length(RawData.Neuro)));

% Set the passband based on the function's string input
switch neurType
    case 'MUApower'
        fpass = [300 3000];
    case 'Gam'
        fpass = [40 100];
    case 'Beta'
        fpass = [13 30];
    case 'Alpha'
        fpass = [8 12];
    case 'Theta'
        fpass = [4 8];
    case 'Delta'
        fpass = [1 4];
end

% filter (bandpass), resample (to 30 Hz), and filter (smooth) the squared signal (neural 'power')
% based on the input string
if ismember(neurType, [{'MUApower'}, {'Gam'}, {'Beta'}, {'Alpha'}, {'Theta'}, {'Delta'}])
    neuroFs = 30;
    [z, p, k] = butter(4, fpass/(analogFs/2));
    [sos, g] = zp2sos(z, p, k);
    filtNeuro = filtfilt(sos, g, neuralData - mean(neuralData));
    [z1, p1, k1] = butter(4, 1/(analogFs/2), 'low');%changed from 10Hz to 1Hz lowpass filter of neural data
    [sos1, g1] = zp2sos(z1, p1, k1);
    longNeuro = filtfilt(sos1, g1, filtNeuro.^2);
    % WARNING. Certain 3rd-party image processing packages have been caught using identical function names
    % as some of the resample function's dependencies. If this line pops an error, check to make sure the proper
    % sub-function is being called.
    neuro = max(resample(longNeuro, neuroFs, analogFs), 0);
end

end
