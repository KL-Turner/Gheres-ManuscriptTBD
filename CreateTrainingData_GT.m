% pull list of raw data files from current directory
rawDataFileStruct = dir('*_RawData.mat');
rawDataFiles = {rawDataFileStruct.name}';
rawDataFileIDs = char(rawDataFiles);
% load each file and create a histogram of the EMG values
emgHold = [];
for a = 1:size(rawDataFileIDs,1)
    rawDataFileID = rawDataFileIDs(a,:);
    load(rawDataFileID)
    emgHold = cat(1,emgHold,RawData.data.emg);
end
% plot histogram of EMG data to assist in identification of bimodal distribution values
figure
histogram(emgHold)
% go through each file and create a list of manual scores
for a = 1:size(rawDataFileIDs,1)
    rawDataFileID = rawDataFileIDs(a,:);
    trainingDataFileID = [rawDataFileID(1:end-12) 'TrainingData.mat'];
    if ~exist(trainingDataFileID,'file')
        disp(['Loading ' rawDataFileID ' for manual sleep scoring (' num2str(a) '/' num2str(size(rawDataFileIDs,1)) ')' ]); disp(' ')
        load(rawDataFileID)
        [figHandle] = GenerateSingleFigures_IOS_Manuscript2020(rawDataFileID,RestingBaselines,baselineType);
        trialDuration = ProcData.notes.trialDuration_sec;
        numBins = trialDuration/5;
        behavioralState = cell(180,1);
        for b = 1:numBins
            global buttonState %#ok<TLEV>
            buttonState = 0;
            xStartVal = (b*5) - 4;
            xEndVal = b*5;
            xInds = xStartVal:1:xEndVal;
            subplot(6,1,3)
            yyaxis left
            ylimits3 = ylim;
            yMax3 = ylimits3(2);
            yInds3 = ones(1,5)*yMax3*1.2;
            hold on
            h3 = scatter(xInds,yInds3);          
            if b <= 60
                xlim([1,300])
            elseif b >= 61 && b <= 120
                xlim([300,600])
            elseif b >= 121 && b <= 180
                xlim([600,900])
            end
            [updatedGUI] = SelectBehavioralStateGUI_IOS_Manuscript2020;
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
        delete(h3)
        end
        close(figHandle)
        paramsTable.behavState = behavioralState;
        trainingTable = paramsTable;
        save(trainingDataFileID, 'trainingTable')
    else
        disp([trainingDataFileID ' already exists. Continuing...']); disp(' ')
    end
end
