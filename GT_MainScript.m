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

%% BLOCK PURPOSE: [0] Analyze vessel diameter and add it to MScanData.mat
clear
clc

disp('Analyzing Block [2] Analyzing vessel diameter.'); disp(' ')
rawDataDirectory = dir('*_MScanData.mat');
rawDataFiles = char({rawDataDirectory.name}');
analysisInfo = dir('*_GT_AnalysisInfo.mat');
if ~isempty(analysisInfo)
    load(analysisInfo.name);
else
    GT_AnalysisInfo = [];
end

multiWaitbar('CloseAll')
clear global buttonState
global buttonState
buttonState = 0;

clear global blockOneProg
global blockOneProg
blockOneProg = 0;

clear global blockTwoProg
global blockTwoProg
blockTwoProg = 0;

clear global blockThreeProg
global blockThreeProg
blockThreeProg = 0;

clear global blockFourProg
global blockFourProg
blockFourProg = 0;

clear global blockFiveProg
global blockFiveProg
blockFiveProg = 0;

clear global blockSixProg
global blockSixProg
blockSixProg = 0;

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
        closereq
        break;
    end
    ...
end

multiWaitbar('Processing RawData files', 0, 'Color', [0.1 0.5 0.8]);
for blockOneProg = 1:size(rawDataFiles, 1)
    multiWaitbar('Processing RawData files', blockOneProg/size(rawDataFiles, 1));
end

multiWaitbar('Categorizing Behavioral Data', 0, 'Color', [0.1 0.5 0.8]);

for blockTwoProg = 1:size(rawDataFiles, 1)
    multiWaitbar('Categorizing Behavioral Data', blockTwoProg/size(rawDataFiles, 1));
end

multiWaitbar('Creating Neural Spectrograms', 0, 'Color', [0.1 0.5 0.8]);
for blockThreeProg = 1:size(rawDataFiles, 1)
    multiWaitbar('Creating Neural Spectrograms', blockThreeProg/size(rawDataFiles, 1));
end

multiWaitbar('Calculating Resting Baselines', 0, 'Color', [0.1 0.5 0.8]);
for blockFourProg = 1:size(rawDataFiles, 1)
    multiWaitbar('Calculating Resting Baselines', blockFourProg/size(rawDataFiles, 1));
end

multiWaitbar('Running Sleep Scoring Analysis', 0, 'Color', [0.1 0.5 0.8]);
for blockFiveProg = 1:size(rawDataFiles, 1)
    multiWaitbar('Running Sleep Scoring Analysis', blockFiveProg/size(rawDataFiles, 1));
end

if saveFigsToggle == 1
    multiWaitbar('Generating Single Trial Summary Figures', 0, 'Color', [0.1 0.5 0.8]);
    for blockSixProg = 1:size(rawDataFiles, 1)
        multiWaitbar('Generating Single Trial Summary Figures', blockSixProg/size(rawDataFiles, 1));
    end
end

%% BLOCK PURPOSE: [1] Analyze vessel diameter and add it to MScanData.mat

% [GT_AnalysisInfo] = GT_ProcessRawData(rawDataFiles, GT_AnalysisInfo);
% 
%% BLOCK PURPOSE: [2] Analyze vessel diameter and add it to MScanData.mat
% [GT_AnalysisInfo] = GT_CategorizeData(rawDataFiles, GT_AnalysisInfo);

%% BLOCK PURPOSE: [0] Analyze vessel diameter and add it to MScanData.mat

%% BLOCK PURPOSE: [0] Analyze vessel diameter and add it to MScanData.mat

%% BLOCK PURPOSE: [0] Analyze vessel diameter and add it to MScanData.mat

%% BLOCK PURPOSE: [0] Analyze vessel diameter and add it to MScanData.mat


MessageAlert('Complete')
multiWaitbar('CloseAll')

    