function [GT_AnalysisInfo] = GT_FindSleepData(sleepScoringDataFiles, GT_AnalysisInfo, guiParams)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: This function uses the sleep logicals in each SleepScoringData file to find periods where there are 60 seconds of 
%            consecutive ones within the sleep logical (12 or more). If a SleepScoringData file's sleep logical contains one or
%            more of these 60 second periods, each of those bins is gathered from the data and put into the SleepEventData.mat
%            struct along with the file's name. 
%________________________________________________________________________________________________________________________
%
%   Inputs: The function loops through each SleepScoringData file within the current folder - no inputs to the function itself
%           This was done as it was easier to add to the SleepEventData struct instead of loading it and then adding to it
%           with each SleepScoringData loop.
%
%   Outputs: SleepEventData.mat struct
%________________________________________________________________________________________________________________________

%% BLOCK PURPOSE: Create sleep scored data structure.
% Identify sleep epochs and place in SleepEventData.mat structure
GT_AnalysisInfo.(guiParams.scoringID).data = [];
sleepBins = guiParams.minSleepTime / 5;
for sF = 1:size(sleepScoringDataFiles, 1)           % Loop through the list of SleepScoringData files
    sleepScoringDataFile = sleepScoringDataFiles(sF, :);
    [~, ~, ~, fileID] = GT_GetFileInfo(sleepScoringDataFile);     % Gather file info
    load(sleepScoringDataFile);                             % Load in sleepScoringDataFile associated with character string
    
    clear deltaPower thetaPower gammaPower ballVelocity HeartRate CBV BinTimes
    clear cellDeltaPower cellThetaPower cellGammaPower cellBallVelocity cellHeartRate cellCBV cellBinTimes
    clear mat2CellDeltaPower mat2CellThetaPower mat2CellGammaPower mat2CellBallVelocity mat2CellHeartRate mat2CellCBV mat2CellBinTimes
    clear matDeltaPower matThetaPower matGammaPower matBallVelocity matHeartRate matCBV matBinTimes
    
    for pF = 1:length(GT_AnalysisInfo.(guiParams.scoringID).FileIDs)
        if strcmp(char(GT_AnalysisInfo.(guiParams.scoringID).FileIDs{pF,1}), fileID)
            sleepLogical = GT_AnalysisInfo.(guiParams.scoringID).Logicals.sleepLogical{pF, 1};
        end
    end
    
    targetTime = ones(1, sleepBins);   % Target time 
    sleepIndex = find(conv(sleepLogical, targetTime) >= sleepBins) - (sleepBins - 1);   % Find the periods of time where there are at least 11 more
    % 5 second epochs following. This is not the full list.
    if isempty(sleepIndex)  % If sleepIndex is empty, skip this file
        % Skip file
    else
        sleepCriteria = (0:(sleepBins - 1));     % This will be used to fix the issue in sleepIndex
        fixedSleepIndex = unique(sleepIndex + sleepCriteria);   % Sleep Index now has the proper time stamps from sleep logical  
        for indexCount = 1:length(fixedSleepIndex)    % Loop through the length of Sleep Index, and pull out associated data
            deltaPower{indexCount, 1} = SleepScoringData.SleepParameters.deltaBandPower{fixedSleepIndex(indexCount), 1};
            thetaPower{indexCount, 1} = SleepScoringData.SleepParameters.thetaBandPower{fixedSleepIndex(indexCount), 1};
            gammaPower{indexCount, 1} = SleepScoringData.SleepParameters.gammaBandPower{fixedSleepIndex(indexCount), 1};
            ballVelocity{indexCount, 1} = SleepScoringData.SleepParameters.ballVelocity{fixedSleepIndex(indexCount), 1};
            HeartRate{indexCount, 1} = SleepScoringData.SleepParameters.HeartRate{fixedSleepIndex(indexCount), 1};
            CBV{indexCount, 1} = SleepScoringData.SleepParameters.CBV{fixedSleepIndex(indexCount), 1};
            BinTimes{indexCount, 1} = 5*fixedSleepIndex(indexCount);
        end
        
        indexBreaks = find(fixedSleepIndex(2:end) - fixedSleepIndex(1:end - 1) > 1);    % Find if there are numerous sleep periods
        
        if isempty(indexBreaks)   % If there is only one period of sleep in this file and not multiple
            matDeltaPower = cell2mat(deltaPower);
            arrayDeltaPower = reshape(matDeltaPower', [1, size(matDeltaPower, 2)*size(matDeltaPower, 1)]);
            cellDeltaPower = {arrayDeltaPower};

            matThetaPower = cell2mat(thetaPower);
            arrayThetaPower = reshape(matThetaPower', [1, size(matThetaPower, 2)*size(matThetaPower, 1)]);
            cellThetaPower = {arrayThetaPower};
                         
            matGammaPower = cell2mat(gammaPower);
            arrayGammaPower = reshape(matGammaPower', [1, size(matGammaPower, 2)*size(matGammaPower, 1)]);
            cellGammaPower = {arrayGammaPower};
            
            for fix = 1:length(ballVelocity)
                if length(ballVelocity{fix,1}) < 150
                    lDiff = 150 - length(ballVelocity{fix,1});
                    lDiff = zeros(lDiff,1);
                    ballVelocity{fix,1} = logical(horzcat(ballVelocity{fix,1}, lDiff));
                end
            end
            matBallVelocity = cell2mat(ballVelocity);
            arrayBallVelocity = reshape(matBallVelocity', [1, size(matBallVelocity, 2)*size(matBallVelocity, 1)]);
            cellBallVelocity = {arrayBallVelocity};
            
            for x = 1:length(HeartRate)
                targetPoints = size(HeartRate{1, 1}, 2);
                if size(HeartRate{x, 1}, 2) ~= targetPoints
                    maxLength = size(HeartRate{x, 1}, 2);
                    difference = targetPoints - size(HeartRate{x, 1}, 2);
                    for y = 1:difference
                        HeartRate{x, 1}(maxLength + y) = mean(HeartRate{x, 1});
                    end
                end
            end
            
            matHeartRate = cell2mat(HeartRate);
            arrayHeartRate = reshape(matHeartRate', [1, size(matHeartRate, 2)*size(matHeartRate, 1)]);
            cellHeartRate = {arrayHeartRate};
            
            matCBV = cell2mat(CBV);
            arrayCBV = reshape(matCBV', [1, size(matCBV, 2)*size(matCBV, 1)]);
            cellCBV = {arrayCBV};
            
            matBinTimes = cell2mat(BinTimes);
            arrayBinTimes = reshape(matBinTimes', [1, size(matBinTimes, 2)*size(matBinTimes, 1)]);
            cellBinTimes = {arrayBinTimes};
        else
            count = length(fixedSleepIndex);
            holdIndex = zeros(1, (length(indexBreaks) + 1));
            
            for indexCounter = 1:length(indexBreaks) + 1
                if indexCounter == 1
                    holdIndex(indexCounter) = indexBreaks(indexCounter);
                elseif indexCounter == length(indexBreaks) + 1
                    holdIndex(indexCounter) = count - indexBreaks(indexCounter - 1);
                else
                    holdIndex(indexCounter)= indexBreaks(indexCounter) - indexBreaks(indexCounter - 1);
                end
            end
            
            splitCounter = 1:length(deltaPower);
            convertedMat2Cell = mat2cell(splitCounter', holdIndex);
            
            for matCounter = 1:length(convertedMat2Cell)
                mat2CellDeltaPower{matCounter, 1} = deltaPower(convertedMat2Cell{matCounter, 1});
                mat2CellThetaPower{matCounter, 1} = thetaPower(convertedMat2Cell{matCounter, 1});
                mat2CellGammaPower{matCounter, 1} = gammaPower(convertedMat2Cell{matCounter, 1});
                mat2CellCBV{matCounter, 1} = CBV(convertedMat2Cell{matCounter, 1});
                mat2CellBallVelocity{matCounter, 1} = ballVelocity(convertedMat2Cell{matCounter, 1});
                mat2CellHeartRate{matCounter, 1} = HeartRate(convertedMat2Cell{matCounter, 1});
                mat2CellBinTimes{matCounter, 1} = BinTimes(convertedMat2Cell{matCounter, 1});
            end
            
            for cellCounter = 1:length(mat2CellDeltaPower)
                matDeltaPower = cell2mat(mat2CellDeltaPower{cellCounter, 1});
                arrayDeltaPower = reshape(matDeltaPower', [1, size(matDeltaPower, 2)*size(matDeltaPower, 1)]);
                cellDeltaPower{cellCounter, 1} = arrayDeltaPower;           
                
                matThetaPower = cell2mat(mat2CellThetaPower{cellCounter, 1});
                arrayThetaPower = reshape(matThetaPower', [1, size(matThetaPower, 2)*size(matThetaPower, 1)]);
                cellThetaPower{cellCounter, 1} = arrayThetaPower;
                
                matGammaPower = cell2mat(mat2CellGammaPower{cellCounter, 1});
                arrayGammaPower = reshape(matGammaPower', [1, size(matGammaPower, 2)*size(matGammaPower, 1)]);
                cellGammaPower{cellCounter, 1} = arrayGammaPower;
                
                matCBV = cell2mat(mat2CellCBV{cellCounter, 1});
                arrayCBV = reshape(matCBV', [1, size(matCBV, 2)*size(matCBV, 1)]);
                cellCBV{cellCounter, 1} = arrayCBV;             
                
                for x = 1:size(mat2CellBallVelocity{cellCounter, 1}, 1)
                    targetPoints = size(mat2CellBallVelocity{cellCounter, 1}{1, 1}, 2);
                    if size(mat2CellBallVelocity{cellCounter, 1}{x, 1}, 2) ~= targetPoints
                        maxLength = size(mat2CellBallVelocity{cellCounter, 1}{x, 1}, 2);
                        difference = targetPoints - size(mat2CellBallVelocity{cellCounter, 1}{x, 1}, 2);
                        for y = 1:difference
                            mat2CellBallVelocity{cellCounter, 1}{x, 1}(maxLength + y) = 0;
                        end
                    end
                end
                
                matBallVelocity = cell2mat(mat2CellBallVelocity{cellCounter, 1});
                arrayBallVelocity = reshape(matBallVelocity', [1, size(matBallVelocity, 2)*size(matBallVelocity, 1)]);
                cellBallVelocity{cellCounter, 1} = arrayBallVelocity;
                
                for x = 1:size(mat2CellHeartRate{cellCounter, 1}, 1)
                    targetPoints = size(mat2CellHeartRate{cellCounter, 1}{1, 1}, 2);
                    if size(mat2CellHeartRate{cellCounter, 1}{x, 1}, 2) ~= targetPoints
                        maxLength = size(mat2CellHeartRate{cellCounter, 1}{x, 1}, 2);
                        difference = targetPoints - size(mat2CellHeartRate{cellCounter, 1}{x, 1}, 2);
                        for y = 1:difference
                            mat2CellHeartRate{cellCounter, 1}{x, 1}(maxLength + y) = mean(mat2CellHeartRate{cellCounter, 1}{x, 1});
                        end
                    end
                end
                
                matHeartRate = cell2mat(mat2CellHeartRate{cellCounter, 1});
                arrayHeartRate = reshape(matHeartRate', [1, size(matHeartRate, 2)*size(matHeartRate, 1)]);
                cellHeartRate{cellCounter, 1} = arrayHeartRate;
                
                matBinTimes = cell2mat(mat2CellBinTimes{cellCounter, 1});
                arrayBinTimes = reshape(matBinTimes', [1, size(matBinTimes, 2)*size(matBinTimes, 1)]);
                cellBinTimes{cellCounter, 1} = arrayBinTimes;
            end
        end
        
        %% BLOCK PURPOSE: Save the data in the SleepEventData struct
        if isempty(GT_AnalysisInfo.(guiParams.scoringID).data)  % If the structure is empty, we need a special case to format the struct properly
            for cellLength = 1:size(cellDeltaPower, 2)   % Loop through however many sleep epochs this file has
                GT_AnalysisInfo.(guiParams.scoringID).data.deltaBandPower{cellLength, 1} = cellDeltaPower{1, 1};
                GT_AnalysisInfo.(guiParams.scoringID).data.thetaBandPower{cellLength, 1} = cellThetaPower{1, 1};
                GT_AnalysisInfo.(guiParams.scoringID).data.gammaBandPower{cellLength, 1} = cellGammaPower{1, 1};
                GT_AnalysisInfo.(guiParams.scoringID).data.CBV{cellLength, 1} = cellCBV{1, 1};
                GT_AnalysisInfo.(guiParams.scoringID).data.ballVelocity{cellLength, 1} = cellBallVelocity{1, 1};
                GT_AnalysisInfo.(guiParams.scoringID).data.heartRate{cellLength, 1} = cellHeartRate{1, 1};
                GT_AnalysisInfo.(guiParams.scoringID).data.fileIDs{cellLength, 1} = fileID;
                GT_AnalysisInfo.(guiParams.scoringID).data.binTimes{cellLength, 1} = cellBinTimes{1, 1};
            end
        else    % If the struct is not empty, add each new iteration after previous data
            for cellLength = 1:size(cellDeltaPower, 1)   % Loop through however many sleep epochs this file has
                GT_AnalysisInfo.(guiParams.scoringID).data.deltaBandPower{size(GT_AnalysisInfo.(guiParams.scoringID).data.deltaBandPower, 1) + 1, 1} = cellDeltaPower{cellLength, 1};
                GT_AnalysisInfo.(guiParams.scoringID).data.thetaBandPower{size(GT_AnalysisInfo.(guiParams.scoringID).data.thetaBandPower, 1) + 1, 1} = cellThetaPower{cellLength, 1};
                GT_AnalysisInfo.(guiParams.scoringID).data.gammaBandPower{size(GT_AnalysisInfo.(guiParams.scoringID).data.gammaBandPower, 1) + 1, 1} = cellGammaPower{cellLength, 1};
                GT_AnalysisInfo.(guiParams.scoringID).data.CBV{size(GT_AnalysisInfo.(guiParams.scoringID).data.CBV, 1) + 1, 1} = cellCBV{cellLength, 1};
                GT_AnalysisInfo.(guiParams.scoringID).data.ballVelocity{size(GT_AnalysisInfo.(guiParams.scoringID).data.ballVelocity, 1) + 1, 1} = cellBallVelocity{cellLength, 1};
                GT_AnalysisInfo.(guiParams.scoringID).data.heartRate{size(GT_AnalysisInfo.(guiParams.scoringID).data.heartRate, 1) + 1, 1} = cellHeartRate{cellLength, 1};
                GT_AnalysisInfo.(guiParams.scoringID).data.fileIDs{size(GT_AnalysisInfo.(guiParams.scoringID).data.fileIDs, 1) + 1, 1} = fileID;
                GT_AnalysisInfo.(guiParams.scoringID).data.binTimes{size(GT_AnalysisInfo.(guiParams.scoringID).data.binTimes, 1) + 1, 1} = cellBinTimes{cellLength, 1};
            end
        end        
    end
end

end
