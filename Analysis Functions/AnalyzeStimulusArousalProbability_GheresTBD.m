function [AnalysisResults] = AnalyzeStimulusArousalProbability_GheresTBD(animalID,rootFolder,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Analyze the transitions between different arousal-states (IOS)
%________________________________________________________________________________________________________________________

%% function parameters
dataLocation = [rootFolder '/' animalID '/Bilateral Imaging/'];
cd(dataLocation)
% find and load EventData.mat struct
eventDataFileStruct = dir('*_EventData.mat');
eventDataFile = {eventDataFileStruct.name}';
eventDataFileID = char(eventDataFile);
load(eventDataFileID)
% forest ID sctruct
forestScoringResultsID = 'Forest_ScoringResults.mat';
load(forestScoringResultsID,'-mat')
% determine the animal's ID use the EventData.mat file's name for the current folder
fileBreaks = strfind(eventDataFileID,'_');
animalID = eventDataFileID(1:fileBreaks(1)-1);
% pull a few necessary numbers from the EventData.mat struct such as trial duration and sampling rate
% Criteria for the FilterEvents data struct
stimCriteriaA.Value = {'LPadSol'};
stimCriteriaA.Fieldname = {'solenoidName'};
stimCriteriaA.Comparison = {'equal'};
stimCriteriaB.Value = {'RPadSol'};
stimCriteriaB.Fieldname = {'solenoidName'};
stimCriteriaB.Comparison = {'equal'};
%% filter the EventData.mat structure for stimulus events that meet the desired criteria
% left pad stimulation
allStimFilterA = FilterEvents_GheresTBD(EventData.CBV_HbT.adjLH.stim,stimCriteriaA);
[allStimFileIDsA] = EventData.CBV_HbT.adjLH.stim.fileIDs(allStimFilterA,:);
[allStimEventTimesA] = EventData.CBV_HbT.adjLH.stim.eventTime(allStimFilterA,:);
% right pad stimulation
allStimFilterB = FilterEvents_GheresTBD(EventData.CBV_HbT.adjLH.stim,stimCriteriaB);
[allStimFileIDsB] = EventData.CBV_HbT.adjLH.stim.fileIDs(allStimFilterB,:);
[allStimEventTimesB] = EventData.CBV_HbT.adjLH.stim.eventTime(allStimFilterB,:);
% combined
allStimFileIDs = cat(1,allStimFileIDsA,allStimFileIDsB);
allStimEventTimes = cat(1,allStimEventTimesA,allStimEventTimesB);
catAwakeNumerics = [];
catAsleepNumerics = [];
for aa = 1:length(allStimEventTimes)
    eventTime = allStimEventTimes(aa,1);
    eventFileID = allStimFileIDs{aa,1};
    stimBinNumber = ceil(eventTime/5) - 1;
    scoringLabels = [];
    for bb = 1:length(ScoringResults.fileIDs)
        sleepFileID = ScoringResults.fileIDs{bb,1};
        if strcmp(eventFileID,sleepFileID) == true
            scoringLabels = ScoringResults.labels{bb,1};
        end
    end
    puffLabels = scoringLabels(stimBinNumber - 2:stimBinNumber + 2);
    goodSet = true;
    for cc = 1:length(puffLabels)
        label = puffLabels{cc,1};
        if strcmp(label,'Not Sleep')
            awakeNumericLabel(1,cc) = 1;
            asleepNumericLabel(1,cc) = 0;
        elseif strcmp(label,'NREM Sleep')
            awakeNumericLabel(1,cc) = 0;
            asleepNumericLabel(1,cc) = 1;
        elseif strcmp(label,'REM Sleep')
            goodSet = false;
        end
    end
    if goodSet == true
        catAwakeNumerics = cat(1,catAwakeNumerics,awakeNumericLabel);
        catAsleepNumerics = cat(1,catAsleepNumerics,asleepNumericLabel);
    end
end
% save results
AnalysisResults.(animalID).Probability.awakeProbability = mean(catAwakeNumerics,1);
AnalysisResults.(animalID).Probability.awakeNumerics = catAwakeNumerics;
AnalysisResults.(animalID).Probability.asleepProbability = mean(catAsleepNumerics,1);
AnalysisResults.(animalID).Probability.asleepNumerics = catAsleepNumerics;
cd(rootFolder)
save('AnalysisResults.mat','AnalysisResults')
end
