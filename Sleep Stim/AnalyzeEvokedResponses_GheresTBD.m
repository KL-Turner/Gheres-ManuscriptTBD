function [AnalysisResults] = AnalyzeEvokedResponses_GheresTBD(animalID,saveFigs,rootFolder,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: Use epochs from the EventData.mat struct to determine the average hemodynamic and neural responses to
%            both volitional whisking and whisker stimuli
%________________________________________________________________________________________________________________________

%% function parameters
animalIDs = {'T99','T101','T102','T103','T105','T108','T109','T110','T111','T119','T120','T121','T122','T123'};
dataTypes = {'adjLH','adjRH'};
%% only run analysis for valid animal IDs
if any(strcmp(animalIDs,animalID))
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
    for aa = 1:length(dataTypes)
        dataType = dataTypes{1,aa};
        neuralDataType = ['cortical_' dataType(4:end)];
        % pull a few necessary numbers from the EventData.mat struct such as trial duration and sampling rate
        samplingRate = EventData.CBV_HbT.(dataType).whisk.samplingRate;
        specSamplingRate = 10;
        trialDuration_sec = EventData.CBV_HbT.(dataType).whisk.trialDuration_sec;
        timeVector = (0:(EventData.CBV_HbT.(dataType).whisk.epoch.duration*samplingRate))/samplingRate - EventData.CBV_HbT.(dataType).whisk.epoch.offset;
        offset = EventData.CBV_HbT.(dataType).whisk.epoch.offset;
        %% Stimulus-evoked responses
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
        % filter the EventData.mat structure for stimulus events that meet the desired criteria
        for gg = 1:length(stimCriteriaNames)
            stimCriteriaName = stimCriteriaNames{1,gg};
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
            % decimate the file list to only include those files that occur within the desired number of target minutes
            [finalStimHbTData,finalStimFileIDs,~,finalStimFileEventTimes] = RemoveInvalidData_GheresTBD(allStimHbTData,allStimFileIDs,allStimDurations,allStimEventTimes,ManualDecisions);
            [finalStimCBVData,~,~,~] = RemoveInvalidData_GheresTBD(allStimCBVData,allStimFileIDs,allStimDurations,allStimEventTimes,ManualDecisions);
            [finalStimCortMUAData,~,~,~] = RemoveInvalidData_GheresTBD(allStimCortMUAData,allStimFileIDs,allStimDurations,allStimEventTimes,ManualDecisions);
            [finalStimHipMUAData,~,~,~] = RemoveInvalidData_GheresTBD(allStimHipMUAData,allStimFileIDs,allStimDurations,allStimEventTimes,ManualDecisions);
            [finalStimCortGamData,~,~,~] = RemoveInvalidData_GheresTBD(allStimCortGamData,allStimFileIDs,allStimDurations,allStimEventTimes,ManualDecisions);
            [finalStimHipGamData,~,~,~] = RemoveInvalidData_GheresTBD(allStimHipGamData,allStimFileIDs,allStimDurations,allStimEventTimes,ManualDecisions);
            % lowpass filter each whisking event and mean-subtract by the first 2 seconds
            clear procStimHbTData procStimCBVData procStimCorticalMUAData procStimHippocampalMUAData procStimCorticalGamData procStimHippocampalGamData finalStimStartTimes finalStimEndTimes finalStimFiles
            ii = 1;
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
                    procStimHbTData(hh,:) = filtStimHbTarray - mean(filtStimHbTarray(1:(offset*samplingRate)));
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
            % Save figures if desired
            if strcmp(saveFigs,'y') == true
                stimEvoked = figure;
                sgtitle([animalID ' ' dataType ' ' solenoid ' stimulus-evoked averages'])
                subplot(2,3,1);
                p1 = plot(timeVector,meanStimCortMUAData,'k');
                hold on
                plot(timeVector,meanStimCortMUAData + stdStimCortMUAData,'color',colors_Manuscript2020('battleship grey'))
                plot(timeVector,meanStimCortMUAData - stdStimCortMUAData,'color',colors_Manuscript2020('battleship grey'))
                p2 = plot(timeVector,meanStimCortGamData,'r');
                hold on
                plot(timeVector,meanStimCortGamData + stdStimCortGamData,'color',colors_Manuscript2020('deep carrot orange'))
                plot(timeVector,meanStimCortGamData - stdStimCortGamData,'color',colors_Manuscript2020('deep carrot orange'))
                title('Cortical MUA/Gam')
                xlabel('Time (sec)')
                ylabel('Fold-change (Norm Power)')
                legend([p1,p2],'MUA','Gam')
                axis tight
                axis square
                set(gca,'box','off')
                subplot(2,3,2);
                imagesc(T2,F,(meanStimCortS))
                title('Cortical MUA')
                xlabel('Time (sec)')
                ylabel('Freq (Hz)')
                ylim([1,100])
                caxis([-0.5,1])
                set(gca,'Ticklength',[0,0])
                axis xy
                axis square
                set(gca,'box','off')
                subplot(2,3,4);
                plot(timeVector,meanStimHipMUAData,'k')
                hold on
                plot(timeVector,meanStimHipMUAData + stdStimHipMUAData,'color',colors_Manuscript2020('battleship grey'))
                plot(timeVector,meanStimHipMUAData - stdStimHipMUAData,'color',colors_Manuscript2020('battleship grey'))
                plot(timeVector,meanStimHipGamData,'r')
                hold on
                plot(timeVector,meanStimHipGamData + stdStimHipGamData,'color',colors_Manuscript2020('deep carrot orange'))
                plot(timeVector,meanStimHipGamData - stdStimHipGamData,'color',colors_Manuscript2020('deep carrot orange'))
                title('Hippocampal MUA/Gam')
                xlabel('Time (sec)')
                ylabel('Fold-change (Norm Power)')
                axis tight
                axis square
                set(gca,'box','off')
                subplot(2,3,5);
                imagesc(T2,F,meanStimHipS)
                title('Hippocampal MUA')
                xlabel('Time (sec)')
                ylabel('Freq (Hz)')
                ylim([1,100])
                caxis([-0.5,1])
                set(gca,'Ticklength',[0,0])
                axis xy
                axis square
                set(gca,'box','off')
                subplot(2,3,[3,6]);
                plot(timeVector,meanStimHbTData,'k')
                hold on
                plot(timeVector,meanStimHbTData + stdStimHbTData,'color',colors_Manuscript2020('battleship grey'))
                plot(timeVector,meanStimHbTData - stdStimHbTData,'color',colors_Manuscript2020('battleship grey'))
                title('Hemodynamics')
                xlabel('Time (sec)')
                ylabel('\DeltaHbT (\muM)')
                axis tight
                axis square
                set(gca,'box','off')
                savefig(stimEvoked,[dirpath animalID '_' dataType '_' solenoid '_StimEvokedAverages']);
                close(stimEvoked)
            end
            % save results
            AnalysisResults.(animalID).EvokedAvgs.Stim.(dataType).(solenoid).count = size(procStimHipMUAData,1); 
            AnalysisResults.(animalID).EvokedAvgs.Stim.(dataType).(solenoid).CBV_HbT.HbT = meanStimHbTData;
            AnalysisResults.(animalID).EvokedAvgs.Stim.(dataType).(solenoid).CBV_HbT.HbTStD = stdStimHbTData;
            AnalysisResults.(animalID).EvokedAvgs.Stim.(dataType).(solenoid).CBV.CBV = meanStimCBVData;
            AnalysisResults.(animalID).EvokedAvgs.Stim.(dataType).(solenoid).CBV.CBVStD = stdStimCBVData;
            AnalysisResults.(animalID).EvokedAvgs.Stim.(dataType).(solenoid).MUA.corticalData = meanStimCortMUAData;
            AnalysisResults.(animalID).EvokedAvgs.Stim.(dataType).(solenoid).MUA.corticalStD = stdStimCortMUAData;
            AnalysisResults.(animalID).EvokedAvgs.Stim.(dataType).(solenoid).MUA.hippocampalData = meanStimHipMUAData;
            AnalysisResults.(animalID).EvokedAvgs.Stim.(dataType).(solenoid).MUA.hippocampalStD = stdStimHipMUAData;
            AnalysisResults.(animalID).EvokedAvgs.Stim.(dataType).(solenoid).Gam.corticalData = meanStimCortGamData;
            AnalysisResults.(animalID).EvokedAvgs.Stim.(dataType).(solenoid).Gam.corticalStD = stdStimCortGamData;
            AnalysisResults.(animalID).EvokedAvgs.Stim.(dataType).(solenoid).Gam.hippocampalData = meanStimHipGamData;
            AnalysisResults.(animalID).EvokedAvgs.Stim.(dataType).(solenoid).Gam.hippocampalStD = stdStimHipGamData;
            AnalysisResults.(animalID).EvokedAvgs.Stim.(dataType).(solenoid).timeVector = timeVector;
            AnalysisResults.(animalID).EvokedAvgs.Stim.(dataType).(solenoid).LFP.corticalS = meanStimCortS;
            AnalysisResults.(animalID).EvokedAvgs.Stim.(dataType).(solenoid).LFP.hippocampalS = meanStimHipS;
            AnalysisResults.(animalID).EvokedAvgs.Stim.(dataType).(solenoid).LFP.T = T2;
            AnalysisResults.(animalID).EvokedAvgs.Stim.(dataType).(solenoid).LFP.F = F;
        end
        %% NREM sleep evoked responses
        % filter the EventData.mat structure for stimulus events that meet the desired criteria
        for gg = 1:length(stimCriteriaNames)
            stimCriteriaName = stimCriteriaNames{1,gg};
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
            [allStimFileIDs] = EventData.CBV_HbT.(dataType).stim.fileIDs(allStimFilter,:);
            [allStimEventTimes] = EventData.CBV_HbT.(dataType).stim.eventTime(allStimFilter,:);
            allStimDurations = zeros(length(allStimEventTimes),1);
            % decimate the file list to only include those files that occur within the desired number of target minutes
            [finalStimHbTData,finalStimFileIDs,~,finalStimFileEventTimes] = KeepSleepData_GheresTBD(allStimHbTData,allStimFileIDs,allStimDurations,allStimEventTimes,ScoringResults,'NREM Sleep');
            [finalStimCBVData,~,~,~] = KeepSleepData_GheresTBD(allStimCBVData,allStimFileIDs,allStimDurations,allStimEventTimes,ScoringResults,'NREM Sleep');
            [finalStimCortMUAData,~,~,~] = KeepSleepData_GheresTBD(allStimCortMUAData,allStimFileIDs,allStimDurations,allStimEventTimes,ScoringResults,'NREM Sleep');
            [finalStimHipMUAData,~,~,~] = KeepSleepData_GheresTBD(allStimHipMUAData,allStimFileIDs,allStimDurations,allStimEventTimes,ScoringResults,'NREM Sleep');
            % lowpass filter each whisking event and mean-subtract by the first 2 seconds
            clear procStimHbTData procStimCBVData procStimCorticalMUAData procStimHippocampalMUAData finalStimStartTimes finalStimEndTimes finalStimFiles
            if ~isempty(finalStimCBVData) == true
                ii = 1;
                for hh = 1:size(finalStimHbTData,1)
                    stimStartTime = round(finalStimFileEventTimes(hh,1),1) - 2;
                    stimEndTime = stimStartTime + 12;
                    finalStimFileID = finalStimFileIDs{hh,1};
                    if stimStartTime >= 0.5 && stimEndTime <= (trialDuration_sec - 0.5)
                        stimHbTarray = finalStimHbTData(hh,:);
                        stimCBVarray = finalStimCBVData(hh,:);
                        stimCortMUAarray = finalStimCortMUAData(hh,:);
                        stimHipMUAarray = finalStimHipMUAData(hh,:);
                        filtStimHbTarray = sgolayfilt(stimHbTarray,3,17);
                        filtStimCBVarray = sgolayfilt(stimCBVarray,3,17);
                        filtStimCortMUAarray = sgolayfilt(stimCortMUAarray,3,17);
                        filtStimHipMUAarray = sgolayfilt(stimHipMUAarray,3,17);
                        procStimHbTData(hh,:) = filtStimHbTarray - mean(filtStimHbTarray(1:(offset*samplingRate)));
                        procStimCBVData(hh,:) = filtStimCBVarray - mean(filtStimCBVarray(1:(offset*samplingRate)));
                        procStimCortMUAData(hh,:) = filtStimCortMUAarray - mean(filtStimCortMUAarray(1:(offset*samplingRate)));
                        procStimHipMUAData(hh,:) = filtStimHipMUAarray - mean(filtStimHipMUAarray(1:(offset*samplingRate)));
                        finalStimStartTimes(ii,1) = stimStartTime;
                        finalStimEndTimes(ii,1) = stimEndTime;
                        finalStimFiles{ii,1} = finalStimFileID;
                        ii = ii + 1;
                    end
                end
                meanStimHbTData = mean(procStimHbTData,1);
                stdStimHbTData = std(procStimHbTData,0,1);
                meanStimCBVData = mean(procStimCBVData,1)*100;
                stdStimCBVData = std(procStimCBVData,0,1)*100;
                meanStimCortMUAData = mean(procStimCortMUAData,1)*100;
                stdStimCortMUAData = std(procStimCortMUAData,0,1)*100;
                meanStimHipMUAData = mean(procStimHipMUAData,1)*100;
                stdStimHipMUAData = std(procStimHipMUAData,0,1)*100;
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
                % Save figures if desired
                if strcmp(saveFigs,'y') == true
                    stimEvoked = figure;
                    sgtitle([animalID ' ' dataType ' ' solenoid ' stimulus-evoked averages during NREM sleep'])
                    subplot(2,3,1);
                    plot(timeVector,meanStimCortMUAData,'k')
                    hold on
                    plot(timeVector,meanStimCortMUAData + stdStimCortMUAData,'color',colors_Manuscript2020('battleship grey'))
                    plot(timeVector,meanStimCortMUAData - stdStimCortMUAData,'color',colors_Manuscript2020('battleship grey'))
                    title('Cortical MUA')
                    xlabel('Time (sec)')
                    ylabel('Fold-change (Norm Power)')
                    axis tight
                    axis square
                    set(gca,'box','off')
                    subplot(2,3,2);
                    imagesc(T2,F,(meanStimCortS))
                    title('Cortical MUA')
                    xlabel('Time (sec)')
                    ylabel('Freq (Hz)')
                    ylim([1,100])
                    caxis([-0.5,1])
                    set(gca,'Ticklength',[0,0])
                    axis xy
                    axis square
                    set(gca,'box','off')
                    subplot(2,3,4);
                    plot(timeVector,meanStimHipMUAData,'k')
                    hold on
                    plot(timeVector,meanStimHipMUAData + stdStimHipMUAData,'color',colors_Manuscript2020('battleship grey'))
                    plot(timeVector,meanStimHipMUAData - stdStimHipMUAData,'color',colors_Manuscript2020('battleship grey'))
                    title('Hippocampal MUA')
                    xlabel('Time (sec)')
                    ylabel('Fold-change (Norm Power)')
                    axis tight
                    axis square
                    set(gca,'box','off')
                    subplot(2,3,5);
                    imagesc(T2,F,meanStimHipS)
                    title('Hippocampal MUA')
                    xlabel('Time (sec)')
                    ylabel('Freq (Hz)')
                    ylim([1,100])
                    caxis([-0.5,1])
                    set(gca,'Ticklength',[0,0])
                    axis xy
                    axis square
                    set(gca,'box','off')
                    subplot(2,3,[3,6]);
                    plot(timeVector,meanStimHbTData,'k')
                    hold on
                    plot(timeVector,meanStimHbTData + stdStimHbTData,'color',colors_Manuscript2020('battleship grey'))
                    plot(timeVector,meanStimHbTData - stdStimHbTData,'color',colors_Manuscript2020('battleship grey'))
                    title('Hemodynamics')
                    xlabel('Time (sec)')
                    ylabel('\DeltaHbT (\muM)')
                    axis tight
                    axis square
                    set(gca,'box','off')
                    savefig(stimEvoked,[dirpath animalID '_' dataType '_' solenoid '_NREM_StimEvokedAverages']);
                    close(stimEvoked)
                end
                % save results
                AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoid).CBV_HbT.HbT = meanStimHbTData;
                AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoid).CBV_HbT.HbTStD = stdStimHbTData;
                AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoid).CBV.CBV = meanStimCBVData;
                AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoid).CBV.CBVStD = stdStimCBVData;
                AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoid).MUA.corticalData = meanStimCortMUAData;
                AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoid).MUA.corticalStD = stdStimCortMUAData;
                AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoid).MUA.hippocampalData = meanStimHipMUAData;
                AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoid).MUA.hippocampalStD = stdStimHipMUAData;
                AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoid).timeVector = timeVector;
                AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoid).LFP.corticalS = meanStimCortS;
                AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoid).LFP.hippocampalS = meanStimHipS;
                AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoid).LFP.T = T2;
                AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoid).LFP.F = F;
            end
        end
        %% NREM sleep evoked responses
        % filter the EventData.mat structure for stimulus events that meet the desired criteria
        for gg = 1:length(stimCriteriaNames)
            stimCriteriaName = stimCriteriaNames{1,gg};
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
            [allStimFileIDs] = EventData.CBV_HbT.(dataType).stim.fileIDs(allStimFilter,:);
            [allStimEventTimes] = EventData.CBV_HbT.(dataType).stim.eventTime(allStimFilter,:);
            allStimDurations = zeros(length(allStimEventTimes),1);
            % decimate the file list to only include those files that occur within the desired number of target minutes
            [finalStimHbTData,finalStimFileIDs,~,finalStimFileEventTimes] = KeepSleepData_GheresTBD(allStimHbTData,allStimFileIDs,allStimDurations,allStimEventTimes,ScoringResults,'REM Sleep');
            [finalStimCBVData,~,~,~] = KeepSleepData_GheresTBD(allStimCBVData,allStimFileIDs,allStimDurations,allStimEventTimes,ScoringResults,'REM Sleep');
            [finalStimCortMUAData,~,~,~] = KeepSleepData_GheresTBD(allStimCortMUAData,allStimFileIDs,allStimDurations,allStimEventTimes,ScoringResults,'REM Sleep');
            [finalStimHipMUAData,~,~,~] = KeepSleepData_GheresTBD(allStimHipMUAData,allStimFileIDs,allStimDurations,allStimEventTimes,ScoringResults,'REM Sleep');
            % lowpass filter each whisking event and mean-subtract by the first 2 seconds
            clear procStimHbTData procStimCBVData procStimCorticalMUAData procStimHippocampalMUAData finalStimStartTimes finalStimEndTimes finalStimFiles
            if ~isempty(finalStimCBVData) == true
                ii = 1;
                for hh = 1:size(finalStimHbTData,1)
                    stimStartTime = round(finalStimFileEventTimes(hh,1),1) - 2;
                    stimEndTime = stimStartTime + 12;
                    finalStimFileID = finalStimFileIDs{hh,1};
                    if stimStartTime >= 0.5 && stimEndTime <= (trialDuration_sec - 0.5)
                        stimHbTarray = finalStimHbTData(hh,:);
                        stimCBVarray = finalStimCBVData(hh,:);
                        stimCortMUAarray = finalStimCortMUAData(hh,:);
                        stimHipMUAarray = finalStimHipMUAData(hh,:);
                        filtStimHbTarray = sgolayfilt(stimHbTarray,3,17);
                        filtStimCBVarray = sgolayfilt(stimCBVarray,3,17);
                        filtStimCortMUAarray = sgolayfilt(stimCortMUAarray,3,17);
                        filtStimHipMUAarray = sgolayfilt(stimHipMUAarray,3,17);
                        procStimHbTData(hh,:) = filtStimHbTarray - mean(filtStimHbTarray(1:(offset*samplingRate)));
                        procStimCBVData(hh,:) = filtStimCBVarray - mean(filtStimCBVarray(1:(offset*samplingRate)));
                        procStimCortMUAData(hh,:) = filtStimCortMUAarray - mean(filtStimCortMUAarray(1:(offset*samplingRate)));
                        procStimHipMUAData(hh,:) = filtStimHipMUAarray - mean(filtStimHipMUAarray(1:(offset*samplingRate)));
                        finalStimStartTimes(ii,1) = stimStartTime;
                        finalStimEndTimes(ii,1) = stimEndTime;
                        finalStimFiles{ii,1} = finalStimFileID;
                        ii = ii + 1;
                    end
                end
                meanStimHbTData = mean(procStimHbTData,1);
                stdStimHbTData = std(procStimHbTData,0,1);
                meanStimCBVData = mean(procStimCBVData,1)*100;
                stdStimCBVData = std(procStimCBVData,0,1)*100;
                meanStimCortMUAData = mean(procStimCortMUAData,1)*100;
                stdStimCortMUAData = std(procStimCortMUAData,0,1)*100;
                meanStimHipMUAData = mean(procStimHipMUAData,1)*100;
                stdStimHipMUAData = std(procStimHipMUAData,0,1)*100;
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
                % Save figures if desired
                if strcmp(saveFigs,'y') == true
                    stimEvoked = figure;
                    sgtitle([animalID ' ' dataType ' ' solenoid ' stimulus-evoked averages during REM sleep'])
                    subplot(2,3,1);
                    plot(timeVector,meanStimCortMUAData,'k')
                    hold on
                    plot(timeVector,meanStimCortMUAData + stdStimCortMUAData,'color',colors_Manuscript2020('battleship grey'))
                    plot(timeVector,meanStimCortMUAData - stdStimCortMUAData,'color',colors_Manuscript2020('battleship grey'))
                    title('Cortical MUA')
                    xlabel('Time (sec)')
                    ylabel('Fold-change (Norm Power)')
                    axis tight
                    axis square
                    set(gca,'box','off')
                    subplot(2,3,2);
                    imagesc(T2,F,(meanStimCortS))
                    title('Cortical MUA')
                    xlabel('Time (sec)')
                    ylabel('Freq (Hz)')
                    ylim([1,100])
                    caxis([-0.5,1])
                    set(gca,'Ticklength',[0,0])
                    axis xy
                    axis square
                    set(gca,'box','off')
                    subplot(2,3,4);
                    plot(timeVector,meanStimHipMUAData,'k')
                    hold on
                    plot(timeVector,meanStimHipMUAData + stdStimHipMUAData,'color',colors_Manuscript2020('battleship grey'))
                    plot(timeVector,meanStimHipMUAData - stdStimHipMUAData,'color',colors_Manuscript2020('battleship grey'))
                    title('Hippocampal MUA')
                    xlabel('Time (sec)')
                    ylabel('Fold-change (Norm Power)')
                    axis tight
                    axis square
                    set(gca,'box','off')
                    subplot(2,3,5);
                    imagesc(T2,F,meanStimHipS)
                    title('Hippocampal MUA')
                    xlabel('Time (sec)')
                    ylabel('Freq (Hz)')
                    ylim([1,100])
                    caxis([-0.5,1])
                    set(gca,'Ticklength',[0,0])
                    axis xy
                    axis square
                    set(gca,'box','off')
                    subplot(2,3,[3,6]);
                    plot(timeVector,meanStimHbTData,'k')
                    hold on
                    plot(timeVector,meanStimHbTData + stdStimHbTData,'color',colors_Manuscript2020('battleship grey'))
                    plot(timeVector,meanStimHbTData - stdStimHbTData,'color',colors_Manuscript2020('battleship grey'))
                    title('Hemodynamics')
                    xlabel('Time (sec)')
                    ylabel('\DeltaHbT (\muM)')
                    axis tight
                    axis square
                    set(gca,'box','off')
                    savefig(stimEvoked,[dirpath animalID '_' dataType '_' solenoid '_REM_StimEvokedAverages']);
                    close(stimEvoked)
                end
                % save results
                AnalysisResults.(animalID).EvokedAvgs.remStim.(dataType).(solenoid).CBV_HbT.HbT = meanStimHbTData;
                AnalysisResults.(animalID).EvokedAvgs.remStim.(dataType).(solenoid).CBV_HbT.HbTStD = stdStimHbTData;
                AnalysisResults.(animalID).EvokedAvgs.remStim.(dataType).(solenoid).CBV.CBV = meanStimCBVData;
                AnalysisResults.(animalID).EvokedAvgs.remStim.(dataType).(solenoid).CBV.CBVStD = stdStimCBVData;
                AnalysisResults.(animalID).EvokedAvgs.remStim.(dataType).(solenoid).MUA.corticalData = meanStimCortMUAData;
                AnalysisResults.(animalID).EvokedAvgs.remStim.(dataType).(solenoid).MUA.corticalStD = stdStimCortMUAData;
                AnalysisResults.(animalID).EvokedAvgs.remStim.(dataType).(solenoid).MUA.hippocampalData = meanStimHipMUAData;
                AnalysisResults.(animalID).EvokedAvgs.remStim.(dataType).(solenoid).MUA.hippocampalStD = stdStimHipMUAData;
                AnalysisResults.(animalID).EvokedAvgs.remStim.(dataType).(solenoid).timeVector = timeVector;
                AnalysisResults.(animalID).EvokedAvgs.remStim.(dataType).(solenoid).LFP.corticalS = meanStimCortS;
                AnalysisResults.(animalID).EvokedAvgs.remStim.(dataType).(solenoid).LFP.hippocampalS = meanStimHipS;
                AnalysisResults.(animalID).EvokedAvgs.remStim.(dataType).(solenoid).LFP.T = T2;
                AnalysisResults.(animalID).EvokedAvgs.remStim.(dataType).(solenoid).LFP.F = F;
            end
        end
    end
end
cd(rootFolder)
save('AnalysisResults.mat','AnalysisResults')
end

