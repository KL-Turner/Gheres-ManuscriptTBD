function [GT_AnalysisInfo] = GT_ProcessRawData(rawDataFile, GT_AnalysisInfo)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Appropriately resample and filter the various analog signals.
%________________________________________________________________________________________________________________________
%
%   Inputs:
%
%   Outputs:
%
%   Last Revised:
%________________________________________________________________________________________________________________________

% Load the RawData.mat file from the current directory. Identify the file info.
load(rawDataFile)
[animalID, hem, fileDate, fileID] = GT_GetFileInfo(rawDataFile);
strDay = GT_ConvertDate(fileDate);
trialDuration_Seconds = 300;
expectedLength = trialDuration_Seconds*RawData.an_fs;
[~, tr, ~, HR] = GT_FindHeartRate(RawData.barrels.CBVrefl_barrels, RawData.dal_fr);
RawData.HR = HR;
RawData.HR_tr = tr;
%% Process the neural data into desired frequency bands.
% Delta [1-4 Hz]
[SleepScoringData.deltaBandPower, SleepScoringData.downSampled_Fs] = GT_ProcessNeuro(RawData, 'Delta', trialDuration_Seconds);
 
% Theta [4-8 Hz]
[SleepScoringData.thetaBandPower, ~] = GT_ProcessNeuro(RawData, 'Theta', trialDuration_Seconds);
 
% Gamma Band [40-100]
[SleepScoringData.gammaBandPower, ~] = GT_ProcessNeuro(RawData, 'Gam', trialDuration_Seconds);

%% Save solenoid times (in seconds).
% Identify the solenoids by amplitude
SleepScoringData.Sol.solenoidContralateral = find(diff(RawData.Sol) == 1) / RawData.an_fs;
SleepScoringData.Sol.solenoidIpsilateral = find(diff(RawData.Sol) == 2) / RawData.an_fs;
SleepScoringData.Sol.solenoidTail = find(diff(RawData.Sol) == 3) / RawData.an_fs;

%% Downsample and binarize the ball velocity.
% Trim any additional data points for resample.
trimmedBallVelocity = RawData.vBall(1:min(expectedLength, length(RawData.vBall)));

% Filter then downsample the ball velocity waveform to desired frequency.
downSampled_Fs = RawData.dal_fr;   % Downsample to CBV Camera Fs.
ballVelocityFilterThreshold = 20;
ballVelocityFilterOrder = 2;
[z, p, k] = butter(ballVelocityFilterOrder, ballVelocityFilterThreshold / (RawData.an_fs / 2), 'low');
[sos, g] = zp2sos(z, p, k);
filteredBallVelocity = filtfilt(sos, g, trimmedBallVelocity);
resampledBallVelocity = resample(filteredBallVelocity, downSampled_Fs, RawData.an_fs);

% Check for this day's threshold value to binarize the ball velocity.
[ok] = GT_CheckForThreshold(['binarizedBallVelocity_' strDay], GT_AnalysisInfo);

if ok == 0
    % If this day doesn't have a previously defined threshold, prompt the user to create one.
    [ballVelocityThreshold] = GT_CreateBallVelocityThreshold(resampledBallVelocity, downSampled_Fs);
    GT_AnalysisInfo.thresholds.(['binarizedBallVelocity_' strDay]) = ballVelocityThreshold;
end

restLink = round(downSampled_Fs);   % Flags animal active if rest period is < this duration.
runLink = round(downSampled_Fs/3);   % Flads animal at rest if active period is < this duration.
binarizedBallVelocity = abs(diff(resampledBallVelocity, 1)) > GT_AnalysisInfo.thresholds.(['binarizedBallVelocity_' strDay]);
[linkedBinarizedVelocity] = GT_LinkBinaryEvents(gt(binarizedBallVelocity,0), [restLink, runLink]);

inds = linkedBinarizedVelocity == 0;
restVelocity = mean(resampledBallVelocity(inds));

SleepScoringData.ballVelocity = resampledBallVelocity - restVelocity;
SleepScoringData.binBallVelocity = binarizedBallVelocity;
%SleepScoringData.LinkedBallVelocity=linkedBinarizedVelocity;
SleepScoringData.CBV = RawData.barrels.CBVrefl_barrels;
SleepScoringData.HeartRate = RawData.HR;

% Save the processed new structure to the current directory.
save([animalID '_' hem '_' fileID '_SleepScoringData.mat'] , 'SleepScoringData');

end

