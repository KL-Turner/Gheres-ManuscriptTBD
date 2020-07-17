function [] = MainScript_GheresTBD()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
% Purpose: Generates KLT's main and supplemental figs for the 2020 sleep paper.
%
% Scripts used to pre-process the original data are located in the folder "Pre-processing-scripts".
% Functions that are used in both the analysis and pre-processing are located in the analysis folder.
%________________________________________________________________________________________________________________________

clear; clc; close all;
%% make sure the code repository and data are present in the current directory.
currentFolder = pwd;
addpath(genpath(currentFolder));
fileparts = strsplit(currentFolder,filesep);
if ismac
    rootFolder = fullfile(filesep,fileparts{1:end});
else
    rootFolder = fullfile(fileparts{1:end});
end
% add root folder to Matlab's working directory.
addpath(genpath(rootFolder))
%% run the data analysis. The progress bars will show the analysis progress.
rerunAnalysis = 'n';
if exist('AnalysisResults.mat') ~= 2 || strcmp(rerunAnalysis,'y') == true
    multiWaitbar_Manuscript2020('Analyzing sleep probability',0,'Color','B'); pause(0.25);
    multiWaitbar_Manuscript2020('Analyzing behavioral distributions',0,'Color','W'); pause(0.25);
    multiWaitbar_Manuscript2020('Analyzing behavioral heart rate' ,0,'Color','B'); pause(0.25);
    multiWaitbar_Manuscript2020('Analyzing behavioral transitions',0,'Color','W'); pause(0.25);
    multiWaitbar_Manuscript2020('Analyzing vessel behavioral transitions',0,'Color','B'); pause(0.25);
    multiWaitbar_Manuscript2020('Analyzing behavioral hemodynamics',0,'Color','W'); pause(0.25);
    multiWaitbar_Manuscript2020('Analyzing behavioral vessel diameter',0,'Color','B'); pause(0.25);
    multiWaitbar_Manuscript2020('Analyzing laser doppler flow',0,'Color','W'); pause(0.25);
    multiWaitbar_Manuscript2020('Analyzing coherence',0,'Color','B'); pause(0.25);
    multiWaitbar_Manuscript2020('Analyzing neural-hemo coherence',0,'Color','W'); pause(0.25);
    multiWaitbar_Manuscript2020('Analyzing power spectra',0,'Color','B'); pause(0.25);
    multiWaitbar_Manuscript2020('Analyzing vessel power spectra',0,'Color','W'); pause(0.25);
    multiWaitbar_Manuscript2020('Analyzing Pearson''s correlation coefficients',0,'Color','B'); pause(0.25);
    multiWaitbar_Manuscript2020('Analyzing cross correlation',0,'Color','W'); pause(0.25);
    multiWaitbar_Manuscript2020('Analyzing model cross validation distribution',0,'Color','B'); pause(0.25);
    multiWaitbar_Manuscript2020('Analyzing evoked responses',0,'Color','W'); pause(0.25);
    multiWaitbar_Manuscript2020('Analyzing vessel evoked responses',0,'Color','B'); pause(0.25);
    multiWaitbar_Manuscript2020('Analyzing CBV-Gamma relationship',0,'Color','W'); pause(0.25);
    multiWaitbar_Manuscript2020('Analyzing HbT-Sleep probability',0,'Color','B'); pause(0.25);
    multiWaitbar_Manuscript2020('Analyzing TwoP-Sleep probability',0,'Color','W'); pause(0.25);
    multiWaitbar_Manuscript2020('Analyzing arteriole durations',0,'Color','B'); pause(0.25);
    % run analysis and output a structure containing all the analyzed data.
    [AnalysisResults] = AnalyzeData_Manuscript2020(rootFolder);
    multiWaitbar_Manuscript2020('CloseAll');
else
    disp('Loading analysis results and generating figures...'); disp(' ')
    load('AnalysisResults.mat')
end
saveFigs = 'y';
%% supplemental figure panels
[AnalysisResults] = FigS22_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
[AnalysisResults] = FigS21_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
[AnalysisResults] = FigS20_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
[AnalysisResults] = FigS19_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
[AnalysisResults] = FigS18_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
[AnalysisResults] = FigS17_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
[AnalysisResults] = FigS16_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
[AnalysisResults] = FigS15_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
[AnalysisResults] = FigS14_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
[AnalysisResults] = FigS13_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
[AnalysisResults] = FigS12_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
[AnalysisResults] = FigS11_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
[AnalysisResults] = FigS10_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
[AnalysisResults] = FigS9_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
[AnalysisResults] = FigS8_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
[AnalysisResults] = FigS7_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
[AnalysisResults] = FigS6_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
[AnalysisResults] = FigS5_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
[AnalysisResults] = FigS4_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
[AnalysisResults] = FigS3_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
[AnalysisResults] = FigS2_Manuscript2020(rootFolder,saveFigs,AnalysisResults);
%% fin.
disp('MainScript Analysis - Complete'); disp(' ')
% sendmail('kevinlturnerjr@gmail.com','Manuscript2020 Analysis Complete');
end

function [AnalysisResults] = AnalyzeData_Manuscript2020(rootFolder)
% IOS animal IDs
IOS_animalIDs = {'T99','T101','T102','T103','T105','T108','T109','T110','T111','T119','T120','T121','T122','T123'};
% Two photon animal IDs
saveFigs = 'y';
if exist('AnalysisResults.mat') == 2
    load('AnalysisResults.mat')
else
    AnalysisResults = [];
end
%% Block [1] Analyze the stimulus-evoked and whisking-evoked neural/hemodynamic responses (IOS)
runFromStart = 'n';
for pp = 1:length(IOS_animalIDs)
    if isfield(AnalysisResults,(IOS_animalIDs{1,pp})) == false || isfield(AnalysisResults.(IOS_animalIDs{1,pp}),'EvokedAvgs') == false || strcmp(runFromStart,'y') == true
        [AnalysisResults] = AnalyzeEvokedResponses_Manuscript2020(IOS_animalIDs{1,pp},saveFigs,rootFolder,AnalysisResults);
    end
    multiWaitbar_Manuscript2020('Analyzing evoked responses','Value',pp/length(IOS_animalIDs));
end
%% fin.
disp('Loading analysis results and generating figures...'); disp(' ')

end
