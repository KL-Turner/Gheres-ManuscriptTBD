function [GT_AnalysisInfo] = GT_ProcessRawData(rawDataFile, GT_AnalysisInfo)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose:
%________________________________________________________________________________________________________________________
%
%   Inputs:
%
%   Outputs:
%
%   Last Revised:
%________________________________________________________________________________________________________________________

load(rawDataFile)
[animalID, hem, fileDate, fileID] = GT_GetFileInfo(rawDataFile);
strDay = GT_ConvertDate(fileDate);
trialDuration_Seconds = 300;
expectedLength = trialDuration_Seconds*RawData.an_fs;

% % Delta [1 - 4 Hz]
 [SleepScoringData.deltaBandPower, SleepScoringData.downSampled_Fs] = GT_ProcessNeuro(RawData, 'Delta', trialDuration_Seconds);
% 
% % Theta [4 - 8 Hz]
 [SleepScoringData.thetaBandPower, ~] = GT_ProcessNeuro(RawData, 'Theta', trialDuration_Seconds);
% 
% % Gamma Band [40 - 100]
 [SleepScoringData.gammaBandPower, ~] = GT_ProcessNeuro(RawData, 'Gam', trialDuration_Seconds);

%% Save solenoid times (in seconds).
% Identify the solenoids by amplitude
SleepScoringData.Sol.solenoidContralateral = find(diff(RawData.Sol) == 1) / RawData.an_fs;
SleepScoringData.Sol.solenoidIpsilateral = find(diff(RawData.Sol) == 2) / RawData.an_fs;
SleepScoringData.Sol.solenoidTail = find(diff(RawData.Sol) == 3) / RawData.an_fs;

%% Downsample and binarize the ball velocity.
% Trim any additional data points for resample
trimmedBallVelocity = RawData.vBall(1:min(expectedLength, length(RawData.vBall)));

% Filter then downsample the ball velocity waveform to desired frequency
downSampled_Fs = RawData.dal_fr;   % Downsample to CBV Camera Fs
ballVelocityFilterThreshold = 20;
ballVelocityFilterOrder = 2;
[z, p, k] = butter(ballVelocityFilterOrder, ballVelocityFilterThreshold / (RawData.an_fs / 2), 'low');
[sos, g] = zp2sos(z, p, k);
filteredBallVelocity = filtfilt(sos, g, trimmedBallVelocity);

resampledBallVelocity = resample(filteredBallVelocity, downSampled_Fs, RawData.an_fs);

% Binarize the ball velocity waveform
[ok] = GT_CheckForThreshold(['binarizedBallVelocity_' strDay], animalID, GT_AnalysisInfo);

if ok == 0
%     [ballVelocityThreshold] = GT_CreateBallVelocityThreshold(resampledBallVelocity, downSampled_Fs);
    ballVelocityThreshold = 1e-2;
    GT_AnalysisInfo.thresholds.(['binarizedBallVelocity_' strDay]) = ballVelocityThreshold;
end

binarizedBallVelocity = abs(diff(resampledBallVelocity, 1)) > GT_AnalysisInfo.thresholds.(['binarizedBallVelocity_' strDay]);
[linkedBinarizedVelocity] = GT_LinkBinaryEvents(gt(binarizedBallVelocity,0), [round(downSampled_Fs/3), 0]);

inds = linkedBinarizedVelocity == 0;
restVelocity = mean(resampledBallVelocity(inds));

SleepScoringData.ballVelocity = resampledBallVelocity - restVelocity;
SleepScoringData.binBallVelocity = binarizedBallVelocity;
SleepScoringData.CBV = RawData.barrels.CBVrefl_barrels;
SleepScoringData.HeartRate = RawData.HR;

%% Save the processed rawdata structure.
save([animalID '_' hem '_' fileID '_SleepScoringData.mat'] , 'SleepScoringData');

end

