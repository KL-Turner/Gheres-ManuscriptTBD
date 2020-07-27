function [decData,decFileIDs,decDurations,decEventTimes] = KeepSleepData_GheresTBD(data,fileIDs,durations,eventTimes,ScoringResults,score)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: Remove resting events from the various fields that aren't in the manual selection
%________________________________________________________________________________________________________________________

trialDuration_sec = 900;   % sec
offset = 0.5;   % sec
x = 1;
decData = [];
decFileIDs = [];
decDurations = [];
decEventTimes = [];
for a = 1:size(data,1)
    fileID = fileIDs{a,1};
    startTime = floor(eventTimes(a,1));
    endTime = startTime + durations(a,1);
    scoringLabels = [];
    for b = 1:length(ScoringResults.fileIDs)
        sleepFileID = ScoringResults.fileIDs{b,1};
        if strcmp(fileID,sleepFileID) == true
            scoringLabels = ScoringResults.labels{b,1};
        end
    end
    sleepBinNumber = ceil(startTime/5);
    eventState = scoringLabels(sleepBinNumber);
    % check that the event falls within appropriate bounds
    if strcmp(eventState,score) == true
        if startTime >= offset && endTime <= (trialDuration_sec - offset)
            if iscell(data) == true
                decData{x,1} = data{a,1}; %#ok<*AGROW>
            else
                decData(x,:) = data(a,:);
            end
            decFileIDs{x,1} = fileIDs{a,1};
            decDurations(x,1) = durations(a,1);
            decEventTimes(x,1) = eventTimes(a,1);
            x = x + 1;
        end
    end
end

end

