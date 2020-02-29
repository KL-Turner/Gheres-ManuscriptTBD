% pull list of raw data files from current directory
rawDataFileStruct = dir('*_RawData.mat');
rawDataFiles = {rawDataFileStruct.name}';
rawDataFileIDs = char(rawDataFiles);
% load each file and create a histogram of the EMG values
% emgHold = [];
% for a = 1:size(rawDataFileIDs,1)
%     disp(['Gathering EMG data for probability distribution: (' num2str(a) '/' num2str(size(rawDataFileIDs,1)) ')']); disp(' ')
%     rawDataFileID = rawDataFileIDs(a,:);
%     load(rawDataFileID)
%     emgHold = cat(2,emgHold,RawData.MUA);
% end
% % plot histogram of EMG data to assist in identification of bimodal distribution values
% figure
% histogram(emgHold,200,'Normalization','probability')
% xlabel('EMG Power')
% ylabel('Probability')
% go through each file and create a list of manual scores
for a = 1:size(rawDataFileIDs,1)
    rawDataFileID = rawDataFileIDs(a,:);
    disp(['Loading ' rawDataFileID ' for manual sleep scoring: (' num2str(a) '/' num2str(size(rawDataFileIDs,1)) ')' ]); disp(' ')
    trainingDataFileID = [rawDataFileID(1:end-11) 'TrainingData.mat'];
    if ~exist(trainingDataFileID,'file')
        load(rawDataFileID)
        % need to add baseline structure or equivalent to figure function
        [figHandle] = GenerateSingleFigures_GT(RawData);
        trialDuration = round(length(RawData.vBall)/RawData.an_fs);
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
            subplot(2,1,1)
            leftEdge1 = xline(xInds(1),'color',colors_GT('electric purple'),'LineWidth',2);
            hold on
            rightEdge1 = xline(xInds(5),'color',colors_GT('electric purple'),'LineWidth',2);
            subplot(2,1,2)
            leftEdge2 = xline(xInds(1),'color',colors_GT('electric purple'),'LineWidth',2);
            hold on
            rightEdge2 = xline(xInds(5),'color',colors_GT('electric purple'),'LineWidth',2);            
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
        delete(rightEdge1)
        delete(rightEdge2)
        end
        close(figHandle)
        TrainingTable.behavState = behavioralState;
        save(trainingDataFileID,'TrainingTable')
    else
        disp([trainingDataFileID ' already exists. Continuing...']); disp(' ')
    end
end