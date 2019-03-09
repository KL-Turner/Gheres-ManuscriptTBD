function [GT_AnalysisInfo] = GT_AddSleepLogicals(sleepScoringDataFile, GT_AnalysisInfo, guiParams, iteration)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: This function uses the sleep parameter bins (delta,theta power, ball velocity, and heart rate) to classify
%            each 5 second bin as either sleeping (1) or not (0). The Delta power is classified as a one if the max point
%            in a bin is greater than a defined input. The signal osccialates, so we take the peak anywhere in
%            the five seconds. The ball velocity is classified as a one if the number of binarizations in a bin is
%            less than a defined input. The heart rate is classified as a one if the max is less than a defined number of
%            beats per second. Certain logicals binary events are linked with 1 or 2 negative events inbetween.
%            These three logicals are then multiplied together to give a total "sleep logical."
%________________________________________________________________________________________________________________________
%
%   Inputs: sleepScoringDataFile (string) with the data
%           GT_AnalysisInfo.mat (struct) summary of sleep scoring results.
%           guiParams.mat (struc) with GUI parameters.
%           interation (double) that denotes the iteration of the loop. 
%
%   Outputs: Save logicals to the GT_AnalysisInfo.mat struct.
%________________________________________________________________________________________________________________________

load(sleepScoringDataFile)
[~,~,~, fileID] = GT_GetFileInfo(sleepScoringDataFile);

%% BLOCK PURPOSE:  Create logicals to compare sleep parameters
% Create logical for the delta band power
for bins = 1:length(SleepScoringData.SleepParameters.deltaBandPower)
    if max(SleepScoringData.SleepParameters.deltaBandPower{bins}) >= guiParams.neurCrit
        deltaElectrodeLogical(bins, 1) = 1;
    else
        deltaElectrodeLogical(bins, 1) = 0;
    end
end

% Create logical for the theta band power
for bins = 1:length(SleepScoringData.SleepParameters.thetaBandPower)
    if max(SleepScoringData.SleepParameters.thetaBandPower{bins}) >= guiParams.neurCrit
        thetaElectrodeLogical(bins, 1) = 1;
    else
        thetaElectrodeLogical(bins, 1) = 0;
    end
end

% cell function the logicals together and link binary events.
electrodeLogical1 = arrayfun(@(deltaElectrodeLogical, thetaElectrodeLogical) any(deltaElectrodeLogical + thetaElectrodeLogical), deltaElectrodeLogical, thetaElectrodeLogical);
[electrodeLogical] = GT_LinkBinaryEvents(gt(electrodeLogical1, 0), [3, 0]);

GT_AnalysisInfo.(guiParams.scoringID).FileIDs{iteration, 1} = fileID;
GT_AnalysisInfo.(guiParams.scoringID).Logicals.electrodeLogical{iteration, 1} = electrodeLogical;

%% BLOCK PURPOSE: Create logical for the ball velocity
for bins = 1:length(SleepScoringData.SleepParameters.ballVelocity)
    if sum(SleepScoringData.SleepParameters.ballVelocity{bins}) <= guiParams.ballCrit 
        ballLogical(bins, 1) = 1;
    else
        ballLogical(bins, 1) = 0;
    end
end

GT_AnalysisInfo.(guiParams.scoringID).Logicals.ballLogical{iteration, 1} = ballLogical;

%% BLOCK PURPOSE: Create logical for the heart rate
for bins = 1:length(SleepScoringData.SleepParameters.HeartRate) 
    if max(SleepScoringData.SleepParameters.HeartRate{bins}) <= guiParams.hrCrit
        heartRateLogical(bins, 1) = 1; 
    else
        heartRateLogical(bins, 1) = 0; 
    end
end

GT_AnalysisInfo.(guiParams.scoringID).Logicals.heartRateLogical{iteration, 1} = heartRateLogical;

%% BLOCK PURPOSE: Create combined logical for potentially sleeping epochs
% TEMP - user-defined GUI for which logicals to use is in progress
% Toggles{1,1} = guiParams.neurToggle;
% Toggles{2,1} = guiParams.ballToggle;
% Toggles{3,1} = guiParams.hrToggle;
% logicals = vertcat(electrodeLogical, ballLogical, heartRateLogical);
% 
% a = 1;
% for t = 1:length(Toggles)
%     if Toggles{t, 1} == true
%         sLogical(t, :) = logicals(t, :);
%     else
%         sLogicals(t, :) = zeros(length(logicals(t, :)), 1);
%     end
% end

sleepLogical1 = electrodeLogical.*ballLogical.*heartRateLogical;
[sleepLogical] = GT_LinkBinaryEvents(gt(sleepLogical1', 0), [2, 0]);
GT_AnalysisInfo.(guiParams.scoringID).Logicals.sleepLogical{iteration,1} = sleepLogical';

end 
