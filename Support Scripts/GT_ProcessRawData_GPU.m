function [GT_AnalysisInfo] = GT_ProcessRawData_GPU(rawDataFile, GT_AnalysisInfo)
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
[~, tr, ~, HR] = GT_FindHeartRate_GPU(RawData.IOS.barrels.CBVrefl, RawData.dal_fr);
RawData.HR = HR;
RawData.HR_tr = tr;
%% Process the neural data into desired frequency bands.
% Delta [1-4 Hz]
[SleepScoringData.deltaBandPower, SleepScoringData.downSampled_Fs] = GT_ProcessNeuro(RawData, 'Delta', trialDuration_Seconds);
 
% Theta [4-10 Hz]
[SleepScoringData.thetaBandPower, ~] = GT_ProcessNeuro(RawData, 'BergelTheta', trialDuration_Seconds);

% Sleep Spindle [10-17 Hz]
[SleepScoringData.spindlePower, ~] = GT_ProcessNeuro(RawData, 'SullivanSpindle', trialDuration_Seconds);
 
% Gamma Band [40-95]
[SleepScoringData.gammaBandPower, ~] = GT_ProcessNeuro(RawData, 'Gam', trialDuration_Seconds);

% Hippocampal Ripple [95-200]
[SleepScoringData.ripplePower, ~] = GT_ProcessNeuro(RawData, 'SullivanRipple', trialDuration_Seconds);

%% Filter EMG Data in to multi unit frequency band
[SleepScoringData.EMG,~]=GT_ProcessNeuro(RawData,'EMGpower',trialDuration_Seconds);
GT_AnalysisInfo.thresholds.EMGData(GT_AnalysisInfo.thresholds.count,:)=SleepScoringData.EMG(1:expectedLength);

%% Get Reflectance data for each ROI
ROI_name=fieldnames(RawData.IOS);
for name_num=1:numel(ROI_name)
SleepScoringData.IOS.(ROI_name{name_num}).CBV=RawData.IOS.(ROI_name{name_num}).CBVrefl;
SleepScoringData.IOS.(ROI_name{name_num}).PixelMap=RawData.IOS(ROI_name{name_num}).PixelMap;
end

%% Save solenoid times (in seconds).
% Identify the solenoids by amplitude
SleepScoringData.Sol.solenoidContralateral = find(diff(RawData.Sol) == 1) / RawData.an_fs;
SleepScoringData.Sol.solenoidIpsilateral = find(diff(RawData.Sol) == 2) / RawData.an_fs;
SleepScoringData.Sol.solenoidTail = find(diff(RawData.Sol) == 3) / RawData.an_fs;
% Identify Opto laser stimulus times
SleepScoringData.Opto.OptoStim(1,:)=find(diff(round(RawData.LED,0))>0)/RawData.an_fs; %Laser ON times
SleepScoringData.Opto.OptoStim(2,:)=find(diff(round(RawData.LED,0))<0)/RawData.an_fs; %Laser OFF times
SleepScoringData.Opto.StimWindows=SleepScoringData.Opto.OptoStim(1,:);
for name_num=1:numel(ROI_name)
SleepScoringData.Opto.IOS.(ROI_name{name_num}).CBV=RawData.IOS.(ROI_name{name_num}).CBVrefl;
end
SleepScoringData.StimParams=RawData.AcquistionParams;
SleepScoringData.StimParams.an_fs=RawData.an_fs;
SleepScoringData.StimParams.dal_fr=RawData.dal_fr;
OptoStimWin=SleepScoringData.StimParams.Laser_Duration;

%% Remove laser pulse times keep just stim start times
if ~isempty(SleepScoringData.Opto.OptoStim)
Stim_On=SleepScoringData.Opto.OptoStim(1,1);
Stim_Off=Stim_On+OptoStimWin;
Stim_Count=length(SleepScoringData.Opto.StimWindows);

for name_num=1:numel(ROI_name)
    if strcmpi(ROI_name{name_num},'Pixelwise')==0
        if name_num==1
        flashframes=find(diff(SleepScoringData.Opto.IOS.(ROI_name{name_num}).CBV)>=50)+1;
        end
        SleepScoringData.Opto.IOS.(ROI_name{name_num}).CBV(flashframes)=NaN;
        SleepScoringData.Opto.IOS.(ROI_name{name_num}).CBV=fillmissing(SleepScoringData.Opto.IOS.(ROI_name{name_num}).CBV,'spline');
    else
        SleepScoringData.Opto.IOS.(ROI_name{name_num}).CBV(flashframes)=NaN;
        SleepScoringData.Opto.IOS.(ROI_name{name_num}).CBV=fillmissing(SleepScoringData.Opto.IOS.(ROI_name{name_num}).CBV,'spline',2);
    end
end
Counter=1;
while Counter<=Stim_Count
                Low_Bound=find(SleepScoringData.Opto.StimWindows>Stim_On);
                Upper_Bound=find(SleepScoringData.Opto.StimWindows<Stim_Off);
                The_Stim_Win=intersect(Low_Bound,Upper_Bound);
                SleepScoringData.Opto.StimWindows(The_Stim_Win)=[];
                if (Counter+1)<=numel(SleepScoringData.Opto.StimWindows)
                    Stim_On=SleepScoringData.Opto.StimWindows(Counter+1);
                    Stim_Off=Stim_On+OptoStimWin;
                end
                Stim_Count=numel(SleepScoringData.Opto.StimWindows);
                Counter=Counter+1;
end
else
    fprintf('No optogenetic stimulus this trial\n')
end

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
GT_AnalysisInfo.thresholds.BallData(GT_AnalysisInfo.thresholds.count,:)=filteredBallVelocity(1:expectedLength);
GT_AnalysisInfo.thresholds.count=GT_AnalysisInfo.thresholds.count+1;
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

SleepScoringData.ballVelocity =resampledBallVelocity; %resampledBallVelocity - restVelocity;
SleepScoringData.binBallVelocity = binarizedBallVelocity;
%SleepScoringData.LinkedBallVelocity=linkedBinarizedVelocity;
%SleepScoringData.CBV = RawData.IOS.barrels.CBVrefl;
SleepScoringData.HeartRate = RawData.HR;

% Save the processed new structure to the current directory.
save([animalID '_' hem '_' fileID '_SleepScoringData.mat'] , 'SleepScoringData');

end

