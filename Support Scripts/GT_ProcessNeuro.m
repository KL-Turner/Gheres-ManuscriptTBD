function [neuro, neuroFs] = GT_ProcessNeuro(RawData, neurType, trialDuration_Seconds)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%________________________________________________________________________________________________________________________
%
%   Purpose:
%________________________________________________________________________________________________________________________
%
%   Inputs:
%
%   Outputs: 
%
%   Last Revised: February 29th, 2019
%________________________________________________________________________________________________________________________

%% Thresholds and Neurtype switch
analogFs = RawData.an_fs;
expectedLength = trialDuration_Seconds*analogFs;
neuralData = RawData.Neuro(1:min(expectedLength, length(RawData.Neuro)));

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

%% CALCULATE NEURAL POWER
if ismember(neurType, [{'MUApower'}, {'Gam'}, {'Beta'}, {'Alpha'}, {'Theta'}, {'Delta'}])
    neuroFs = 30;
    [z, p, k] = butter(4, fpass / (analogFs / 2));
    [sos, g] = zp2sos(z, p, k);
    filtNeuro = filtfilt(sos, g, neuralData - mean(neuralData));
    [z1, p1, k1] = butter(4, 10 / (analogFs / 2), 'low');
    [sos1, g1] = zp2sos(z1, p1, k1);
    longNeuro = filtfilt(sos1, g1, filtNeuro.^2);
    neuro = max(resample(longNeuro, neuroFs, analogFs), 0);
end

end
