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

%% BLOCK PURPOSE: [2] Analyze vessel diameter and add it to MScanData.mat
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

global buttonState 
buttonState = 0;

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

[GT_AnalysisInfo] = GT_ProcessRawData(rawDataFiles, GT_AnalysisInfo);

[GT_AnalysisInfo] = GT_CategorizeData(rawDataFiles, GT_AnalysisInfo);



    