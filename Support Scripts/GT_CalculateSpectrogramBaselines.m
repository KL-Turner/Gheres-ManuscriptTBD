function [GT_AnalysisInfo] = GT_CalculateSpectrogramBaselines(GT_AnalysisInfo, SpectrogramData)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Uses the indeces of resting events to pull and average the corresponding power of each frequency bin.
%            This function pulls the power in all frequency bins accross time from for each resting event. Each unique
%            resting event is then averaged through time. These averaged events are then averaged per individual five
%            minute trial. These five minute trials are then averaged together to form the average for the day.
%
%            full event (> 10 seconds) -> avg event -> avg events in trial -> avg trials in day
%________________________________________________________________________________________________________________________
%
%   Inputs: GT_AnalysisInfo.mat (struct) summary structure of sleep scoring analysis.
%           SpectrogramData.mat (struct) containing the T,F,S data for one and five seconds of each single trial.
%
%   Outputs: GT_AnalysisInfo.mat (struct) with the spectrogram baselines added to the baselines field.
%________________________________________________________________________________________________________________________

% List of unique files from the baselines folder, i.e. the files already used for other baseline calculations.
% It is assumed that these files meet the requirements (such as first 30 minutes of imaging).
restFileList = unique(GT_AnalysisInfo.baselineFileInfo.fileIDs);

% Obtain the spectrogram data from all (and only) the unique resting files.
for a = 1:length(restFileList)
    fileID = restFileList{a, 1};
    % Loop through the each unique file name and compare it with the SpectrogramData file names. If the name
    % matches, pull out the data.
    for b = 1:length(SpectrogramData.FileIDs)
        if strcmp(fileID, SpectrogramData.FileIDs{b, 1})
            S1 = SpectrogramData.OneSec.S{b, 1};
            T1 = SpectrogramData.OneSec.T{b, 1};
            F1 = SpectrogramData.OneSec.F{b, 1};
            S5 = SpectrogramData.FiveSec.S{b, 1};
            T5 = SpectrogramData.FiveSec.T{b, 1};
            F5 = SpectrogramData.FiveSec.F{b, 1};
        end
    end
    % Store the data from each unique rest file in a cell array.
    Neural_restS1{a, 1} = S1;
    Neural_restT1{a, 1} = T1;
    Neural_restF1{a, 1} = F1;
    Neural_restS5{a, 1} = S5;
    Neural_restT5{a, 1} = T5;
    Neural_restF5{a, 1} = F5;
end

% Loop through each unique rest file again now that we have the corresponding data.
for a = 1:length(restFileList)
    fileID = restFileList{a, 1};
    strDay = GT_ConvertDate(fileID(1:6));
    % Get the corresponding data for the individual file
    S1_data = Neural_restS1{a, 1};
    S5_data = Neural_restS5{a, 1};
    % Find the length of the spectrogram
    s1Length = size(S1_data, 2);
    s5Length = size(S5_data, 2);
    % Determine the bin size necessary for the length of the spectrogram to be divided into 300 seconds
    % as evenly as possible. Compare this lower fs to the original sampling rate that the baseline resting time 
    % indeces for each resting file correspond to.
    binSize1 = ceil(s1Length/300);
    binSize5 = ceil(s5Length/300);
    samplingRate = 30;
    samplingDiff1 = samplingRate / binSize1;
    samplingDiff5 = samplingRate / binSize5;  
    S1_trialRest = [];
    S5_trialRest = [];
    % Cycle through each rbaseline file ID
    for b = 1:length(GT_AnalysisInfo.baselineFileInfo.fileIDs)
        restFileID = GT_AnalysisInfo.baselineFileInfo.fileIDs{b, 1};
        % COmpare the ID to each resting file to pull out the corresponding event times and durations of resting periods.
        if strcmp(fileID, restFileID)
            restDuration1 = floor(floor(GT_AnalysisInfo.baselineFileInfo.durations(b, 1)*samplingRate)/samplingDiff1);
            restDuration5 = floor(floor(GT_AnalysisInfo.baselineFileInfo.durations(b, 1)*samplingRate)/samplingDiff5);
            startTime1 = floor(floor(GT_AnalysisInfo.baselineFileInfo.eventTimes(b, 1)*samplingRate)/samplingDiff1);
            startTime5 = floor(floor(GT_AnalysisInfo.baselineFileInfo.eventTimes(b, 1)*samplingRate)/samplingDiff5);
            % Pull out the data from the spectrogram that corresponds to the time index of the resting event with the
            % lower sampling rate. There's a little bit of 'negotiating' here with the rounding and uneven samples.
            % The try/catch statement helps control for edge effects of occassionally uneven points.
            try
                S1_single_rest = S1_data(:, (startTime1:(startTime1 + restDuration1)));
                S5_single_rest = S5_data(:, (startTime5:(startTime5 + restDuration5)));
            catch
                S1_single_rest = S1_data(:, end - restDuration1:end);
                S5_single_rest = S5_data(:, end - restDuration5:end);
            end
            S1_trialRest = [S1_single_rest, S1_trialRest];
            S5_trialRest = [S5_single_rest, S5_trialRest];
        end
    end
    % Average the individual resting events per day and store.
    S_trialAvg1 = mean(S1_trialRest, 2);
    S_trialAvg5 = mean(S5_trialRest, 2);
    trialRestData.([strDay '_' fileID]).OneSec.S_avg = S_trialAvg1;
    trialRestData.([strDay '_' fileID]).FiveSec.S_avg = S_trialAvg5;
end

fields = fieldnames(trialRestData);
uniqueDays = GT_GetUniqueDays(GT_AnalysisInfo.baselineFileInfo.fileIDs);

% Now, we want to average the individual rest epochs from each trial together.
for day = 1:length(uniqueDays)
    x = 1;
    for field = 1:length(fields)
        if strcmp(fields{field}(7:12), uniqueDays{day})
            stringDay = GT_ConvertDate(uniqueDays{day});
            S_avgs.OneSec.(stringDay){x, 1} = trialRestData.(fields{field}).OneSec.S_avg;
            S_avgs.FiveSec.(stringDay){x, 1} = trialRestData.(fields{field}).FiveSec.S_avg;
            x = x + 1;
        end
    end
end

% Finally, we want to average the individual trial's resting values for the entire day.
dayFields = fieldnames(S_avgs.OneSec);
for day = 1:length(dayFields)
    dayVals1 = [];
    dayVals5 = [];
    for x = 1:length(S_avgs.OneSec.(dayFields{day}))
        dayVals1 = [dayVals1, S_avgs.OneSec.(dayFields{day}){x, 1}];
        dayVals5 = [dayVals5, S_avgs.FiveSec.(dayFields{day}){x, 1}];
    end
    GT_AnalysisInfo.baselines.Spectrograms.OneSec.(dayFields{day}) = mean(dayVals1, 2);
    GT_AnalysisInfo.baselines.Spectrograms.FiveSec.(dayFields{day}) = mean(dayVals5, 2);
end

end
