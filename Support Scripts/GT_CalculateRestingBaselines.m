function [GT_AnalysisInfo] = GT_CalculateRestingBaselines(GT_AnalysisInfo, guiParams)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: This function finds the resting baseline for all fields of the GT_AnalysisInfo.RestData.mat structure, for each unique day
%________________________________________________________________________________________________________________________
%
%   Inputs: animal name (str) for saving purposes, targetMinutes (such as 30, 60, etc) which the code will interpret as
%           the number of minutes/files at the beginning of each unique imaging day to use for baseline calculation.
%           GT_AnalysisInfo.RestData.mat, which should have field names such as CBV, Delta Power, Gamma Power, etc. with ALL resting events
%
%   Outputs: SleepRestEventData.mat struct
%
%   Last Revision: March 8th, 2019
%________________________________________________________________________________________________________________________

% The GT_AnalysisInfo.RestData.mat struct has all resting events, regardless of duration. We want to set the threshold for rest as anything
% that is greater than 10 seconds.
RestCriteria.Fieldname = {'durations'};
RestCriteria.Comparison = {'gt'};
RestCriteria.Value = {15}; %minimum duration in seconds to classify as true rest. Changed to 15sec 3-13-19 KWG

puffCriteria.Fieldname = {'puffDistances'};
puffCriteria.Comparison = {'gt'};
puffCriteria.Value = {5}; %duration after whisker stimulus to consider start of resting period.

% Find the fieldnames of GT_AnalysisInfo.RestData and loop through each field. Each fieldname should be a different dataType of interest.
% These will typically be CBV, Delta, Theta, Gamma, and MUA
dataTypes = fieldnames(GT_AnalysisInfo.RestData);
for dT = 1:length(dataTypes)
    dataType = char(dataTypes(dT));   % Load each loop iteration's fieldname as a character string
    
    % Use the RestCriteria we specified earlier to find all resting events that are greater than the criteria
    [restLogical] = GT_FilterEvents(GT_AnalysisInfo.RestData.(dataType), RestCriteria);   % Output is a logical
    [puffLogical] = GT_FilterEvents(GT_AnalysisInfo.RestData.(dataType), puffCriteria);   % Output is a logical
    combRestLogical = logical(restLogical.*puffLogical);
    allRestFiles = GT_AnalysisInfo.RestData.(dataType).fileIDs(combRestLogical, :);   % Overall logical for all resting file names that meet criteria
    allRestDurations = GT_AnalysisInfo.RestData.(dataType).durations(combRestLogical, :);
    allRestEventTimes = GT_AnalysisInfo.RestData.(dataType).eventTimes(combRestLogical, :);
    restingData = GT_AnalysisInfo.RestData.(dataType).data(combRestLogical, :);   % Pull out data from all those resting files that meet criteria
    
    uniqueDays = GT_GetUniqueDays(GT_AnalysisInfo.RestData.(dataType).fileIDs);   % Find the unique days of imaging
    uniqueFiles = unique(GT_AnalysisInfo.RestData.(dataType).fileIDs);   % Find the unique files from the filelist. This removes duplicates
    % since most files have more than one resting event
    numberOfFiles = length(unique(GT_AnalysisInfo.RestData.(dataType).fileIDs));   % Find the number of unique files
    fileTarget = guiParams.awakeDuration / 5;   % Divide that number of unique files by 5 (minutes) to get the number of files that
    % corresponds to the desired targetMinutes
    
    % Loop through each unique day in order to create a logical to filter the file list so that it only includes the first
    % x number of files that fall within the targetMinutes requirement
    for uD = 1:length(uniqueDays)
        day = uniqueDays(uD);
        x = 1;
        for nOF = 1:numberOfFiles
            file = uniqueFiles(nOF);
            fileID = file{1}(1:6);
            if strcmp(day, fileID) && x <= fileTarget
                filtLogical{uD, 1}(nOF, 1) = 1;
                x = x + 1;
            else
                filtLogical{uD, 1}(nOF, 1) = 0;
            end
        end
    end
    % Combine the 3 logicals so that it reflects the first "x" number of files from each day
    finalLogical = any(sum(cell2mat(filtLogical'), 2), 2);
    
    % Now that the appropriate files from each day are identified, loop through each file name with respect to the original
    % list of ALL resting files, only keeping the ones that fall within the first targetMinutes of each day.
    filtRestFiles = uniqueFiles(finalLogical, :);
    for rF = 1:length(allRestFiles)
        logic = strcmp(allRestFiles{rF}, filtRestFiles);
        logicSum = sum(logic);
        if logicSum == 1
            fileFilter(rF, 1) = 1;
        else
            fileFilter(rF, 1) = 0;
        end
    end
    
    finalFileFilter = logical(fileFilter);
    finalFileIDs = allRestFiles(finalFileFilter, :);
    finalFileDurations = allRestDurations(finalFileFilter, :);
    finalFileEventTimes = allRestEventTimes(finalFileFilter, :);
    finalGT_AnalysisInfo.RestData = restingData(finalFileFilter, :);
    
    % Loop through each unique day and pull out the data that corresponds to the resting files
    for y = 1:length(uniqueDays)
        z = 1;
        for x = 1:length(finalFileIDs)
            fileID = finalFileIDs{x, 1}(1:6);
            date{y, 1} = GT_ConvertDate(uniqueDays{y, 1});
            if strcmp(fileID, uniqueDays{y, 1}) == 1
                tempData.(date{y, 1}){z, 1} = finalGT_AnalysisInfo.RestData{x, 1};
                z = z + 1;
            end
        end
    end
    
    % find the means of each unique day
    for x = 1:size(date, 1)
        tempData_means{x, 1} = cellfun(@(x) mean(x), tempData.(date{x, 1}));    % LH date-specific means
        tempData_stanDev{x,1}=cellfun(@(x) std(x),tempData.(date{x,1}));
    end
    
    % Save the means into the Baseline struct under the current loop iteration with the associated dates
    for x = 1:length(uniqueDays)
        GT_AnalysisInfo.baselines.(dataType).(date{x, 1}).Avg = mean(tempData_means{x, 1});    % LH date-specific means
        GT_AnalysisInfo.baselines.(dataType).(date{x, 1}).stanDev = mean(tempData_stanDev{x, 1});
    end
end

GT_AnalysisInfo.baselineFileInfo.fileIDs = finalFileIDs;
GT_AnalysisInfo.baselineFileInfo.eventTimes = finalFileEventTimes;
GT_AnalysisInfo.baselineFileInfo.durations = finalFileDurations;

end
