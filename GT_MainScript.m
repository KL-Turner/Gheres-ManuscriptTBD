function [GT_AnalysisInfo] = GT_MainScript()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: [1] Analyze each RawData file to bandpass filter and downsample the various analog signals
%            [2] Categorize the animal's behavior using ball velocity.
%            [3] Categorize the animal's behavior using ball velocity.
%            [4] Determine resting baseline values using the animal's behavior flags.
%            [5] Run sleep scoring analysis functions.
%            [6] Create single trial summary figures if prompted.
%________________________________________________________________________________________________________________________
%
%   Inputs:
%
%   Outputs:
%
%   Last Revised: March 4th, 2019
%________________________________________________________________________________________________________________________

%% BLOCK PURPOSE: [0] Set parameters to be used for sleep scoring characterization
clear 
clc
rawDataDirectory = dir('*_RawData.mat');
rawDataFiles = char({rawDataDirectory.name}');
animalFile = rawDataFiles(1, :);
[animalID, ~, ~, ~] = GT_GetFileInfo(animalFile);

analysisInfo = dir('*_GT_AnalysisInfo.mat');
if ~isempty(analysisInfo)
    load(analysisInfo.name);
else
    GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData = false;
    GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData = false;
    GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData = false;
    GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData = false;
    GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData = false;
    GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData = false;
end

GT_multiWaitbar('CloseAll');
clear global buttonState
global buttonState
buttonState = 0;

% GUI for parameter settings
[updatedGUI] = GT_ScoringParameters;
while buttonState == 0
    drawnow()
    if buttonState == 1
        guiResults = guidata(updatedGUI);
        guiParams.awakeDuration = str2double(guiResults.awakeDuration.String);
        guiParams.minSleepTime = str2double(guiResults.minSleepTime.String);
        guiParams.neurToggle = guiResults.neurToggle.Value;
        guiParams.ballToggle = guiResults.ballToggle.Value;
        guiParams.hrToggle = guiResults.hrToggle.Value;
        guiParams.neurCrit = str2double(guiResults.neurCrit.String);
        guiParams.ballCrit = str2double(guiResults.ballCrit.String);
        guiParams.hrCrit = str2double(guiResults.hrCrit.String);
        guiParams.scoringID = guiResults.scoringID.String;
        guiParams.saveFigsToggle = guiResults.saveFigsToggle.Value;
        guiParams.saveStructToggle = guiResults.saveStructToggle.Value;
        guiParams.rerunBase = guiResults.rerunBase.Value;
        guiParams.rerunCatData = guiResults.rerunCatData.Value;
        guiParams.rerunProcData = guiResults.rerunProcData.Value;
        guiParams.rerunSpecData = guiResults.rerunSpecData.Value;
        closereq
        break;
    end
    ...
end

% Handle invalid inputs to GUI
[Error] = CheckGUIVals(guiParams);
if Error == true
    GT_MessageAlert('Invalid', guiParams)
    return;
end

% Progress Bars
GT_multiWaitbar('Processing RawData Files', 0, 'Color', [0.1 0.5 0.8]);
GT_multiWaitbar('Categorizing Behavioral Data', 0, 'Color', [1.0 0.4 0.0]);
GT_multiWaitbar('Creating Neural Spectrograms', 0, 'Color', [0.1 0.5 0.8]);
GT_multiWaitbar('Calculating Resting Baselines', 0, 'Color', [0.1 0.5 0.8]);
GT_multiWaitbar('Running Sleep Scoring Analysis', 0, 'Color', [0.1 0.5 0.8]);
if guiParams.saveFigsToggle == 1
    GT_multiWaitbar('Generating Single Trial Summary Figures', 0, 'Color', [0.1 0.5 0.8]);
end

%% BLOCK PURPOSE: [1] Analyze each RawData file to bandpass filter and downsample the various analog signals.
if ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_ProcessRawData') || GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData == false || guiParams.rerunProcData == true 
    for blockOneProg = 1:size(rawDataFiles, 1)
        rawDataFile = rawDataFiles(blockOneProg, :);
        [GT_AnalysisInfo] = GT_ProcessRawData(rawDataFile, GT_AnalysisInfo);
        GT_multiWaitbar('Processing RawData Files', blockOneProg/size(rawDataFiles, 1));
    end
    GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData = true;
    save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo');
else
    for blockOneProg = 1:size(rawDataFiles, 1)
        GT_multiWaitbar('Processing RawData Files', blockOneProg/size(rawDataFiles, 1));
        pause(0.05)
    end
end

%% BLOCK PURPOSE: [2] Categorize the animal's behavior using ball velocity.
if ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_CategorizeData') || GT_AnalysisInfo.analysisChecklist.GT_CategorizeData == false || guiParams.rerunCatData == true 
    for blockTwoProg = 1:size(rawDataFiles, 1)
        rawDataFile = rawDataFiles(blockTwoProg, :);
        [GT_AnalysisInfo] = GT_CategorizeData(rawDataFile, GT_AnalysisInfo);
        GT_multiWaitbar('Categorizing Behavioral Data', blockTwoProg/size(rawDataFiles, 1));
    end
    GT_AnalysisInfo.analysisChecklist.GT_CategorizeRawData = true;
    save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo');
else
    for blockTwoProg = 1:size(rawDataFiles, 1)
        GT_multiWaitbar('Categorizing Behavioral Data', blockTwoProg/size(rawDataFiles, 1));
        pause(0.05)
    end
end

% BLOCK PURPOSE: [3] Calculate the neural spectrogram for each file.
if GT_AnalysisInfo.analysisChecklist.GT_CategorizeData == false || ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_CategorizeData') || guiParams.redoCatData == true 
    for blockTwoProg = 1:size(rawDataFiles, 1)
        rawDataFile = rawDataFiles(blockTwoProg, :);
        [GT_AnalysisInfo] = GT_CategorizeData(rawDataFile, GT_AnalysisInfo);
        GT_multiWaitbar('Categorizing Behavioral Data', blockTwoProg/size(rawDataFiles, 1));
    end
    GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData = true;
    save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo');
end

%% BLOCK PURPOSE: [4] Determine resting baseline values using the animal's behavior flags.
% if GT_AnalysisInfo.analysisChecklist.GT_CategorizeData == false || ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_CategorizeData') || guiParams.redoCatData == true 
%     for blockTwoProg = 1:size(rawDataFiles, 1)
%         rawDataFile = rawDataFiles(blockTwoProg, :);
%         [GT_AnalysisInfo] = GT_CategorizeData(rawDataFile, GT_AnalysisInfo);
%         GT_multiWaitbar('Categorizing Behavioral Data', blockTwoProg/size(rawDataFiles, 1));
%     end
%     GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData = true;
%     save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo');
% end

%% BLOCK PURPOSE: [5] Run sleep scoring analysis functions.
% if GT_AnalysisInfo.analysisChecklist.GT_CategorizeData == false || ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_CategorizeData') || guiParams.redoCatData == true 
%     for blockTwoProg = 1:size(rawDataFiles, 1)
%         rawDataFile = rawDataFiles(blockTwoProg, :);
%         [GT_AnalysisInfo] = GT_CategorizeData(rawDataFile, GT_AnalysisInfo);
%         GT_multiWaitbar('Categorizing Behavioral Data', blockTwoProg/size(rawDataFiles, 1));
%     end
%     GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData = true;
%     save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo');
% end

%% BLOCK PURPOSE: [6] Create single trial summary figures if prompted.
% if GT_AnalysisInfo.analysisChecklist.GT_CategorizeData == false || ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_CategorizeData') || guiParams.redoCatData == true 
%     for blockTwoProg = 1:size(rawDataFiles, 1)
%         rawDataFile = rawDataFiles(blockTwoProg, :);
%         [GT_AnalysisInfo] = GT_CategorizeData(rawDataFile, GT_AnalysisInfo);
%         GT_multiWaitbar('Categorizing Behavioral Data', blockTwoProg/size(rawDataFiles, 1));
%     end
%     GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData = true;
%     save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo');
% end

% GT_MessageAlert('Complete')
GT_multiWaitbar('CloseAll');

end