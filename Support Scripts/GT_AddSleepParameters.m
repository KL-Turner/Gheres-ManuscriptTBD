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

Delta = SleepScoringData.normDeltaBandPower;
Theta = SleepScoringData.normThetaBandPower;
Gamma = SleepScoringData.normGammaBandPower;

% Smooth the signal with a 1 Hz low pass 4th-order butterworth filter
% Sampling Rate is 30 Hz for Delta, Theta, and Gamma signals
[B, A] = butter(4, 1 / (30 / 2), 'low');  
DeltaNeuro = filtfilt(B, A, Delta);
ThetaNeuro = filtfilt(B, A, Theta);
GammaNeuro = filtfilt(B, A, Gamma);

% Divide the neural signals into five second bins and put them in a cell array
tempDeltaStruct = cell(60, 1);
tempThetaStruct = cell(60, 1);
tempGammaStruct = cell(60, 1);

for neuralBins = 1:60   % loop through all 9000 samples across 5 minutes in 5 second bins (60 total)
    if neuralBins == 1
        tempDeltaStruct(neuralBins, 1) = {DeltaNeuro(neuralBins:150)};
        tempThetaStruct(neuralBins, 1) = {ThetaNeuro(neuralBins:150)};
        tempGammaStruct(neuralBins, 1) = {GammaNeuro(neuralBins:150)};
    elseif neuralBins == 60
        tempDeltaStruct(neuralBins, 1) = {DeltaNeuro((((150*(neuralBins - 1)) + 1)):end)};   % Samples 151 to 300, etc...
        tempThetaStruct(neuralBins, 1) = {ThetaNeuro((((150*(neuralBins - 1)) + 1)):end)};
        tempGammaStruct(neuralBins, 1) = {GammaNeuro((((150*(neuralBins - 1)) + 1)):end)};
    else
        tempDeltaStruct(neuralBins, 1) = {DeltaNeuro((((150*(neuralBins - 1)) + 1)):(150*neuralBins))};  % Samples 151 to 300, etc... 
        tempThetaStruct(neuralBins, 1) = {ThetaNeuro((((150*(neuralBins - 1)) + 1)):(150*neuralBins))};
        tempGammaStruct(neuralBins, 1) = {GammaNeuro((((150*(neuralBins - 1)) + 1)):(150*neuralBins))};    
    end
end

SleepScoringData.SleepParameters.deltaBandPower = tempDeltaStruct;
SleepScoringData.SleepParameters.thetaBandPower = tempThetaStruct;
SleepScoringData.SleepParameters.gammaBandPower = tempGammaStruct;


%% BLOCK PURPOSE: Chunk the ball velocity
ballVelocity = SleepScoringData.binBallVelocity;
Bin_width=5*SleepScoringData.downSampled_Fs; %Set up a five second duration bin for binning locomotion data 3-11-19 KWG
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
HeartRate = SleepScoringData.HeartRate;

% Divide the signal into five second bins and put them in a cell array
tempHRStruct = cell(60, 1); 

for HRBins = 1:60  
    if HRBins == 1
        tempHRStruct(HRBins, 1) = {HeartRate(HRBins:5)};
    elseif HRBins == 60
        tempHRStruct(HRBins, 1) = {HeartRate((((5*(HRBins - 1)) + 1)):end)};
    else
        tempHRStruct(HRBins, 1) = {HeartRate((((5*(HRBins - 1)) + 1)):(5*HRBins))}; 
    end
end

SleepScoringData.SleepParameters.HeartRate = tempHRStruct;

%% BLOCK PURPOSE: Chunk the  CBV data
CBV = SleepScoringData.normCBV;

[D, C] = butter(4, 1 / (30 / 2), 'low');  
FiltCBV = filtfilt(D, C, CBV);

tempCBVStruct = cell(60, 1);   % Pre-allocate cell array 

for CBVBins = 1:60  
    if CBVBins == 1
        tempCBVStruct(CBVBins, 1) = {FiltCBV(CBVBins:150)};
    else
        tempCBVStruct(CBVBins, 1) = {FiltCBV((((150*(CBVBins - 1)) + 1)):(150*CBVBins))};
    end
end

SleepScoringData.SleepParameters.CBV = tempCBVStruct; 

save(sleepScoringDataFile, 'SleepScoringData');

end
