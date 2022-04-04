function [AnalysisResults] = AnalyzeEvokedResponses2_GheresTBD(animalID,rootFolder,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: Use epochs from the EventData.mat struct to determine the average hemodynamic and neural responses to
%            whisker stimuli during different arousal states
%________________________________________________________________________________________________________________________

%% function parameters
dataTypes = {'adjLH','adjRH'};
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
samplingRate = EventData.CBV_HbT.adjLH.stim.samplingRate;
trialDuration_sec = EventData.CBV_HbT.adjLH.stim.trialDuration_sec;
timeVector = (0:(EventData.CBV_HbT.adjLH.stim.epoch.duration*samplingRate))/samplingRate - EventData.CBV_HbT.adjLH.stim.epoch.offset;
offset = EventData.CBV_HbT.adjLH.stim.epoch.offset;
% Criteria for the FilterEvents data struct
stimCriteriaA.Value = {'LPadSol'};
stimCriteriaA.Fieldname = {'solenoidName'};
stimCriteriaA.Comparison = {'equal'};
stimCriteriaB.Value = {'RPadSol'};
stimCriteriaB.Fieldname = {'solenoidName'};
stimCriteriaB.Comparison = {'equal'};
stimCriteriaC.Value = {'AudSol'};
stimCriteriaC.Fieldname = {'solenoidName'};
stimCriteriaC.Comparison = {'equal'};
stimCriteriaNames = {'stimCriteriaA','stimCriteriaB','stimCriteriaC'};
for aa = 1:length(dataTypes)
    dataType = dataTypes{1,aa};
    %% filter the EventData.mat structure for stimulus events that meet the desired criteria
    for bb = 1:length(stimCriteriaNames)
        stimCriteriaName = stimCriteriaNames{1,bb};
        if strcmp(stimCriteriaName,'stimCriteriaA') == true
            stimCriteria = stimCriteriaA;
            solenoid = 'LPadSol';
        elseif strcmp(stimCriteriaName,'stimCriteriaB') == true
            stimCriteria = stimCriteriaB;
            solenoid = 'RPadSol';
        elseif strcmp(stimCriteriaName,'stimCriteriaC') == true
            stimCriteria = stimCriteriaC;
            solenoid = 'AudSol';
        end
        allStimFilter = FilterEvents_GheresTBD(EventData.CBV_HbT.(dataType).stim,stimCriteria);
        [allStimHbTData] = EventData.CBV_HbT.(dataType).stim.data(allStimFilter,:);
        [allStimFileIDs] = EventData.CBV_HbT.(dataType).stim.fileIDs(allStimFilter,:);
        [allStimEventTimes] = EventData.CBV_HbT.(dataType).stim.eventTime(allStimFilter,:);
        allStimDurations = zeros(length(allStimEventTimes),1);
        FilterCategories = {'Awake','NREM','Together'};
        for cc = 1:length(FilterCategories)
            filterCategory = FilterCategories{1,cc};
            if strcmp(filterCategory,'Awake') == true
                % decimate the file list to only include those files that occur within the desired number of target minutes
                [finalStimHbTData,finalStimFileIDs,~,finalStimFileEventTimes] = KeepSleepData_GheresTBD(allStimHbTData,allStimFileIDs,allStimDurations,allStimEventTimes,ScoringResults,'Not Sleep');
            elseif strcmp(filterCategory,'NREM') == true
                % decimate the file list to only include those files that occur within the desired number of target minutes
                [finalStimHbTData,finalStimFileIDs,~,finalStimFileEventTimes] = KeepSleepData_GheresTBD(allStimHbTData,allStimFileIDs,allStimDurations,allStimEventTimes,ScoringResults,'NREM Sleep');
            elseif strcmp(filterCategory,'Together') == true
                % decimate the file list to only include those files that occur within the desired number of target minutes
                [finalStimHbTDataA,finalStimFileIDsA,~,finalStimFileEventTimesA] = KeepSleepData_GheresTBD(allStimHbTData,allStimFileIDs,allStimDurations,allStimEventTimes,ScoringResults,'Not Sleep');
                [finalStimHbTDataB,finalStimFileIDsB,~,finalStimFileEventTimesB] = KeepSleepData_GheresTBD(allStimHbTData,allStimFileIDs,allStimDurations,allStimEventTimes,ScoringResults,'NREM Sleep');
                finalStimHbTData = cat(1,finalStimHbTDataA,finalStimHbTDataB);
                finalStimFileIDs = cat(1,finalStimFileIDsA,finalStimFileIDsB);
                finalStimFileEventTimes = cat(1,finalStimFileEventTimesA,finalStimFileEventTimesB);
            end
            % lowpass filter each whisking event and mean-subtract by the first 2 seconds
            ii = 1;
            procStimHbTData = []; finalStimStartTimes = []; finalStimEndTimes = []; finalStimFiles = [];
            for hh = 1:size(finalStimHbTData,1)
                stimStartTime = round(finalStimFileEventTimes(hh,1),1) - 5;
                stimEndTime = stimStartTime + 20;
                finalStimFileID = finalStimFileIDs{hh,1};
                if stimStartTime >= 0.5 && stimEndTime <= (trialDuration_sec - 0.5)
                    stimHbTarray = finalStimHbTData(hh,:);
                    filtStimHbTarray = sgolayfilt(stimHbTarray,3,17);
                    procStimHbTData(hh,:) = filtStimHbTarray - mean(filtStimHbTarray(1:(offset*samplingRate)));
                    finalStimStartTimes(ii,1) = stimStartTime;
                    finalStimEndTimes(ii,1) = stimEndTime;
                    finalStimFiles{ii,1} = finalStimFileID;
                    ii = ii + 1;
                end
            end
            if isempty(procStimHbTData) == false
                meanStimHbTData = mean(procStimHbTData,1);
                % save results
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).HbT = meanStimHbTData;
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).timeVector = timeVector;
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).count = size(procStimHbTData,1);
            else
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid) = NaN;
            end
        end
    end
end
cd(rootFolder)
save('AnalysisResults.mat','AnalysisResults')
end
