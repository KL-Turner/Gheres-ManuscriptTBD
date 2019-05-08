function GT_AddSleepParameters(sleepScoringDataFile)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: This function serves to add the relevant sleep parameters to each SleepScoringData file, the most notable being
%            the delta and theta power that will be normalized by the current day's baseline, which was obtained from the 
%            resting events. The other parameters include the raw CBV, the Heart Rate, and the ball velocity.
%________________________________________________________________________________________________________________________
%
%   Inputs: sleepScoringDataFile (string) ID of file whose parameters are to be chunked into 5 second bins.
%
%   Outputs: None - saves the SleepScoringData.mat struct to the current directory.
%________________________________________________________________________________________________________________________

%% BLOCK PURPOSE: Chunk the neural data from the electrode
load(sleepScoringDataFile)

WindowTime=1;%time in seconds for binning sleep scoring criteria
WindowSamples=round((length(SleepScoringData.normDeltaBandPower)/SleepScoringData.StimParams.dal_fr)/...
    WindowTime,0); %Number of non overlapping windows to cover the data set
SamplesInWindow=WindowTime*SleepScoringData.StimParams.dal_fr; %number of samples in each window

Delta = SleepScoringData.normDeltaBandPower;
Theta = SleepScoringData.normThetaBandPower;
Spindle=SleepScoringData.normSpindlePower;
Gamma = SleepScoringData.normGammaBandPower;
Ripple=SleepScoringData.normRipplePower;

% Smooth the signal with a 2 Hz low pass 4th-order butterworth filter
% Sampling Rate is 30 Hz for Delta, Theta, and Gamma signals
[B, A] = butter(4, 2 / (30 / 2), 'low');  
DeltaNeuro = filtfilt(B, A, Delta);
ThetaNeuro = filtfilt(B, A, Theta);
SpindleNeuro=filtfilt(B,A,Spindle);
GammaNeuro = filtfilt(B, A, Gamma);
RippleNeuro=filtfilt(B,A,Ripple);

% Divide the neural signals into five second bins and put them in a cell array
tempDeltaStruct = cell(WindowSamples, 1);
tempThetaStruct = cell(WindowSamples, 1);
tempSpindleStruct=cell(WindowSamples,1);
tempGammaStruct = cell(WindowSamples, 1);
tempRippleStruct = cell(WindowSamples, 1);

for neuralBins = 1:WindowSamples   % loop through all 9000 samples across 5 minutes in 5 second bins (60 total)
    if neuralBins == 1
        tempDeltaStruct(neuralBins, 1) = {DeltaNeuro(neuralBins:SamplesInWindow)};
        tempThetaStruct(neuralBins, 1) = {ThetaNeuro(neuralBins:SamplesInWindow)};
        tempSpindleStruct(neuralBins, 1) = {SpindleNeuro(neuralBins:SamplesInWindow)};
        tempGammaStruct(neuralBins, 1) = {GammaNeuro(neuralBins:SamplesInWindow)};
        tempRippleStruct(neuralBins, 1) = {RippleNeuro(neuralBins:SamplesInWindow)};
    elseif neuralBins == WindowSamples
        tempDeltaStruct(neuralBins, 1) = {DeltaNeuro((((SamplesInWindow*(neuralBins - 1)) + 1)):end)};   % Samples 151 to 300, etc...
        tempThetaStruct(neuralBins, 1) = {ThetaNeuro((((SamplesInWindow*(neuralBins - 1)) + 1)):end)};
        tempSpindleStruct(neuralBins, 1) = {SpindleNeuro((((SamplesInWindow*(neuralBins-1))+1)):end)};
        tempGammaStruct(neuralBins, 1) = {GammaNeuro((((SamplesInWindow*(neuralBins - 1)) + 1)):end)};
        tempRippleStruct(neuralBins, 1) = {RippleNeuro((((SamplesInWindow*(neuralBins - 1)) + 1)):end)};
    else
        tempDeltaStruct(neuralBins, 1) = {DeltaNeuro((((SamplesInWindow*(neuralBins - 1)) + 1)):(SamplesInWindow*neuralBins))};  % Samples 151 to 300, etc... 
        tempThetaStruct(neuralBins, 1) = {ThetaNeuro((((SamplesInWindow*(neuralBins - 1)) + 1)):(SamplesInWindow*neuralBins))};
        tempSpindleStruct(neuralBins, 1) = {SpindleNeuro((((SamplesInWindow*(neuralBins-1))+1)):(SamplesInWindow*neuralBins))};
        tempGammaStruct(neuralBins, 1) = {GammaNeuro((((SamplesInWindow*(neuralBins - 1)) + 1)):(SamplesInWindow*neuralBins))};
        tempRippleStruct(neuralBins, 1) = {RippleNeuro((((SamplesInWindow*(neuralBins - 1)) + 1)):(SamplesInWindow*neuralBins))};
    end
