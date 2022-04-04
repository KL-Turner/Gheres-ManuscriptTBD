function [AnalysisResults] = AnalyzeTransitionalAverages_GheresTBD(animalID,rootFolder,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Analyze the transitions between different arousal-states (IOS)
%________________________________________________________________________________________________________________________

%% function parameters
animalIDs = {'T99','T101','T102','T103','T105','T108','T109','T110','T111','T119','T120','T121','T122','T123'};
transitions = {'AWAKEtoNREM','NREMtoAWAKE','NREMtoREM','REMtoAWAKE'};
%% only run analysis for valid animal IDs
if any(strcmp(animalIDs,animalID))
    % load model
    modelDirectory = [rootFolder '\' animalID '\Figures\Sleep Models\'];
    cd(modelDirectory)
    modelName = [animalID '_IOS_RF_SleepScoringModel.mat'];
    load(modelName)
    % go to data and load the model files
    dataLocation = [rootFolder '/' animalID '/Bilateral Imaging/'];
    cd(dataLocation)
    modelDataFileStruct = dir('*_ModelData.mat');
    modelDataFile = {modelDataFileStruct.name}';
    modelDataFileIDs = char(modelDataFile);
    baselineFileStruct = dir('*_RestingBaselines.mat');
    baselineFile = {baselineFileStruct.name}';
    baselineFileID = char(baselineFile);
    load(baselineFileID)
    samplingRate = 30;
    fileDates = fieldnames(RestingBaselines.manualSelection.CBV.adjLH);
    % go through each file and sleep score the data
    for a = 1:size(modelDataFileIDs,1)
        modelDataFileID = modelDataFileIDs(a,:);
        if a == 1
            load(modelDataFileID)
            dataLength = size(paramsTable,1);
            joinedTable = paramsTable;
            joinedFileList = cell(size(paramsTable,1),1);
            joinedFileList(:) = {modelDataFileID};
        else
            load(modelDataFileID)
            fileIDCells = cell(size(paramsTable,1),1);
            fileIDCells(:) = {modelDataFileID};
            joinedTable = vertcat(joinedTable,paramsTable); %#ok<*AGROW>
            joinedFileList = vertcat(joinedFileList,fileIDCells);
        end
    end
    scoringTable = joinedTable;
    [labels,~] = predict(RF_MDL,scoringTable);
    % apply a logical patch on the REM events
    REMindex = strcmp(labels,'REM Sleep');
    numFiles = length(labels)/dataLength;
    reshapedREMindex = reshape(REMindex,dataLength,numFiles);
    patchedREMindex = [];
    % patch missing REM indeces due to theta band falling off
    for b = 1:size(reshapedREMindex,2)
        remArray = reshapedREMindex(:,b);
        patchedREMarray = LinkBinaryEvents_IOS_eLife2020(remArray',[5,0]);
        patchedREMindex = vertcat(patchedREMindex,patchedREMarray'); %#ok<*AGROW>
    end
    % change labels for each event
    for c = 1:length(labels)
        if patchedREMindex(c,1) == 1
            labels{c,1} = 'REM Sleep';
        end
    end
    % convert strings to numbers for easier comparisons
    labelNumbers = zeros(length(labels),1);
    for d = 1:length(labels)
        if strcmp(labels{d,1},'Not Sleep') == true
            labelNumbers(d,1) = 1;
        elseif strcmp(labels{d,1},'NREM Sleep') == true
            labelNumbers(d,1) = 2;
        elseif strcmp(labels{d,1},'REM Sleep') == true
            labelNumbers(d,1) = 3;
        end
    end
    % reshape
    fileIDs = unique(joinedFileList);
    fileLabels = reshape(labelNumbers,dataLength,size(modelDataFileIDs,1))';
    stringArray = zeros(1,12);
    for d = 1:length(transitions)
        transition = transitions{1,d};
        if strcmp(transition,'AWAKEtoNREM') == true
            for e = 1:12
                if e <= 6
                    stringArray(1,e) = 1;
                else
                    stringArray(1,e) = 2;
                end
            end
        elseif strcmp(transition,'NREMtoAWAKE') == true
            for e = 1:12
                if e <= 6
                    stringArray(1,e) = 2;
                else
                    stringArray(1,e) = 1;
                end
            end
        elseif strcmp(transition,'NREMtoREM') == true
            for e = 1:12
                if e <= 6
                    stringArray(1,e) = 2;
                else
                    stringArray(1,e) = 3;
                end
            end
        elseif strcmp(transition,'REMtoAWAKE') == true
            for e = 1:12
                if e <= 6
                    stringArray(1,e) = 3;
                else
                    stringArray(1,e) = 1;
                end
            end
        end
        % go through and pull out all indeces of matching strings
        idx = 1;
        for f = 1:length(fileIDs)
            fileID = fileIDs{f,1};
            labelArray = fileLabels(f,:);
            indeces = strfind(labelArray,stringArray);
            if isempty(indeces) == false
                for g1 = 1:length(indeces)
                    data.(transition).files{idx,1} = fileID;
                    data.(transition).startInd(idx,1) = indeces(1,g1);
                    idx = idx + 1;
                end
            end
        end
    end
    % extract data
    for h = 1:length(transitions)
        transition = transitions{1,h};
        iqx = 1;
        for i = 1:length(data.(transition).files)
            file = data.(transition).files{i,1};
            startBin = data.(transition).startInd(i,1);
            if startBin > 1 && startBin < (180 - 12)
                [animalID,fileDate,fileID] = GetFileInfo_IOS_eLife2020(file);
                strDay = ConvertDate_IOS_eLife2020(fileDate);
                procDataFileID = [animalID '_' fileID '_ProcData.mat'];
                load(procDataFileID)
                startTime = (startBin - 1)*5;   % sec
                endTime = startTime + (12*5);   % sec
                % HbT data
                [z2,p2,k2] = butter(4,1/(samplingRate/2),'low');
                [sos2,g2] = zp2sos(z2,p2,k2);
                LH_HbT = ProcData.data.CBV_HbT.adjLH;
                RH_HbT = ProcData.data.CBV_HbT.adjRH;
                filtLH_HbT = filtfilt(sos2,g2,LH_HbT(startTime*samplingRate + 1:endTime*samplingRate));
                filtRH_HbT = filtfilt(sos2,g2,RH_HbT(startTime*samplingRate + 1:endTime*samplingRate));
                data.(transition).fileDate{iqx,1} = strDay;
                data.(transition).LH_HbT(iqx,:) = filtLH_HbT - mean(filtLH_HbT(1:27.5*samplingRate));
                data.(transition).RH_HbT(iqx,:) = filtRH_HbT - mean(filtRH_HbT(1:27.5*samplingRate));
                iqx = iqx + 1;
            end
        end
    end
    % take averages of each behavior
    for d = 1:length(transitions)
        transition = transitions{1,d};
        % save results
        AnalysisResults.(animalID).Transitions.(transition).indFileDate = data.(transition).fileDate;
        AnalysisResults.(animalID).Transitions.(transition).fileDates = fileDates;
        allHbT = cat(1,data.(transition).LH_HbT,data.(transition).RH_HbT);
        AnalysisResults.(animalID).Transitions.(transition).HbT = mean(allHbT,1);
        AnalysisResults.(animalID).Transitions.(transition).LH_HbT = data.(transition).LH_HbT;
        AnalysisResults.(animalID).Transitions.(transition).RH_HbT = data.(transition).RH_HbT;
    end
    % save data
    cd(rootFolder)
    save('AnalysisResults.mat','AnalysisResults')
end

end
