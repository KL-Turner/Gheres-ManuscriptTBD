function [GT_AnalysisInfo] = GT_AddSleepLogicals(sleepScoringDataFile, GT_AnalysisInfo, guiParams, iteration)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% Ph.D. Candidate, Department of Bioengineering
% The Pennsylvania State University
%________________________________________________________________________________________________________________________
%
%   Purpose: This function uses the sleep parameter bins (Delta power, whisker acceleration, and heart rate) to classify
%            each 5 second bin as either sleeping (1) or not (0). The Delta power is classified as a one if the max point
%            in a bin is greater than 5 (500% whisking baseline). The signal osccialates, so we take the peak anywhere in
%            the five seconds. The whisker acceleration is classified as a one if the max whisker acceleration in a bin is
%            less than 5 degrees/sec^2. The heart rate is classified as a one if the max is less than 9 beats per second.
%            These three logicals are then multiplied together to give a total "sleep logical."
%________________________________________________________________________________________________________________________
%
%   Inputs: ProcData file from a 5 minute imaging session.
%
%   Outputs: Save logicals to the ProcData file.
%________________________________________________________________________________________________________________________

load(sleepScoringDataFile)
[~,~,~, fileID] = GT_GetFileInfo(sleepScoringDataFile);

%% BLOCK PURPOSE:  Create logicals to compare sleep parameters
% Create logical for the left and right electrode
for bins = 1:length(SleepScoringData.SleepParameters.deltaBandPower)    % Loop through the total number of bins
    if max(SleepScoringData.SleepParameters.deltaBandPower{bins}) >= guiParams.neurCrit   % If the max Power in the 5 second interval
        deltaElectrodeLogical(bins, 1) = 1; %#ok<*SAGROW>          % is >= 5, put a 1
    else
        deltaElectrodeLogical(bins, 1) = 0;                        % else, put a 0
    end
end

for bins = 1:length(SleepScoringData.SleepParameters.thetaBandPower)   % Loop through the total number of bins
    if max(SleepScoringData.SleepParameters.thetaBandPower{bins}) >= guiParams.neurCrit   % If the max Power in the 5 second interval
        thetaElectrodeLogical(bins, 1) = 1; %#ok<*SAGROW>          % is >= 5, put a 1
    else
        thetaElectrodeLogical(bins, 1) = 0;                        % else, put a 0
    end
end

electrodeLogical = arrayfun(@(deltaElectrodeLogical, thetaElectrodeLogical) any(deltaElectrodeLogical + thetaElectrodeLogical), deltaElectrodeLogical, thetaElectrodeLogical);

GT_AnalysisInfo.(guiParams.scoringID).FileIDs{iteration, 1} = fileID;
GT_AnalysisInfo.(guiParams.scoringID).Logicals.electrodeLogical{iteration, 1} = electrodeLogical;   % Place the data in the ProcData struct to later be saved

%% BLOCK PURPOSE: Create logical for the whisker angle acceleration
for bins = 1:length(SleepScoringData.SleepParameters.ballVelocity)  % Loop through the total number of bins
    if sum(SleepScoringData.SleepParameters.ballVelocity{bins}) <= guiParams.ballCrit  % If the max whisker acceleration in the 5 second interval
        ballLogical(bins, 1) = 1; %#ok<*SAGROW>              % is <= 5 degrees/sec sq, put a 1
    else
        ballLogical(bins, 1) = 0;                            % else, put a 0
    end
end

GT_AnalysisInfo.(guiParams.scoringID).Logicals.ballLogical{iteration, 1} = ballLogical;   % Place the data in the ProcData struct to later be saved

%% BLOCK PURPOSE: Create logical for the heart rate
for bins = 1:length(SleepScoringData.SleepParameters.HeartRate)         % Loop through the total number of bins
    if max(SleepScoringData.SleepParameters.HeartRate{bins}) <= guiParams.hrCrit       % If the max whisker acceleration in the 5 second interval
        heartRateLogical(bins, 1) = 1; %#ok<*SAGROW>             % is <= 5 degrees/sec sq, put a 1
    else
        heartRateLogical(bins, 1) = 0;                           % else, put a 0
    end
end

GT_AnalysisInfo.(guiParams.scoringID).Logicals.heartRateLogical{iteration, 1} = heartRateLogical;   % Place the data in the ProcData struct to later be saved

%% BLOCK PURPOSE: Create combined logical for potentially sleeping epochs
% Toggles{1,1} = guiParams.neurToggle;
% Toggles{2,1} = guiParams.ballToggle;
% Toggles{3,1} = guiParams.hrToggle;
% logicals = vertcat(electrodeLogical, ballLogical, heartRateLogical);
% 
% a = 1;
% for t = 1:length(Toggles)
%     if Toggles{t, 1} == true
%         sLogical(a, :) = logicals(t, :);
%         a = a + 1;
%     end
% end

sleepLogical = electrodeLogical.*ballLogical.*heartRateLogical;
GT_AnalysisInfo.(guiParams.scoringID).Logicals.sleepLogical{iteration,1} = sleepLogical;

end 
