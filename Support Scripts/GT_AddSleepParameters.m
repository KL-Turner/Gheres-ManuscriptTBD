function GT_AddSleepParameters(sleepScoringDataFile)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner 
% Ph.D. Candidate, Department of Bioengineering 
% The Pennsylvania State University
%________________________________________________________________________________________________________________________
%
%   Purpose: This function serves to add the relevant sleep parameters to each ProcData file, the most notable being the
%            delta power that will be normalized by the current day's DeltaBandBaseline, which was obtained from the 
%            whisking events. The other parameters include the raw CBV from both hemispheres, the raw neural data from
%            both hemispheres (as well as the non-normalized Gamma band power), the Heart Rate, and whisker acceleration.
%________________________________________________________________________________________________________________________
%
%   Inputs: ProcData and RawData files from the same 5 minute imaging session. The RawData file contains the raw neural
%           data, while the ProcData file contains the Delta and Gamma bands, and the whisker position used to calculate
%           the acceleration. The raw CBV is in both files - either can be used. The Heart Rate is then calculated from 
%           the raw CBV.
%
%   Outputs: 5 second bins of each of the previously mentioned parameters that are either relevenat for sleep scoring, 
%            or for post-scoring analysis.
%________________________________________________________________________________________________________________________

%% BLOCK PURPOSE: Create folder for the Neural Data of each electrode
load(sleepScoringDataFile)

Delta = SleepScoringData.normDeltaBandPower;   % Right electrode Delta power signal
Theta = SleepScoringData.normTheteaBandPower;   % Right electrode Theta power signal
Gamma = SleepScoringData.normGammaBandPower;   % Right electrode Gamma power signal

% Smooth the signal with a 1 Hz low pass 4th-order butterworth filter
% Sampling Rate is 30 Hz for Delta, Theta, and Gamma signals
[B, A] = butter(4, 1 / (30 / 2), 'low');  
DeltaNeuro = filtfilt(B, A, Delta);   % Filtered right electrode Delta power signal
ThetaNeuro = filtfilt(B, A, Theta);   % Filtered right electrode Delta power signal
GammaNeuro = filtfilt(B, A, Gamma);   % Filtered right electrode Gamma power signal

% Divide the neural signals into five second bins and put them in a cell array
tempDeltaStruct = cell(60, 1);   % Pre-allocate cell array
tempThetaStruct = cell(60, 1);
tempGammaStruct = cell(60, 1);

for neuralBins = 1:60   % loop through all 9000 samples across 5 minutes in 5 second bins (60 total)
    if neuralBins == 1
        tempDeltaStruct(neuralBins, 1) = {DeltaNeuro(neuralBins:150)};
        tempThetaStruct(neuralBins, 1) = {ThetaNeuro(neuralBins:150)};
        tempGammaStruct(neuralBins, 1) = {GammaNeuro(neuralBins:150)};
    elseif neuralBins == 60
        tempDeltaStruct(neuralBins, 1) = {NormDelta((((150*(neuralBins - 1)) + 1)):end)};   % Samples 151 to 300, etc...
        tempThetaStruct(neuralBins, 1) = {ThetaNeuro((((150*(neuralBins - 1)) + 1)):end)};
        tempGammaStruct(neuralBins, 1) = {GammaNeuro((((150*(neuralBins - 1)) + 1)):end)};
    else
        tempDeltaStruct(neuralBins, 1) = {NormDelta((((150*(neuralBins - 1)) + 1)):(150*neuralBins))};  % Samples 151 to 300, etc... 
        tempThetaStruct(neuralBins, 1) = {ThetaNeuro((((150*(neuralBins - 1)) + 1)):(150*neuralBins))};
        tempGammaStruct(neuralBins, 1) = {GammaNeuro((((150*(neuralBins - 1)) + 1)):(150*neuralBins))};    
    end
end

SleepScoringData.SleepParameters.deltaBandPower = tempDeltaStruct;   % Place the data in the ProcData struct to later be saved
SleepScoringData.SleepParameters.thetaBandPower = tempThetaStruct;
SleepScoringData.SleepParameters.gammaBandPower = tempGammaStruct;


%% BLOCK PURPOSE: Create folder for the Whisker Acceleration
ballVelocity = SleepScoringData.binBallVelocity;     % Unfiltered whisker angle

% Find the number of whiskerBins due to frame drops.
ballBinNumber = ceil(length(whiskerAcceleration) / 150);

% Divide the signal into five second bins and put them in a cell array
tempBallStruct = cell(ballBinNumber, 1);   % Pre-allocate cell array

for ballBins = 1:ballBinNumber  % loop through all 9000 samples across 5 minutes in 5 second bins (60 total)
    if ballBins == 1
        tempBallStruct(whiskerBins, 1) = (ballVelocity(ballBins:150));  % Samples 1 to 150
    elseif ballBins == ballBinNumber
        tempBallStruct(whiskerBins, 1) = (ballVelocity((((150*(ballBins - 1)) + 1)):end));  % Samples 8701 to end. which changes due to dropped frames
    else
        tempBallStruct(whiskerBins, 1) = (ballVelocity((((150*(ballBins - 1)) + 1)):(150*ballBins)));  % Samples 151 to 300, etc...
    end
end
SleepScoringData.SleepParameters.ballVelocity = tempBallStruct;   % Place the data in the ProcData struct to later be saved

%% BLOCK PURPOSE: Create folder for the Heart Rate
% Find the heart rate from the current ProcData file
HeartRate = SleepScoringData.HR;

% Divide the signal into five second bins and put them in a cell array
tempHRStruct = cell(60, 1);   % Pre-allocate cell array

for HRBins = 1:60  % loop through all 297 samples across 5 minutes in 5 second bins (60 total)
    if HRBins == 1
        tempHRStruct(HRBins, 1) = {HeartRate(HRBins:5)};  % Samples 1 to 5
    elseif HRBins == 60
        tempHRStruct(HRBins, 1) = {HeartRate((((5*(HRBins - 1)) + 1)):end)};  % Samples 297 to end.
    else
        tempHRStruct(HRBins, 1) = {HeartRate((((5*(HRBins - 1)) + 1)):(5*HRBins))};  % Samples 6 to 10, etc...
    end
end

SleepScoringData.SleepParameters.HeartRate = tempHRStruct;   % Place the data in the ProcData struct to later be saved

%% BLOCK PURPOSE: Create folder for the left and right CBV data
CBV = SleepScoringData.normCBV;

[D, C] = butter(4, 1 / (30 / 2), 'low');  
FiltCBV = filtfilt(D, C, CBV);

tempCBVStruct = cell(60, 1);   % Pre-allocate cell array 

for CBVBins = 1:60   % loop through all 9000 samples across 5 minutes in 5 second bins (60 total)
    if CBVBins == 1
        tempCBVStruct(CBVBins, 1) = {FiltCBV(CBVBins:150)};  % Samples 1 to 150
    else
        tempCBVStruct(CBVBins, 1) = {FiltCBV((((150*(CBVBins - 1)) + 1)):(150*CBVBins))};  % Samples 151 to 300, etc...
    end
end

SleepScoringData.SleepParameters.CBV = tempCBVStruct;   % Place the data in the ProcData struct to later be saved

save(sleepScoringDataFile, 'SleepScoringData');

end
