% pull list of raw data files from current directory
scoringDataFileStruct = dir('*_SleepScoringData.mat');
scoringDataFiles = {scoringDataFileStruct.name}';
scoringDataFileIDs = char(scoringDataFiles);
% load each file and create a histogram of the EMG values
emgHold = [];
for a = 1:size(scoringDataFileIDs,1)
    disp(['Gathering EMG data for probability distribution: (' num2str(a) '/' num2str(size(scoringDataFileIDs,1)) ')']); disp(' ')
    scoringDataFileID = scoringDataFileIDs(a,:);
    load(scoringDataFileID,'Ephys')
    EMG_Signal=Ephys.downSampleEMG;
    EMG_Signal(EMG_Signal<0)=0; % Negative EMG values are artifact of filtering, set to 0 for plotting purposes
    emgHold = cat(2,emgHold,log(EMG_Signal)); % use natural log transform to visualize dynamic range of EMG signal
end
% plot histogram of EMG data to assist in identification of bimodal distribution values
figure
histogram(emgHold,500,'Normalization','probability')% visualize log transformed data as a histogram using 500 bins
xlabel('EMG Power')
ylabel('Probability')
% go through each file and create a list of manual scores
for a = 1:size(scoringDataFileIDs,1)
    scoringDataFileID = scoringDataFileIDs(a,:);
    disp(['Loading ' scoringDataFileID ' for manual sleep scoring: (' num2str(a) '/' num2str(size(scoringDataFileIDs,1)) ')' ]); disp(' ')
    strBreaks = strfind(scoringDataFileID,'_');
    trainingDataFileID = [scoringDataFileID(1:strBreaks(end)) 'TrainingData.mat'];
    if ~exist(trainingDataFileID,'file')
        load(scoringDataFileID)
        % need to add baseline structure or equivalent to figure function
        [figHandle] = GenerateSingleFigures_GT(AcquisitionParams.downSampled_Fs,Behavior.ballVelocity,Ephys.downSampleEMG,IOS.barrels.dHbT,Spectrograms.FiveSec);
        trialDuration = round(length(Behavior.ballVelocity)/AcquisitionParams.downSampled_Fs);
        % determine number of 5 seconds bins
        numBins = trialDuration/5;
        behavioralState = cell(numBins,1);
        for b = 1:numBins
            global buttonState %#ok<TLEV>
            buttonState = 0;
            xStartVal = (b*5) - 5;
            xEndVal = b*5;
            xInds = xStartVal:1:xEndVal;
            figHandle = gcf;
            subplot(3,1,1)
            leftEdge1 = xline(xInds(1),'color',colors_GT('electric purple'),'LineWidth',2);
            hold on
            rightEdge1 = xline(xInds(5),'color',colors_GT('electric purple'),'LineWidth',2);
            subplot(3,1,2)
            leftEdge2 = xline(xInds(1),'color',colors_GT('electric purple'),'LineWidth',2);
            hold on
            rightEdge2 = xline(xInds(5),'color',colors_GT('electric purple'),'LineWidth',2);
            subplot(3,1,3)
            leftEdge3 = xline(xInds(1),'color',colors_GT('electric purple'),'LineWidth',2);
            hold on
            rightEdge3 = xline(xInds(5),'color',colors_GT('electric purple'),'LineWidth',2);
            % make decision
            [updatedGUI] = SelectBehavioralStateGUI_GT;
            while buttonState == 0
                drawnow()
                if buttonState == 1
                    guiResults = guidata(updatedGUI);
                    if guiResults.togglebutton1.Value == true
                        behavioralState{b,1} = 'Not Sleep';
                    elseif guiResults.togglebutton2.Value == true
                        behavioralState{b,1} = 'NREM Sleep';
                    elseif guiResults.togglebutton3.Value == true
                        behavioralState{b,1} = 'REM Sleep';
                    else
                        disp('No button pressed'); disp(' ')
                        keyboard
                    end
                    close(updatedGUI)
                    break;
                end
                ...
            end
        delete(leftEdge1)
        delete(leftEdge2)
        delete(leftEdge3)
        delete(rightEdge1)
        delete(rightEdge2)
        delete(rightEdge3)
        end
        close(figHandle)
        TrainingTable.behavState = behavioralState;
        save(trainingDataFileID,'TrainingTable')
    else
        disp([trainingDataFileID ' already exists. Continuing...']); disp(' ')
    end
end
