function [] = MainScript_GheresTBD()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
% Purpose: Generates KLT's main and supplemental figs for the Gheres (TBD) paper.
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
if exist('AnalysisResults_Gheres.mat') ~= 2 || strcmp(rerunAnalysis,'y') == true
    multiWaitbar_GheresTBD('Analyzing evoked responses',0,'Color','G'); pause(0.25);
    % run analysis and output a structure containing all the analyzed data.
    [AnalysisResults] = AnalyzeData_Manuscript2020(rootFolder);
    multiWaitbar_GheresTBD('CloseAll');
else
    disp('Loading analysis results and generating figures...'); disp(' ')
    load('AnalysisResults_Gheres.mat')
end
saveFigs = 'y';
%% supplemental figure panels
% FigTemp_GheresTBD(rootFolder,saveFigs,AnalysisResults)
FigTemp2_GheresTBD(rootFolder,saveFigs,AnalysisResults)
% [AnalysisResults] = FigS1_GheresTBD(rootFolder,saveFigs,AnalysisResults);
% [AnalysisResults] = FigS2_GheresTBD(rootFolder,saveFigs,AnalysisResults);
% [AnalysisResults] = FigS3_GheresTBD(rootFolder,saveFigs,AnalysisResults);
% Fig1_GheresTBD(rootFolder,saveFigs,AnalysisResults)
%% fin.
disp('MainScript Analysis - Complete'); disp(' ')
% sendmail('kevinlturnerjr@gmail.com','Manuscript2020 Analysis Complete');
end

function [AnalysisResults] = AnalyzeData_Manuscript2020(rootFolder)
% IOS animal IDs
IOS_animalIDs = {'T99','T101','T102','T103','T105','T108','T109','T110','T111','T119','T120','T121','T122','T123'};
% Two photon animal IDs
if exist('AnalysisResults_Gheres.mat') == 2
    load('AnalysisResults_Gheres.mat')
else
    AnalysisResults = [];
end
%% Block [1] Analyze the stimulus-evoked and whisking-evoked neural/hemodynamic responses (IOS)
runFromStart = 'n';
for pp = 1:length(IOS_animalIDs)
    if isfield(AnalysisResults,(IOS_animalIDs{1,pp})) == false || isfield(AnalysisResults.(IOS_animalIDs{1,pp}),'EvokedAvgs') == false || strcmp(runFromStart,'y') == true
        [AnalysisResults] = AnalyzeEvokedResponses_GheresTBD(IOS_animalIDs{1,pp},rootFolder,AnalysisResults);
    end
    multiWaitbar_GheresTBD('Analyzing evoked responses','Value',pp/length(IOS_animalIDs));
end
%% Block [9] Analyze the spectral coherence between bilateral hemodynamic [HbT] and neural signals (IOS)
runFromStart = 'n';
for jj = 1:length(IOS_animalIDs)
    if isfield(AnalysisResults,(IOS_animalIDs{1,jj})) == false || isfield(AnalysisResults.(IOS_animalIDs{1,jj}),'Coherence') == false || strcmp(runFromStart,'y') == true
        [AnalysisResults] = AnalyzeCoherence_GT(IOS_animalIDs{1,jj},rootFolder,AnalysisResults);
    end
    multiWaitbar_Manuscript2020('Analyzing coherence','Value',jj/length(IOS_animalIDs));
end
%% fin.
disp('Loading analysis results and generating figures...'); disp(' ')

end