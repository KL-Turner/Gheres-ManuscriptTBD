function [GT_AnalysisInfo] = GT_CreateTrialSpectrograms(rawDataFile, GT_AnalysisInfo)
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
RawNeuro = RawData.Neuro;

w0 = 60/(RawData.an_fs/2);  bw = w0/35;
[num,den] = iirnotch(w0, bw);
filtRawNeuro = filtfilt(num, den, RawNeuro);

% Spectrogram parameters
params.tapers = [5 9];
params.Fs = RawData.an_fs;
params.fpass = [0.1 100];
movingwin1 = [1 1/5];
movingwin5 = [5 1/5];

[Neural_S1, Neural_T1, Neural_F1] = mtspecgramc(filtRawNeuro, movingwin1, params);
[Neural_S5, Neural_T5, Neural_F5] = mtspecgramc(filtRawNeuro, movingwin5, params);

RawData.GT_SleepAnalysis.spectrogramData.FiveSec.S = Neural_S5';
RawData.GT_SleepAnalysis.spectrogramData.FiveSec.T = Neural_T5;
RawData.GT_SleepAnalysis.spectrogramData.FiveSec.F = Neural_F5;
RawData.GT_SleepAnalysis.spectrogramData.Notes.params = params;
RawData.GT_SleepAnalysis.spectrogramData.Notes.movingwin5 = movingwin5;

RawData.GT_SleepAnalysis.spectrogramData.OneSec.S = Neural_S1';
RawData.GT_SleepAnalysis.spectrogramData.OneSec.T = Neural_T1;
RawData.GT_SleepAnalysis.spectrogramData.OneSec.F = Neural_F1;
RawData.GT_SleepAnalysis.spectrogramData.Notes.movingwin1 = movingwin1;

save(rawDataFile, 'RawData', '-v7.3');

end
