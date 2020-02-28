function [binarized_whisking,whisking_times]=GT_FindWhiskerMovement(behaviorCamfile,SleepScoringData)
% Extremely low resolution whisker movement detection using Intrinisc Rig
% behavior cameras. 

%% Create Video Object of behavior Camera file
BehaviorCameraVideo=VideoReader(behaviorCamfile);

%% Generate empty variables and constants
BlackBox((1:95),(1:15))=0;
binarized_whisking(1:length(SleepScoringData.deltaBandPower))=0;
UpsampledWhisking(1:length(SleepScoringData.deltaBandPower))=0;
TrialDuration=length(SleepScoringData.deltaBandPower)/SleepScoringData.downSampled_Fs;
UpsampleTime=(1:length(SleepScoringData.deltaBandPower))/SleepScoringData.downSampled_Fs;
framenum=1;

%% Get Video frames and remove image clock
while hasFrame(BehaviorCameraVideo)
    tempFrame=readFrame(BehaviorCameraVideo);
    BehaviorMovie(:,:,framenum)=double(tempFrame);
    tempMov=BehaviorMovie(:,:,framenum);
    tempMov((103:117),(63:157))=BlackBox';
    BlankMov(:,:,framenum)=tempMov;
    framenum=framenum+1;
end

%% Define where in frame to search for movement
figure;imagesc(BehaviorMovie(:,:,25));
ROIVals=roipoly;

%% Find movement in ROI Binarize based on user defined threshold ~2 standard deviations
MovementMov=diff(BlankMov,1,3);

for framenum=1:size(MovementMov,3)
    ROIMov(:,:,framenum)=MovementMov(:,:,framenum).*ROIVals;
end

MoveScore=squeeze(sum(sum(ROIMov,1),2));
MoveThresh=2*std(MoveScore);
Rough_binarized_whisking=MoveScore>MoveThresh;
CameraFs=size(BehaviorMovie,3)/TrialDuration;
whisking_times=find(Rough_binarized_whisking==1)/(size(BehaviorMovie,3)/TrialDuration);

%% Convert whisking times to same length as other binarized data and CBV measurements
for k=1:length(whisking_times)
 theInds=find(UpsampleTime>(whisking_times(k)-(1/CameraFs)) & UpsampleTime<(whisking_times(k)+(1/CameraFs)));
 if min(theInds)>0 && max(theInds)<length(UpsampledWhisking)
 UpsampledWhisking(theInds)=1;
 end
end

%% Find times where animal is only whisking with no ball velocity
WhiskTimes=find(UpsampledWhisking==1);
RunTimes=find(SleepScoringData.ballVelocity==1);
StillWhisking=setdiff(WhiskTimes,RunTimes);
binarized_whisking(StillWhisking)=1;
end




    