end

SleepScoringData.SleepParameters.deltaBandPower = tempDeltaStruct;
SleepScoringData.SleepParameters.thetaBandPower = tempThetaStruct;
SleepScoringData.SleepParameters.spindlePower=tempSpindleStruct;
SleepScoringData.SleepParameters.gammaBandPower = tempGammaStruct;
SleepScoringData.SleepParameters.ripplePower = tempRippleStruct;

%% BLOCK PURPOSE: Chunk the ball velocity
ballVelocity = SleepScoringData.binBallVelocity;
Bin_width=WindowTime*SleepScoringData.downSampled_Fs; %Set up a five second duration bin for binning locomotion data 3-11-19 KWG
% Find the number of ball bins.
ballBinNumber = ceil(length(ballVelocity) / Bin_width);
%ballBinNumber=floor(length(ballVelocity)/30);
% Divide the signal into five second bins and put them in a cell array
tempBallStruct = cell(ballBinNumber, 1);

for ballBins = 1:ballBinNumber  
    if ballBins == 1
        tempBallStruct(ballBins, 1) = {(ballVelocity(ballBins:Bin_width))}; 
    elseif ballBins == ballBinNumber
        tempBallStruct(ballBins, 1) = {(ballVelocity((((Bin_width*(ballBins - 1)) + 1)):end))};
    else
        tempBallStruct(ballBins, 1) = {(ballVelocity((((Bin_width*(ballBins - 1)) + 1)):(Bin_width*ballBins)))};
    end
end
SleepScoringData.SleepParameters.ballVelocity = tempBallStruct;

%% BLOCK PURPOSE: Chunk the Heart Rate into five second bins
% Find the heart rate from the current ProcData file
% HeartRate = SleepScoringData.HeartRate;
% 
% % Divide the signal into five second bins and put them in a cell array
% tempHRStruct = cell(WindowSamples, 1); 
% 
% for HRBins = 1:WindowSamples  
%     if HRBins == 1
%         tempHRStruct(HRBins, 1) = {HeartRate(HRBins:WindowTime)};
%     elseif HRBins == WindowSamples
%         tempHRStruct(HRBins, 1) = {HeartRate((((WindowTime*(HRBins - 1)) + 1)):end)};
%     else
%         tempHRStruct(HRBins, 1) = {HeartRate((((WindowTime*(HRBins - 1)) + 1)):(WindowTime*HRBins))}; 
%     end
% end
% 
% SleepScoringData.SleepParameters.HeartRate = tempHRStruct;

%% BLOCK PURPOSE: Chunk the Binarized EMG data
TheAtonia=double(SleepScoringData.Flags.Atonia);

tempEMGStruct=cell(WindowSamples,1);

for EMGBins=1:WindowSamples
    if EMGBins==1
        tempEMGStruct(EMGBins,1)={TheAtonia(EMGBins:Bin_width)};
    elseif EMGBins==WindowSamples
        tempEMGStruct(EMGBins,1)={TheAtonia((((Bin_width*(EMGBins-1))+1)):end)};
    else
        tempEMGStruct(EMGBins,1)={TheAtonia((((Bin_width*(EMGBins-1))+1)):(Bin_width*EMGBins))};
    end
end
SleepScoringData.SleepParameters.EMG=tempEMGStruct;

%% BLOCK PURPOSE: Chunk the  CBV data
CBV = SleepScoringData.normCBV;

[D, C] = butter(4, 1 / (30 / 2), 'low');  
FiltCBV = filtfilt(D, C, CBV);

tempCBVStruct = cell(WindowSamples, 1);   % Pre-allocate cell array 

for CBVBins = 1:WindowSamples  
    if CBVBins == 1
        tempCBVStruct(CBVBins, 1) = {FiltCBV(CBVBins:SamplesInWindow)};
    else
        tempCBVStruct(CBVBins, 1) = {FiltCBV((((SamplesInWindow*(CBVBins - 1)) + 1)):(SamplesInWindow*CBVBins))};
    end
end

SleepScoringData.SleepParameters.CBV = tempCBVStruct; 

save(sleepScoringDataFile, 'SleepScoringData');

end
