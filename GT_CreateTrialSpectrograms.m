function [RawDataSpectrogramData] = GT_CreateTrialSpectrograms(animalID, mergedDataFiles, RawDataSpectrogramData)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% Ph.D. Candidate, Department of Bioengineering
% The Pennsylvania State University
%________________________________________________________________________________________________________________________
%
%   Purpose: //
%________________________________________________________________________________________________________________________
%
%   Inputs: //
%
%   Outputs: //
%________________________________________________________________________________________________________________________

    load(rawDataFile);
    [~, ~, fileID, vesselID] = GetFileInfo_2P(rawDataFile);
    RawNeuro = RawData.Data.Raw_NeuralData;
    
    w0 = 60/(20000/2);  bw = w0/35;
    [num,den] = iirnotch(w0, bw);
    RawNeuro2 = filtfilt(num, den, RawNeuro);

    % Spectrogram parameters
    params.tapers = [5 9];
    params.Fs = RawData.Notes.MScan.MScan_analogSamplingRate;
    params.fpass = [0.1 100];
    movingwin1 = [1 1/5];
    movingwin5 = [5 1/5];
    
    [Neural_S1, Neural_T1, Neural_F1] = mtspecgramc(RawNeuro2, movingwin1, params);
    [Neural_S5, Neural_T5, Neural_F5] = mtspecgramc(RawNeuro2, movingwin5, params);
    
    RawData.GT_SleepAnalysis.spectrogramData.FiveSec.S{fileNumber, 1} = Neural_S5';
    RawData.GT_SleepAnalysis.spectrogramData.FiveSec.T{fileNumber, 1} = Neural_T5;
    RawData.GT_SleepAnalysis.spectrogramData.FiveSec.F{fileNumber, 1} = Neural_F5;
    RawData.GT_SleepAnalysis.spectrogramData.VesselIDs{fileNumber, 1} = vesselID;
    RawData.GT_SleepAnalysis.spectrogramData.FileIDs{fileNumber, 1} = fileID;
    RawData.GT_SleepAnalysis.spectrogramData.Notes.params = params;
    RawData.GT_SleepAnalysis.spectrogramData.Notes.movingwin5 = movingwin5;
    
    RawData.GT_SleepAnalysis.spectrogramData.OneSec.S{fileNumber, 1} = Neural_S1';
    RawData.GT_SleepAnalysis.spectrogramData.OneSec.T{fileNumber, 1} = Neural_T1;
    RawData.GT_SleepAnalysis.spectrogramData.OneSec.F{fileNumber, 1} = Neural_F1;
    RawData.GT_SleepAnalysis.spectrogramData.Notes.movingwin1 = movingwin1; 

save(rawDataFile, 'RawData', '-v7.3');

end
