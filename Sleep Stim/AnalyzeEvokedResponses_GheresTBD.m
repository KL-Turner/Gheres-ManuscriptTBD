function [AnalysisResults] = AnalyzeEvokedResponses_GheresTBD(animalID,rootFolder,AnalysisResults)
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
% find and load Manual baseline event information
manualBaselineFileStruct = dir('*_ManualBaselineFileList.mat');
manualBaselineFile = {manualBaselineFileStruct.name}';
manualBaselineFileID = char(manualBaselineFile);
load(manualBaselineFileID)
% find and load RestingBaselines.mat struct
baselineDataFileStruct = dir('*_RestingBaselines.mat');
baselineDataFile = {baselineDataFileStruct.name}';
baselineDataFileID = char(baselineDataFile);
load(baselineDataFileID)
% find and load AllSpecStruct.mat struct
allSpecStructFileStruct = dir('*_AllSpecStructB.mat');
allSpecStructFile = {allSpecStructFileStruct.name}';
allSpecStructFileID = char(allSpecStructFile);
load(allSpecStructFileID)
% forest ID sctruct
forestScoringResultsID = 'Forest_ScoringResults.mat';
load(forestScoringResultsID,'-mat')
% determine the animal's ID use the EventData.mat file's name for the current folder
fileBreaks = strfind(eventDataFileID,'_');
animalID = eventDataFileID(1:fileBreaks(1)-1);
% pull a few necessary numbers from the EventData.mat struct such as trial duration and sampling rate
samplingRate = EventData.CBV_HbT.adjLH.stim.samplingRate;
specSamplingRate = 10;
trialDuration_sec = EventData.CBV_HbT.adjLH.stim.trialDuration_sec;
timeVector = (0:(EventData.CBV_HbT.adjLH.stim.epoch.duration*samplingRate))/samplingRate - EventData.CBV_HbT.adjLH.stim.epoch.offset;
offset = EventData.CBV_HbT.adjLH.stim.epoch.offset;
T2 = -2:(1/specSamplingRate):10;
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
    neuralDataType = ['cortical_' dataType(4:end)];
    % filter the EventData.mat structure for stimulus events that meet the desired criteria
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
        [allStimCBVData] = EventData.CBV.(dataType).stim.NormData(allStimFilter,:);
        [allStimCortMUAData] = EventData.(neuralDataType).muaPower.stim.NormData(allStimFilter,:);
        [allStimHipMUAData] = EventData.hippocampus.muaPower.stim.NormData(allStimFilter,:);
        [allStimCortGamData] = EventData.(neuralDataType).gammaBandPower.stim.NormData(allStimFilter,:);
        [allStimHipGamData] = EventData.hippocampus.gammaBandPower.stim.NormData(allStimFilter,:);
        [allStimFileIDs] = EventData.CBV_HbT.(dataType).stim.fileIDs(allStimFilter,:);
        [allStimEventTimes] = EventData.CBV_HbT.(dataType).stim.eventTime(allStimFilter,:);
        allStimDurations = zeros(length(allStimEventTimes),1);
        FilterCategories = {'Awake','NREM','REM','NREMawake','REMawake'};
        for cc = 1:length(FilterCategories)
            filterCategory = FilterCategories{1,cc};
            if strcmp(filterCategory,'Awake') == true
                % decimate the file list to only include those files that occur within the desired number of target minutes
                [finalStimHbTData,finalStimFileIDs,~,finalStimFileEventTimes] = RemoveInvalidData_GheresTBD(allStimHbTData,allStimFileIDs,allStimDurations,allStimEventTimes,ManualDecisions);
                [finalStimCBVData,~,~,~] = RemoveInvalidData_GheresTBD(allStimCBVData,allStimFileIDs,allStimDurations,allStimEventTimes,ManualDecisions);
                [finalStimCortMUAData,~,~,~] = RemoveInvalidData_GheresTBD(allStimCortMUAData,allStimFileIDs,allStimDurations,allStimEventTimes,ManualDecisions);
                [finalStimHipMUAData,~,~,~] = RemoveInvalidData_GheresTBD(allStimHipMUAData,allStimFileIDs,allStimDurations,allStimEventTimes,ManualDecisions);
                [finalStimCortGamData,~,~,~] = RemoveInvalidData_GheresTBD(allStimCortGamData,allStimFileIDs,allStimDurations,allStimEventTimes,ManualDecisions);
                [finalStimHipGamData,~,~,~] = RemoveInvalidData_GheresTBD(allStimHipGamData,allStimFileIDs,allStimDurations,allStimEventTimes,ManualDecisions);
            else
                if strcmp(filterCategory,'NREM') == true
                    scoreA = 'NREM Sleep';
                    scoreB = 'NREM Sleep';
                elseif strcmp(filterCategory,'REM') == true
                    scoreA = 'REM Sleep';
                    scoreB = 'REM Sleep';
                elseif strcmp(filterCategory,'NREMawake') == true
                    scoreA = 'NREM Sleep';
                    scoreB = 'Not Sleep';
                elseif strcmp(filterCategory,'REMawake') == true
                    scoreA = 'REM Sleep';
                    scoreB = 'Not Sleep';
                end
                % decimate the file list to only include those files that occur within the desired number of target minutes
                [finalStimHbTData,finalStimFileIDs,~,finalStimFileEventTimes] = KeepSleepData_GheresTBD(allStimHbTData,allStimFileIDs,allStimDurations,allStimEventTimes,ScoringResults,scoreA,scoreB);
                [finalStimCBVData,~,~,~] = KeepSleepData_GheresTBD(allStimCBVData,allStimFileIDs,allStimDurations,allStimEventTimes,ScoringResults,scoreA,scoreB);
                [finalStimCortMUAData,~,~,~] = KeepSleepData_GheresTBD(allStimCortMUAData,allStimFileIDs,allStimDurations,allStimEventTimes,ScoringResults,scoreA,scoreB);
                [finalStimHipMUAData,~,~,~] = KeepSleepData_GheresTBD(allStimHipMUAData,allStimFileIDs,allStimDurations,allStimEventTimes,ScoringResults,scoreA,scoreB);
                [finalStimCortGamData,~,~,~] = KeepSleepData_GheresTBD(allStimCortGamData,allStimFileIDs,allStimDurations,allStimEventTimes,ScoringResults,scoreA,scoreB);
                [finalStimHipGamData,~,~,~] = KeepSleepData_GheresTBD(allStimHipGamData,allStimFileIDs,allStimDurations,allStimEventTimes,ScoringResults,scoreA,scoreB);
            end
            % lowpass filter each whisking event and mean-subtract by the first 2 seconds
            clear procStimHbTData procStimCBVData procStimCortMUAData procStimHipMUAData procStimCortGamData procStimHipGamData finalStimStartTimes finalStimEndTimes finalStimFiles
            ii = 1;
            procStimHbTData = [];
            for hh = 1:size(finalStimHbTData,1)
                stimStartTime = round(finalStimFileEventTimes(hh,1),1) - 2;
                stimEndTime = stimStartTime + 12;
                finalStimFileID = finalStimFileIDs{hh,1};
                if stimStartTime >= 0.5 && stimEndTime <= (trialDuration_sec - 0.5)
                    stimHbTarray = finalStimHbTData(hh,:);
                    stimCBVarray = finalStimCBVData(hh,:);
                    stimCortMUAarray = finalStimCortMUAData(hh,:);
                    stimHipMUAarray = finalStimHipMUAData(hh,:);
                    stimCortGamArray = finalStimCortGamData(hh,:);
                    stimHipGamArray = finalStimHipGamData(hh,:);
                    filtStimHbTarray = sgolayfilt(stimHbTarray,3,17);
                    filtStimCBVarray = sgolayfilt(stimCBVarray,3,17);
                    filtStimCortMUAarray = sgolayfilt(stimCortMUAarray,3,17);
                    filtStimHipMUAarray = sgolayfilt(stimHipMUAarray,3,17);
                    filtStimCortGamArray = sgolayfilt(stimCortGamArray,3,17);
                    filtStimHipGamArray = sgolayfilt(stimHipGamArray,3,17);
                    procStimHbTData(hh,:) = filtStimHbTarray - mean(filtStimHbTarray(1:(offset*samplingRate))); %#ok<*AGROW>
                    procStimCBVData(hh,:) = filtStimCBVarray - mean(filtStimCBVarray(1:(offset*samplingRate)));
                    procStimCortMUAData(hh,:) = filtStimCortMUAarray - mean(filtStimCortMUAarray(1:(offset*samplingRate)));
                    procStimHipMUAData(hh,:) = filtStimHipMUAarray - mean(filtStimHipMUAarray(1:(offset*samplingRate)));
                    procStimCortGamData(hh,:) = filtStimCortGamArray - mean(filtStimCortGamArray(1:(offset*samplingRate)));
                    procStimHipGamData(hh,:) = filtStimHipGamArray - mean(filtStimHipGamArray(1:(offset*samplingRate)));
                    finalStimStartTimes(ii,1) = stimStartTime;
                    finalStimEndTimes(ii,1) = stimEndTime;
                    finalStimFiles{ii,1} = finalStimFileID;
                    ii = ii + 1;
                end
            end
            if isempty(procStimHbTData) == false
                meanStimHbTData = mean(procStimHbTData,1);
                stdStimHbTData = std(procStimHbTData,0,1);
                meanStimCBVData = mean(procStimCBVData,1)*100;
                stdStimCBVData = std(procStimCBVData,0,1)*100;
                meanStimCortMUAData = mean(procStimCortMUAData,1)*100;
                stdStimCortMUAData = std(procStimCortMUAData,0,1)*100;
                meanStimHipMUAData = mean(procStimHipMUAData,1)*100;
                stdStimHipMUAData = std(procStimHipMUAData,0,1)*100;
                meanStimCortGamData = mean(procStimCortGamData,1)*100;
                stdStimCortGamData = std(procStimCortGamData,0,1)*100;
                meanStimHipGamData = mean(procStimHipGamData,1)*100;
                stdStimHipGamData = std(procStimHipGamData,0,1)*100;
                % extract LFP from spectrograms associated with the stimuli indecies
                stimCortZhold = [];
                stimHipZhold = [];
                for jj = 1:length(finalStimFiles)
                    % load normalized one-second bin data from each file
                    stimFileID = finalStimFiles{jj,1};
                    stimSpecDataFileID = [animalID '_' stimFileID '_SpecDataB.mat'];
                    stimSpecField = neuralDataType;
                    for kk = 1:length(AllSpecData.(stimSpecField).fileIDs)
                        if strcmp(AllSpecData.(stimSpecField).fileIDs{kk,1},stimSpecDataFileID) == true
                            stimCorticalS_Data = AllSpecData.(stimSpecField).normS{kk,1};
                            stimHippocampalS_Data = AllSpecData.hippocampus.normS{kk,1};
                            F = AllSpecData.(stimSpecField).F{kk,1};
                            T = round(AllSpecData.(stimSpecField).T{kk,1},1);
                        end
                    end
                    stimStartTimeIndex = find(T == round(finalStimStartTimes(jj,1),1));
                    stimStartTimeIndex = stimStartTimeIndex(1);
                    stimDurationIndex = find(T == round(finalStimEndTimes(jj,1),1));
                    stimDurationIndex = stimDurationIndex(end);
                    stimCorticalS_Vals = stimCorticalS_Data(:,stimStartTimeIndex:stimDurationIndex);
                    stimHippocampalS_Vals = stimHippocampalS_Data(:,stimStartTimeIndex:stimDurationIndex);
                    % mean subtract each row with detrend
                    transpStimCorticalS_Vals = stimCorticalS_Vals';
                    transpStimHippocampalS_Vals = stimHippocampalS_Vals';
                    dTStimCortS_Vals = transpStimCorticalS_Vals;
                    dTStimCortS_Vals = dTStimCortS_Vals(1:12*specSamplingRate + 1,:);
                    dTStimHipS_Vals = transpStimHippocampalS_Vals;
                    dTStimHipS_Vals = dTStimHipS_Vals(1:12*specSamplingRate + 1,:);
                    stimCortZhold = cat(3,stimCortZhold,dTStimCortS_Vals');
                    stimHipZhold = cat(3,stimHipZhold,dTStimHipS_Vals');
                end
                % figure time/frequency axis and average each S data matrix through time
                meanStimCortS = mean(stimCortZhold,3);
                meanStimHipS = mean(stimHipZhold,3);
                % save results
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).count = size(procStimHipMUAData,1);
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).CBV_HbT.HbT = meanStimHbTData;
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).CBV_HbT.HbTStD = stdStimHbTData;
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).CBV.CBV = meanStimCBVData;
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).CBV.CBVStD = stdStimCBVData;
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).MUA.corticalData = meanStimCortMUAData;
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).MUA.corticalStD = stdStimCortMUAData;
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).MUA.hippocampalData = meanStimHipMUAData;
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).MUA.hippocampalStD = stdStimHipMUAData;
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).Gam.corticalData = meanStimCortGamData;
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).Gam.corticalStD = stdStimCortGamData;
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).Gam.hippocampalData = meanStimHipGamData;
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).Gam.hippocampalStD = stdStimHipGamData;
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).timeVector = timeVector;
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).LFP.corticalS = meanStimCortS;
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).LFP.hippocampalS = meanStimHipS;
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).LFP.T = T2;
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid).LFP.F = F;
            else
                AnalysisResults.(animalID).EvokedAvgs.(filterCategory).(dataType).(solenoid) = NaN;
            end
        end
    end
end
cd(rootFolder)
save('AnalysisResults_Gheres.mat','AnalysisResults')
end
