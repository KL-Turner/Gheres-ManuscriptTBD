function [GT_AnalysisInfo] = GT_MainScript()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: [1] Analyze each RawData file to bandpass filter and downsample the various analog signals
%            [2] Categorize the animal's behavior using ball velocity.
%            [3] Find resting epochs.
%            [4] Calculate the neural spectrogram for each file.
%            [5] Determine resting baseline values using the animal's behavior flags.
%            [6] Normalize data by resting baselines.
%            [7] Run sleep scoring analysis functions.
%            [8] Create single trial summary figures if prompted.
%________________________________________________________________________________________________________________________
%
%   Inputs: None
%
%   Outputs: GT_AnalysisInfo containing a structure containing the sleep data from the GUI inputs.
%
%   Last Revised: March 5th, 2019
%________________________________________________________________________________________________________________________

%% BLOCK PURPOSE: [0] Set parameters to be used for sleep scoring characterization
clear 
clc
rawDataDirectory = dir('*_RawData.mat');
rawDataFiles = char({rawDataDirectory.name}');
animalFile = rawDataFiles(1, :);
[animalID, ~, ~, ~] = GT_GetFileInfo(animalFile);

analysisInfo = dir('*_GT_AnalysisInfo.mat');
if ~isempty(analysisInfo)
    load(analysisInfo.name);
else
    GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData = false;
    GT_AnalysisInfo.analysisChecklist.GT_CategorizeData = false;
    GT_AnalysisInfo.analysisChecklist.GT_CreateTrialSpectrograms = false;
    GT_AnalysisInfo.analysisChecklist.GT_CalculateRestingBaselines = false;
end

if ~isempty(analysisInfo)
    load(analysisInfo.name);
else
    GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData = false;
    GT_AnalysisInfo.analysisChecklist.GT_CategorizeData = false;
    GT_AnalysisInfo.analysisChecklist.GT_CreateTrialSpectrograms = false;
    GT_AnalysisInfo.analysisChecklist.GT_CalculateRestingBaselines = false;
end

GT_multiWaitbar('CloseAll');
clear global buttonState
global buttonState
buttonState = 0;

% GUI for parameter settings
[updatedGUI] = GT_ScoringParameters;
while buttonState == 0
    drawnow()
    if buttonState == 1
        guiResults = guidata(updatedGUI);
        guiParams.awakeDuration = str2double(guiResults.awakeDuration.String);
        guiParams.minSleepTime = str2double(guiResults.minSleepTime.String);
        guiParams.neurToggle = guiResults.neurToggle.Value;
        guiParams.ballToggle = guiResults.ballToggle.Value;
        guiParams.hrToggle = guiResults.hrToggle.Value;
        guiParams.neurCrit = str2double(guiResults.neurCrit.String);
        guiParams.ballCrit = str2double(guiResults.ballCrit.String);
        guiParams.hrCrit = str2double(guiResults.hrCrit.String);
        guiParams.scoringID = guiResults.scoringID.String;
        guiParams.saveFigsToggle = guiResults.saveFigsToggle.Value;
        guiParams.saveStructToggle = guiResults.saveStructToggle.Value;
        guiParams.rerunProcData = guiResults.rerunProcData.Value;
        guiParams.rerunCatData = guiResults.rerunCatData.Value;
        guiParams.rerunSpecData = guiResults.rerunSpecData.Value;
        guiParams.rerunBase = guiResults.rerunBase.Value;
        closereq
        break;
    end
    ...
end

% Handle invalid inputs to GUI
[Error] = GT_CheckGUIVals(guiParams);
if Error == true
    GT_MessageAlert('Invalid', guiParams)
    return;
end

% Progress Bars
GT_multiWaitbar('Processing RawData Files', 0, 'Color', [0.9 0.8 0.2]);
GT_multiWaitbar('Categorizing Behavioral Data', 0, 'Color', [0.4 0.1 0.5]);
GT_multiWaitbar('Finding Resting Epochs (Data Types)', 0, 'Color', [0.8 0.4 0.9]);
GT_multiWaitbar('Finding Resting Epochs (Files per Data Type)', 0, 'Color', [0.1 0.5 0.8]);
GT_multiWaitbar('Creating Neural Spectrograms', 0, 'Color', [0.8 0.4 0.9]);
GT_multiWaitbar('Calculating Resting Baselines', 0, 'Color', [0.4 0.1 0.5]);
GT_multiWaitbar('Normalizing Data by Baselines', 0, 'Color', [0.8 0.4 0.9]);
GT_multiWaitbar('Running Sleep Scoring Analysis (part 1)', 0, 'Color', [0.8 0.4 0.9]);
GT_multiWaitbar('Running Sleep Scoring Analysis (part 2)', 0, 'Color', [0.4 0.1 0.5]);

if guiParams.saveFigsToggle == true
    GT_multiWaitbar('Generating Single Trial Summary Figures', 0, 'Color', [0.9 0.8 0.2]);
end

%% BLOCK PURPOSE: [1] Analyze each RawData file to bandpass filter and downsample the various analog signals.
if ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_ProcessRawData') || GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData == false || guiParams.rerunProcData == true 
    for blockOneProg = 1:size(rawDataFiles, 1)
        rawDataFile = rawDataFiles(blockOneProg, :);
        [GT_AnalysisInfo] = GT_ProcessRawData(rawDataFile, GT_AnalysisInfo);
        GT_multiWaitbar('Processing RawData Files', blockOneProg/size(rawDataFiles, 1));
    end
    GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData = true;
    save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo');
else
    for blockOneProg = 1:size(rawDataFiles, 1)
        GT_multiWaitbar('Processing RawData Files', blockOneProg/size(rawDataFiles, 1));
        pause(0.05)
    end
end

%% BLOCK PURPOSE: [2] Categorize the animal's behavior using ball velocity.
if ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_CategorizeData') || GT_AnalysisInfo.analysisChecklist.GT_CategorizeData == false || guiParams.rerunCatData == true 
    for blockTwoProg = 1:size(rawDataFiles, 1)
        rawDataFile = rawDataFiles(blockTwoProg, :);
        [GT_AnalysisInfo] = GT_CategorizeData(rawDataFile, GT_AnalysisInfo);
        GT_multiWaitbar('Categorizing Behavioral Data', blockTwoProg/size(rawDataFiles, 1));
    end
else
    for blockTwoProg = 1:size(rawDataFiles, 1)
        GT_multiWaitbar('Categorizing Behavioral Data', blockTwoProg/size(rawDataFiles, 1));
        pause(0.05)
    end
end

%% BLOCK PURPOSE: [3] Find resting epochs. (This block is programmatically coupled with Block [2])
% To properly utilize the progress bars, this function's code has been pasted into this block. 
dataTypes = {'CBVrefl_barrels', 'deltaBandPower', 'thetaBandPower', 'gammaBandPower'};
if ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_CategorizeData') || GT_AnalysisInfo.analysisChecklist.GT_CategorizeData == false || guiParams.rerunCatData == true
    for blockThreeProgA = 1:length(dataTypes)
        GT_multiWaitbar('Finding Resting Epochs (Data Types)', blockThreeProgA/length(dataTypes));
        restVals = cell(size(rawDataFiles, 1), 1);
        eventTimes = cell(size(rawDataFiles, 1), 1);
        durations = cell(size(rawDataFiles, 1), 1);
        puffDistances = cell(size(rawDataFiles, 1), 1);
        fileIDs = cell(size(rawDataFiles, 1), 1);
        fileDates = cell(size(rawDataFiles, 1), 1);
        
        for blockThreeProgB = 1:size(rawDataFiles, 1)
            filename = rawDataFiles(blockThreeProgB, :);
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
                    trialRestVals{tET} = RawData.GT_SleepAnalysis.(dataTypes{blockThreeProgA})(:, startInd:stopInd);
                catch
                    trialRestVals{tET} = RawData.barrels.(dataTypes{blockThreeProgA})(:, startInd:stopInd);
                end
            end
            % Add all periods of rest to a cell array for all files
            restVals{blockThreeProgB} = trialRestVals';
            
            % Transfer information about resting periods to the new structure
            eventTimes{blockThreeProgB} = trialEventTimes';
            durations{blockThreeProgB} = trialDurations';
            puffDistances{blockThreeProgB} = trialPuffDistances';
            fileIDs{blockThreeProgB} = repmat({fileID}, 1, length(trialEventTimes));
            fileDates{blockThreeProgB} = repmat({fileDate}, 1, length(trialEventTimes));
            GT_multiWaitbar('Finding Resting Epochs (Files per Data Type)', blockThreeProgB/size(rawDataFiles,1));
        end
        
        GT_AnalysisInfo.RestData.(dataTypes{blockThreeProgA}).data = [restVals{:}]';
        GT_AnalysisInfo.RestData.(dataTypes{blockThreeProgA}).eventTimes = cell2mat(eventTimes);
        GT_AnalysisInfo.RestData.(dataTypes{blockThreeProgA}).durations = cell2mat(durations);
        GT_AnalysisInfo.RestData.(dataTypes{blockThreeProgA}).puffDistances = [puffDistances{:}]';
        GT_AnalysisInfo.RestData.(dataTypes{blockThreeProgA}).fileIDs = [fileIDs{:}]';
        GT_AnalysisInfo.RestData.(dataTypes{blockThreeProgA}).fileDates = [fileDates{:}]';
        GT_AnalysisInfo.RestData.(dataTypes{blockThreeProgA}).samplingRate = downSampled_Fs;
    end
    GT_AnalysisInfo.analysisChecklist.GT_CategorizeData = true;
    save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo');
else
    for blockThreeProgB = 1:size(rawDataFiles, 1)
        GT_multiWaitbar('Finding Resting Epochs (Data Types)', blockThreeProgB/size(rawDataFiles, 1));
        GT_multiWaitbar('Finding Resting Epochs (Files per Data Type)', blockThreeProgB/size(rawDataFiles, 1));
        pause(0.05)
    end
end

%% BLOCK PURPOSE: [4] Calculate the neural spectrogram for each file.
% To properly utilize the progress bars, this function's code has been pasted into this block. 
if ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_CreateTrialSpectrograms') || GT_AnalysisInfo.analysisChecklist.GT_CreateTrialSpectrograms == false || guiParams.rerunSpecData == true 
    for blockFourProg = 1:size(rawDataFiles, 1)
        rawDataFile = rawDataFiles(blockFourProg, :);
        [~, ~, ~, fileID] = GT_GetFileInfo(rawDataFile);
        load(rawDataFile);
        RawNeuro = RawData.Neuro;
        
        % Remove 60 Hz noise
        w0 = 60/(RawData.an_fs/2);  bw = w0/35;
        [num,den] = iirnotch(w0, bw);
        filtRawNeuro = filtfilt(num, den, RawNeuro);
        
        % Spectrogram parameters
        params.tapers = [5 9];
        params.Fs = RawData.an_fs;
        params.fpass = [0.1 100];
        movingwin1 = [1 1/5];
        movingwin5 = [5 1/5]; 
        [Neural_S1, Neural_T1, Neural_F1] = mtspecgramc(filtRawNeuro, movingwin1, params);
        [Neural_S5, Neural_T5, Neural_F5] = mtspecgramc(filtRawNeuro, movingwin5, params);
 
        SpectrogramData.FiveSec.S{blockFourProg, 1} = Neural_S5';
        SpectrogramData.FiveSec.T{blockFourProg, 1}  = Neural_T5;
        SpectrogramData.FiveSec.F{blockFourProg, 1}  = Neural_F5;
        SpectrogramData.OneSec.S{blockFourProg, 1} = Neural_S1';
        SpectrogramData.OneSec.T{blockFourProg, 1} = Neural_T1;
        SpectrogramData.OneSec.F{blockFourProg, 1} = Neural_F1;
        SpectrogramData.FileIDs{blockFourProg, 1} = fileID;
        SpectrogramData.Notes.params = params;
        SpectrogramData.Notes.movingwin5 = movingwin5;
        SpectrogramData.Notes.movingwin1 = movingwin1;
        GT_multiWaitbar('Creating Neural Spectrograms', blockFourProg/size(rawDataFiles, 1));
    end   
    save([animalID '_GT_SpectrogramData'], 'SpectrogramData', '-v7.3');
    GT_AnalysisInfo.analysisChecklist.GT_CreateTrialSpectrograms = true;
    save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo');
else
    for blockFourProg = 1:size(rawDataFiles, 1)
        GT_multiWaitbar('Creating Neural Spectrograms', blockFourProg/size(rawDataFiles, 1));
        pause(0.05)
    end
end

%% BLOCK PURPOSE: [5] Determine resting baseline values using the animal's behavior flags.
if ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_CalculateRestingBaselines') || GT_AnalysisInfo.analysisChecklist.GT_CalculateRestingBaselines == false || guiParams.rerunBaseData == true 
    [GT_AnalysisInfo] = GT_CalculateRestingBaselines(GT_AnalysisInfo, guiParams);
    [GT_AnalysisInfo] = GT_CalculateSpectrogramBaselines(GT_AnalysisInfo, SpectrogramData);
    for blockFiveProg = 1:size(rawDataFiles, 1)
        GT_multiWaitbar('Calculating Resting Baselines', blockFiveProg/size(rawDataFiles, 1));
        pause(0.05)
    end
    save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo');
else
    for blockFiveProg = 1:size(rawDataFiles, 1)
        GT_multiWaitbar('Calculating Resting Baselines', blockFiveProg/size(rawDataFiles, 1));
        pause(0.05)
    end 
end

%% BLOCK PURPOSE: [6] Normalize data by resting baselines. (This block is programmatically coupled with Block [5])
if ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_CalculateRestingBaselines') || GT_AnalysisInfo.analysisChecklist.GT_CalculateRestingBaselines == false || guiParams.rerunBaseData == true 
    for blockSixProg = 1:size(rawDataFiles, 1)
        rawDataFile = rawDataFiles(blockSixProg, :);
        [GT_AnalysisInfo] = GT_CategorizeData(rawDataFile, GT_AnalysisInfo);
        GT_multiWaitbar('Calculating Resting Baselines', blockSixProg/size(rawDataFiles, 1));
    end
    GT_AnalysisInfo.analysisChecklist.GT_CalculateRestingBaselines = true;
    save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo');
else
    for blockSixProg = 1:size(rawDataFiles, 1)
        GT_multiWaitbar('Calculating Resting Baselines', blockSixProg/size(rawDataFiles, 1));
        pause(0.05)
    end
end

%% BLOCK PURPOSE: [7] Run sleep scoring analysis functions.
% for blockTwoProg = 1:size(rawDataFiles, 1)
%     rawDataFile = rawDataFiles(blockTwoProg, :);
%     [GT_AnalysisInfo] = GT_CategorizeData(rawDataFile, GT_AnalysisInfo);
%     GT_multiWaitbar('Categorizing Behavioral Data', blockTwoProg/size(rawDataFiles, 1));
% end
% GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData = true;
% save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo');

%% BLOCK PURPOSE: [8] Create single trial summary figures if prompted.
if guiParams.saveFigsToggle == true
    for blockSixProg = 1:size(rawDataFiles, 1)
        rawDataFile = rawDataFiles(blockSixProg, :);
        GT_CreateSingleTrialFigs(rawDataFile, GT_AnalysisInfo);
        GT_multiWaitbar('Generating Single Trial Summary Figures', blockSixProg/size(rawDataFiles, 1));
    end
end

%% Results
GT_MessageAlert('Complete');
GT_multiWaitbar('CloseAll');

end

