function GT_NormalizeData(sleepScoringDataFile, GT_AnalysisInfo, SpectrogramData)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Normalize spectrograms and other data by the unique day's resting baseline values.
%________________________________________________________________________________________________________________________
%
%   Inputs: sleepScoringDataFile (string) file ID to be normalized.
%           GT_AnalysisInfo.mat (struct) of sleep scoring results summary.
%           SpectrogramData.mat (struct) of spectrogram data for each file.
%
%   Outputs: None - saves normalized value to each SleepScoringData.mat file.
%
%   Last Revised: March 9th, 2019
%________________________________________________________________________________________________________________________

load(sleepScoringDataFile)
[~, ~, fileDate, fileID] = GT_GetFileInfo(sleepScoringDataFile);
strDay = GT_ConvertDate(fileDate);

cbvBaseline = GT_AnalysisInfo.baselines.CBV.(strDay);
deltaBaseline = GT_AnalysisInfo.baselines.deltaBandPower.(strDay);
thetaBaseline = GT_AnalysisInfo.baselines.thetaBandPower.(strDay);
gammaBaseline = GT_AnalysisInfo.baselines.gammaBandPower.(strDay);
oneSpecBaseline = GT_AnalysisInfo.baselines.Spectrograms.OneSec.(strDay);
fiveSpecBaseline = GT_AnalysisInfo.baselines.Spectrograms.FiveSec.(strDay);

for s = 1:length(SpectrogramData.FileIDs)
    if strcmp(SpectrogramData.FileIDs{s,1}, fileID)
        S1 = SpectrogramData.OneSec.S{s,1};
        T1 = SpectrogramData.OneSec.T{s,1};
        F1 = SpectrogramData.OneSec.F{s,1};
        S5 = SpectrogramData.FiveSec.S{s,1};
        T5 = SpectrogramData.FiveSec.T{1,1};
        F5 = SpectrogramData.FiveSec.F{s,1};
    end
end

hold_matrix1 = oneSpecBaseline.*ones(size(S1));
hold_matrix5 = fiveSpecBaseline.*ones(size(S5));

S1_Norm = (S1 - hold_matrix1) ./ hold_matrix1;
S5_Norm = (S5 - hold_matrix5) ./ hold_matrix5;

SleepScoringData.Spectrograms.OneSec.S1_Norm = S1_Norm;
SleepScoringData.Spectrograms.FiveSec.S5_Norm = S5_Norm;
SleepScoringData.Spectrograms.OneSec.T1 = T1;
SleepScoringData.Spectrograms.FiveSec.T5 = T5;
SleepScoringData.Spectrograms.OneSec.F1 = F1;
SleepScoringData.Spectrograms.FiveSec.F5 = F5;

SleepScoringData.normCBV = (SleepScoringData.CBV - cbvBaseline) ./ cbvBaseline;
SleepScoringData.normDeltaBandPower = (SleepScoringData.deltaBandPower - deltaBaseline) ./ deltaBaseline;
SleepScoringData.normThetaBandPower = (SleepScoringData.thetaBandPower - thetaBaseline) ./ thetaBaseline;
SleepScoringData.normGammaBandPower = (SleepScoringData.gammaBandPower - gammaBaseline) ./ gammaBaseline;
save(sleepScoringDataFile, 'SleepScoringData');

end
