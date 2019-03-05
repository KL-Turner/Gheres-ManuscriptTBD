function [GT_AnalysisInfo] = GT_ExtractRestingData(rawDataFiles, dataTypes, GT_AnalysisInfo)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% Ph.D. Candidate, Department of Bioengineering
% The Pennsylvania State University
%________________________________________________________________________________________________________________________
%
%   Purpose:
%________________________________________________________________________________________________________________________
%
%   Inputs:
%
%   Outputs: RestData.mat
%________________________________________________________________________________________________________________________

global blockThreeProg
if not(iscell(dataTypes))
    dataTypes = {dataTypes};
end

for dT = 1:length(dataTypes)
    restVals = cell(size(rawDataFiles, 1), 1);
    eventTimes = cell(size(rawDataFiles, 1), 1);
    durations = cell(size(rawDataFiles, 1), 1);
    puffDistances = cell(size(rawDataFiles, 1), 1);
    fileIDs = cell(size(rawDataFiles, 1), 1);
    fileDates = cell(size(rawDataFiles, 1), 1);
    
    for blockThreeProg = 1:size(rawDataFiles, 1)
        filename = rawDataFiles(blockThreeProg, :);
        load(filename);
        
        % Get the date and file identifier for the data to be saved with each resting event
        [~, ~, fileDate, fileID] = GT_GetFileInfo(filename);
        
        % Expected number of samples for element of dataType
        downSampled_Fs = RawData.GT_SleepAnalysis.downSampled_Fs;
        expectedLength = 300*downSampled_Fs;
        
        % Get information about periods of rest from the loaded file
        trialEventTimes = RawData.GT_SleepAnalysis.Flags.rest.eventTime';
        trialPuffDistances = RawData.GT_SleepAnalysis.Flags.rest.puffDistance;
        trialDurations = RawData.GT_SleepAnalysis.Flags.rest.duration';
        
        % Initialize cell array for all periods of rest from the loaded file
        trialRestVals = cell(size(trialEventTimes'));
        for tET = 1:length(trialEventTimes)
            % Extract the whole duration of the resting event. Coerce the
            % start index to values above 1 to preclude rounding to 0.
            startInd = max(floor(trialEventTimes(tET)*downSampled_Fs), 1);
            
            % Convert the duration from seconds to samples.
            dur = round(trialDurations(tET)*downSampled_Fs);
            
            % Get ending index for data chunk. If event occurs at the end of
            % the trial, assume animal whisks as soon as the trial ends and
            % give a 200ms buffer.
            stopInd = min(startInd + dur, expectedLength - round(0.2*downSampled_Fs));
            
            % Extract data from the trial and add to the cell array for the current loaded file
            try
                trialRestVals{tET} = RawData.GT_SleepAnalysis.(dataTypes{dT})(:, startInd:stopInd);
            catch
                trialRestVals{tET} = RawData.barrels.(dataTypes{dT})(:, startInd:stopInd);
            end
        end
        % Add all periods of rest to a cell array for all files
        restVals{blockThreeProg} = trialRestVals';
        
        % Transfer information about resting periods to the new structure
        eventTimes{blockThreeProg} = trialEventTimes';
        durations{blockThreeProg} = trialDurations';
        puffDistances{blockThreeProg} = trialPuffDistances';
        fileIDs{blockThreeProg} = repmat({fileID}, 1, length(trialEventTimes));
        fileDates{blockThreeProg} = repmat({fileDate}, 1, length(trialEventTimes));
    end
    
    GT_AnalysisInfo.GT_SleepAnalysis.RestData.(dataTypes{dT}).data = [restVals{:}]';
    GT_AnalysisInfo.GT_SleepAnalysis.RestData.(dataTypes{dT}).eventTimes = cell2mat(eventTimes);
    GT_AnalysisInfo.GT_SleepAnalysis.RestData.(dataTypes{dT}).durations = cell2mat(durations);
    GT_AnalysisInfo.GT_SleepAnalysis.RestData.(dataTypes{dT}).puffDistances = [puffDistances{:}]';
    GT_AnalysisInfo.GT_SleepAnalysis.RestData.(dataTypes{dT}).fileIDs = [fileIDs{:}]';
    GT_AnalysisInfo.GT_SleepAnalysis.RestData.(dataTypes{dT}).fileDates = [fileDates{:}]';
    GT_AnalysisInfo.GT_SleepAnalysis.RestData.(dataTypes{dT}).samplingRate = downSampled_Fs;
end

end
