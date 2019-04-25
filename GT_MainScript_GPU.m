function [GT_AnalysisInfo] = GT_MainScript_GPU()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: [0] Set parameters to be used for sleep scoring characterization.
%            [1] Analyze each RawData file to appropriately filter and downsample the various analog signals.
%            [2] Categorize the animal's behavior, in this case that is ball (running) velocity.
%            [3] Find resting epochs during periods of quiescence.
%            [4] Calculate the neural spectrogram for each file.
%            [5] Determine resting baseline values using the animal's behavior flags.
%            [6] Normalize data by resting baselines.
%            [7] Run sleep scoring analysis functions based on GUI parameters.
%            [8] Create single trial summary figures if prompted.
%________________________________________________________________________________________________________________________
%
%   Inputs: None. This function can be called by another script/function or run independently.
%
%   Outputs: GT_AnalysisInfo containing a structure with the sleep data from the GUI inputs.
%
%   Last Revised: March 8th, 2019
%________________________________________________________________________________________________________________________

%% BLOCK PURPOSE: [0] Set parameters to be used for sleep scoring characterization.
boom;   % function set to clear, clc, close all

id = 'signal:filtfilt:ParseSOS';
warning('off', id)

% Pull a list (m by n character array) corresponding to all _rawdata.mat files in the current directory.
rawDataDirectory = dir('*_RawData.mat');
rawDataFiles = char({rawDataDirectory.name}');
animalFile = rawDataFiles(1, :);   % Use the first file in the list of _rawdata.mat files.
[animalID, hem, ~, ~] = GT_GetFileInfo(animalFile);   % Pull the animal's ID tag and imaged hemisphere.

% Check if this specific animal's AnalysisInfo file already exists in the directory. If it does, load it and this current
% iteration will be added to it under a unique scoring ID. If it does not exist, create an empty one and set the checklist to false.
analysisInfo = dir('*_GT_AnalysisInfo.mat');
if ~isempty(analysisInfo)
    load(analysisInfo.name);
else
    GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData = false;
    GT_AnalysisInfo.analysisChecklist.GT_CategorizeData = false;
    GT_AnalysisInfo.analysisChecklist.GT_CreateTrialSpectrograms = false;
    GT_AnalysisInfo.analysisChecklist.GT_CalculateRestingBaselines = false;
end

% Check if this animal's Spectrograms have already been analyzed. If they have, load it. If not, set to empty.
specDataFile = dir('*_GT_SpectrogramData.mat');
if ~isempty(specDataFile)
    load(specDataFile.name);
end

% Close any left-over loading bars from prior analysis. Initiate a global variable for the GUI's button state (GO button)
% and set its default value to off.
GT_multiWaitbar('CloseAll');
clear global buttonState
global buttonState
buttonState = 0;

% Open the GUI and prompt user for the analysis' sleep scoring parameters. For more info, check the README.txt.
% The GUI will stay open until the GO. button is pressed. While the GUI is waiting for the buttonState change, it
% constantly updates the output values.
[updatedGUI] = GT_ScoringParameters;
while buttonState == 0
    drawnow()
    if buttonState == 1
        % When GO. button is pressed, gather the GUI's outputs and save them into a guiParams struct.
        guiResults = guidata(updatedGUI);
        guiParams.awakeDuration = str2double(guiResults.awakeDuration.String);
        guiParams.minSleepTime = str2double(guiResults.minSleepTime.String);
        guiParams.neurToggle = guiResults.neurToggle.Value;
        guiParams.ballToggle = guiResults.ballToggle.Value;
        guiParams.hrToggle = guiResults.hrToggle.Value;
        guiParams.neurCrit = str2double(guiResults.neurCrit.String);
        guiParams.ballCrit = str2double(guiResults.ballCrit.String);
        guiParams.hrCrit = str2double(guiResults.hrCrit.String);
        guiParams.scoringID = strrep(guiResults.scoringID.String, ' ', '_');
        guiParams.saveFigsToggle = guiResults.saveFigsToggle.Value;
        guiParams.saveStructToggle = guiResults.saveStructToggle.Value;
        guiParams.rerunProcData = guiResults.rerunProcData.Value;
        guiParams.rerunCatData = guiResults.rerunCatData.Value;
        guiParams.rerunSpecData = guiResults.rerunSpecData.Value;
        guiParams.rerunBase = guiResults.rerunBase.Value;
        closereq
        break;   % Leave the while loop.
    end
    ...
end

% TEMPORARY - Override GUI's baseline/categorize data toggle buttons. These analysis runs quickly as-is, and the current
% version of this script is not able to catch changes in the awakeDuration variable that influences these categorizations.
guiParams.rerunBase = true;
guiParams.rerunCatData = true;

% Handle invalid inputs to GUI by ending the function and popping an error message.
[Error] = GT_CheckGUIVals(guiParams);
if Error == true
    GT_MessageAlert('Invalid', GT_AnalysisInfo, guiParams)
    return;
end

% Create a set of loading bars to inform the user of the analysis' progress. A set of brief delays (pause) are used to
% smoothen out the initial pop-up display and loading of the bars.
pause(0.25)
GT_multiWaitbar('Processing RawData Files', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);
GT_multiWaitbar('Categorizing Behavioral Data', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);
GT_multiWaitbar('Finding Resting Epochs (Data Types)', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);
GT_multiWaitbar('Finding Resting Epochs (Files per Data Type)', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);
GT_multiWaitbar('Creating Neural Spectrograms', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);
GT_multiWaitbar('Calculating Resting Baselines', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);
GT_multiWaitbar('Normalizing Data by Baselines', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);
GT_multiWaitbar('Running Sleep Scoring Analysis (part 1)', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);
GT_multiWaitbar('Running Sleep Scoring Analysis (part 2)', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);
if guiParams.saveFigsToggle == true
    GT_multiWaitbar('Generating Single Trial Summary Figures', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25)
end

%% BLOCK PURPOSE: [1] Analyze each RawData file to appropriately filter and downsample the various analog signals.
% If this block's results are not a saved field OR this block has never been ran OR the user has prompted to re-run... 
if ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_ProcessRawData') || GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData == false || guiParams.rerunProcData == true 
    for blockOneProg = 1:size(rawDataFiles, 1)
        rawDataFile = rawDataFiles(blockOneProg, :);
        if blockOneProg==1
            GT_AnalysisInfo.thresholds.EMGData(1:size(rawDataFiles, 1),(1:(300*20000)))=NaN;
            GT_AnalysisInfo.thresholds.BallData(1:size(rawDataFiles, 1),(1:(300*20000)))=NaN;
            GT_AnalysisInfo.thresholds.count=1;
        end
        % Feed the function one file at a time along with the summary structure.
        [GT_AnalysisInfo] = GT_ProcessRawData_GPU(rawDataFile, GT_AnalysisInfo);
        GT_multiWaitbar('Processing RawData Files', blockOneProg/size(rawDataFiles, 1));   % Update progress bar.
    end
    % Find threshold EMG data to identify periods of atonia
    [GT_AnalysisInfo]=GT_FindAtonia(GT_AnalysisInfo);
    % When finished with each file, save the summary structure and set the checklist for this block to true.
    GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData = true;
    save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo','-v7.3');
else
    % If this analysis has already been ran and this is a subsequent iteration...
    for blockOneProg = 1:size(rawDataFiles, 1)
        % Quickly cycle through the progress bar for ... visual satisfaction.
        GT_multiWaitbar('Processing RawData Files', blockOneProg/size(rawDataFiles, 1)); pause(0.1)
    end
end

% Pull a list (m by n character array) corresponding to all _SleepScoringData.mat files in the current directory.
% These files are created by GT_ProcessRawData.m function. Whether that block has just finished running or was skipped
% because the analysis has already previously ran, load in the filenames of the SleepScoringData.mat structures.
sleepScoringDataDirectory = dir('*_SleepScoringData.mat');
sleepScoringDataFiles = char({sleepScoringDataDirectory.name}');

%% BLOCK PURPOSE: [2] Categorize the animal's behavior, in this case that is ball (running) velocity.
% If this block's results are not a saved field OR this block has never been ran OR the user has prompted to re-run... 
if ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_CategorizeData') || GT_AnalysisInfo.analysisChecklist.GT_CategorizeData == false || guiParams.rerunCatData == true 
    for blockTwoProg = 1:size(sleepScoringDataFiles, 1)
        sleepScoringDataFile = sleepScoringDataFiles(blockTwoProg, :);
         Downsampled_EMG=logical(resample(double(GT_AnalysisInfo.thresholds.EMG_Atonia(blockTwoProg,:)),30,20000));
        % Feed the function one file at a time along with the summary structure.
        GT_CategorizeData(sleepScoringDataFile,Downsampled_EMG);
        GT_multiWaitbar('Categorizing Behavioral Data', blockTwoProg/size(sleepScoringDataFiles, 1));   % Update progress bar.
    end
else
    % If this analysis has already been ran and this is a subsequent iteration...
    for blockTwoProg = 1:size(sleepScoringDataFiles, 1)
        % Quickly cycle through the progress bar for ... visual satisfaction.
        GT_multiWaitbar('Categorizing Behavioral Data', blockTwoProg/size(sleepScoringDataFiles, 1)); pause(0.1);
    end
end

%% BLOCK PURPOSE: [3] Find resting epochs during periods of quiescence. (This block is programmatically coupled with Block [2])
% To properly utilize the progress bars, the original function's code has been pasted into this block. 
% If this block's results are not a saved field OR this block has never been ran OR the user has prompted to re-run... 
dataTypes = {'CBV', 'deltaBandPower', 'thetaBandPower', 'gammaBandPower','ripplePower','spindlePower'};
if ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_CategorizeData') || GT_AnalysisInfo.analysisChecklist.GT_CategorizeData == false || guiParams.rerunCatData == true
    for blockThreeProgA = 1:length(dataTypes)
        GT_multiWaitbar('Finding Resting Epochs (Data Types)', blockThreeProgA/length(dataTypes));   % Update progress bar.
        restVals = cell(size(sleepScoringDataFiles, 1), 1);
        eventTimes = cell(size(sleepScoringDataFiles, 1), 1);
        durations = cell(size(sleepScoringDataFiles, 1), 1);
        puffDistances = cell(size(sleepScoringDataFiles, 1), 1);
        fileIDs = cell(size(sleepScoringDataFiles, 1), 1);
        fileDates = cell(size(sleepScoringDataFiles, 1), 1);
        
        for blockThreeProgB = 1:size(sleepScoringDataFiles, 1)
            sleepScoringDataFile = sleepScoringDataFiles(blockThreeProgB, :);
            load(sleepScoringDataFile);
            % Get the date and file identifier for the data to be saved with each resting event
            [~, ~, fileDate, fileID] = GT_GetFileInfo(sleepScoringDataFile);
            
            % Expected number of samples for element of dataType
            downSampled_Fs = SleepScoringData.downSampled_Fs;
            expectedLength = 300*downSampled_Fs;
            
            % Get information about periods of rest from the loaded file
            trialEventTimes = SleepScoringData.Flags.rest.eventTime';
            trialPuffDistances = SleepScoringData.Flags.rest.puffDistance;
            trialDurations = SleepScoringData.Flags.rest.duration';
            
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
                    trialRestVals{tET} = SleepScoringData.(dataTypes{blockThreeProgA})(:, startInd:stopInd);
                catch
                    trialRestVals{tET} = SleepScoringData.(dataTypes{blockThreeProgA})(:, startInd:stopInd);
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
            GT_multiWaitbar('Finding Resting Epochs (Files per Data Type)', blockThreeProgB/size(rawDataFiles,1));   % Update progress bar.
        end
        
        GT_AnalysisInfo.RestData.(dataTypes{blockThreeProgA}).data = [restVals{:}]';
        GT_AnalysisInfo.RestData.(dataTypes{blockThreeProgA}).eventTimes = cell2mat(eventTimes);
        GT_AnalysisInfo.RestData.(dataTypes{blockThreeProgA}).durations = cell2mat(durations);
        GT_AnalysisInfo.RestData.(dataTypes{blockThreeProgA}).puffDistances = [puffDistances{:}]';
        GT_AnalysisInfo.RestData.(dataTypes{blockThreeProgA}).fileIDs = [fileIDs{:}]';
        GT_AnalysisInfo.RestData.(dataTypes{blockThreeProgA}).fileDates = [fileDates{:}]';
        GT_AnalysisInfo.RestData.(dataTypes{blockThreeProgA}).samplingRate = downSampled_Fs;
    end
    % When finished with each file, save the summary structure and set the checklist for this block to true.
    GT_AnalysisInfo.analysisChecklist.GT_CategorizeData = true;
    save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo','-v7.3');
else
    % If this analysis has already been ran and this is a subsequent iteration...
    for blockThreeProgB = 1:size(sleepScoringDataFiles, 1)
        % Quickly cycle through the progress bar for ... visual satisfaction.
        GT_multiWaitbar('Finding Resting Epochs (Data Types)', blockThreeProgB/size(sleepScoringDataFiles, 1));
        GT_multiWaitbar('Finding Resting Epochs (Files per Data Type)', blockThreeProgB/size(sleepScoringDataFiles, 1)); pause(0.1);
    end
end

%% BLOCK PURPOSE: [4] Calculate the neural spectrogram for each file.
% To properly utilize the progress bars, this function's code has been pasted into this block. 
% If this block's results are not a saved field OR this block has never been ran OR the user has prompted to re-run... 
if ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_CreateTrialSpectrograms') || GT_AnalysisInfo.analysisChecklist.GT_CreateTrialSpectrograms == false || guiParams.rerunSpecData == true 
    for blockFourProg = 1:size(rawDataFiles, 1)
        rawDataFile = rawDataFiles(blockFourProg, :);
        [~, ~, ~, fileID] = GT_GetFileInfo(rawDataFile);
        load(rawDataFile);
        RawNeuro = RawData.Neuro;
        
        % Remove 60 Hz noise
        %  w0 = 60/(RawData.an_fs/2);  bw = w0/35;
        % [num,den] = iirnotch(w0, bw);
        % filtRawNeuro = filtfilt(num, den, RawNeuro);
        filtRawNeuro = RawNeuro - mean(RawNeuro);
        
        % Spectrogram parameters
        params.tapers = [5 9];
        params.Fs = RawData.an_fs;
        params.fpass = [0.1 100];
        movingwin1 = [1 1/5];
        movingwin5 = [5 1/5]; 
        [Neural_S1, Neural_T1, Neural_F1] = GT_mtspecgramc_GPU(filtRawNeuro, movingwin1, params);
        [Neural_S5, Neural_T5, Neural_F5] = GT_mtspecgramc_GPU(filtRawNeuro, movingwin5, params);
 
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
        GT_multiWaitbar('Creating Neural Spectrograms', blockFourProg/size(rawDataFiles, 1));   % Update progress bar.
    end
    % When finished with each file, save the summary structure and set the checklist for this block to true.
    save([animalID '_GT_SpectrogramData'], 'SpectrogramData', '-v7.3');
    GT_AnalysisInfo.analysisChecklist.GT_CreateTrialSpectrograms = true;
    save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo','-v7.3');
else
    % If this analysis has already been ran and this is a subsequent iteration...
    for blockFourProg = 1:size(rawDataFiles, 1)
        % Quickly cycle through the progress bar for ... visual satisfaction.
        GT_multiWaitbar('Creating Neural Spectrograms', blockFourProg/size(rawDataFiles, 1)); pause(0.1);
    end
end

%% BLOCK PURPOSE: [5] Determine resting baseline values using the animal's behavior flags.
% If this block's results are not a saved field OR this block has never been ran OR the user has prompted to re-run... 
if ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_CalculateRestingBaselines') || GT_AnalysisInfo.analysisChecklist.GT_CalculateRestingBaselines == false || guiParams.rerunBase == true
    % Find the resting baselines of the data. These functions perform best with the entire list of files and do not
    % take very long to run, so to avoid copy/pasting the entire code(s) in this block, the progress bar is a 'fraud'.
    [GT_AnalysisInfo] = GT_CalculateRestingBaselines(GT_AnalysisInfo, guiParams);
    [GT_AnalysisInfo] = GT_CalculateSpectrogramBaselines(GT_AnalysisInfo, SpectrogramData);
    for blockFiveProg = 1:size(sleepScoringDataFiles, 1)
        % Quickly cycle through the progress bar for ... visual satisfaction.
        GT_multiWaitbar('Calculating Resting Baselines', blockFiveProg/size(sleepScoringDataFiles, 1)); pause(0.1);   % Update progress bar. 
    end
    save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo','-v7.3');
else
    for blockFiveProg = 1:size(sleepScoringDataFiles, 1)
        % Quickly cycle through the progress bar for ... visual satisfaction.
        GT_multiWaitbar('Calculating Resting Baselines', blockFiveProg/size(sleepScoringDataFiles, 1)); pause(0.1);
    end
end

%% BLOCK PURPOSE: [6] Normalize data by resting baselines. (This block is programmatically coupled with Block [5])
% If this block's results are not a saved field OR this block has never been ran OR the user has prompted to re-run... 
if ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_CalculateRestingBaselines') || GT_AnalysisInfo.analysisChecklist.GT_CalculateRestingBaselines == false || guiParams.rerunBase == true
    for blockSixProg = 1:size(sleepScoringDataFiles, 1)
        sleepScoringDataFile = sleepScoringDataFiles(blockSixProg, :);
        % Feed the function one file at a time along with the summary structure and SpectrogramData structure.
        GT_NormalizeData(sleepScoringDataFile, GT_AnalysisInfo, SpectrogramData);
        GT_multiWaitbar('Normalizing Data by Baselines', blockSixProg/size(sleepScoringDataFiles, 1));   % Update progress bar.
    end
    % When finished with each file, save the summary structure and set the checklist for this block to true.
    GT_AnalysisInfo.analysisChecklist.GT_CalculateRestingBaselines = true;
    save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo','-v7.3');
else
    % If this analysis has already been ran and this is a subsequent iteration...
    for blockSixProg = 1:size(sleepScoringDataFiles, 1)
        % Quickly cycle through the progress bar for ... visual satisfaction.
        GT_multiWaitbar('Normalizing Data by Baselines', blockSixProg/size(sleepScoringDataFiles, 1)); pause(0.1);
    end
end

%% BLOCK PURPOSE: [7] Run sleep scoring analysis functions.
GT_AnalysisInfo.(guiParams.scoringID).guiParams = guiParams;
for blockSevenProgA = 1:size(sleepScoringDataFiles, 1)
    sleepScoringDataFile = sleepScoringDataFiles(blockSevenProgA, :);
    % Feed the function one file at a time.
    GT_AddSleepParameters(sleepScoringDataFile);
    GT_multiWaitbar('Running Sleep Scoring Analysis (part 1)', blockSevenProgA/size(sleepScoringDataFiles, 1));   % Update progress bar.
end

for blockSevenProgB = 1:size(sleepScoringDataFiles, 1)
    sleepScoringDataFile = sleepScoringDataFiles(blockSevenProgB, :);
    % Feed the function one file at a time along with the summary structure and GUI parameters.
    [GT_AnalysisInfo] = GT_AddSleepLogicals(sleepScoringDataFile, GT_AnalysisInfo, guiParams, blockSevenProgB);
    GT_multiWaitbar('Running Sleep Scoring Analysis (part 2)', blockSevenProgB/size(sleepScoringDataFiles, 1));   % Update progress bar.
end

[GT_AnalysisInfo] = GT_FindSleepData(sleepScoringDataFiles, GT_AnalysisInfo, guiParams);   % Create struct containing sleep epochs

if guiParams.saveStructToggle == true
    save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo','-v7.3');
end

%% BLOCK PURPOSE: [8] Create single trial summary figures if prompted.
% If the user prompted for the summary figures to be saved, create each figure for succesfully score files.
if guiParams.saveFigsToggle == true
    % Determine whether a folder for summary figures already exists.
    if exist('Sleep Summary Figs') == 7
        % Determine whether a folder for this specific scoring ID already exists. This would occur from successive
        % iterations of analysis with identical scoring IDs, which could have different parameters.
        if exist(['Sleep Summary Figs/' guiParams.scoringID '/']) == 7
            % Get a list of all files in the folder.
            filePattern = fullfile(['Sleep Summary Figs/' guiParams.scoringID '/'], '*.fig'); % Change to whatever pattern you need.
            theFiles = dir(filePattern);
            % Delete each figure that already exists under this scoring ID to prevent confusion.
            for k = 1 : length(theFiles)
                baseFileName = theFiles(k).name;
                fullFileName = fullfile(['Sleep Summary Figs/' guiParams.scoringID '/'], baseFileName);
                delete(fullFileName);
            end
        else
            % If a folder for the scoring ID doesn't exist, make it.
            dirpath = ([cd '/Sleep Summary Figs/' guiParams.scoringID '/']);
            mkdir(dirpath);
        end
    else
        % If a folder for the scoring ID doesn't exist, make it.
        dirpath = ([cd '/Sleep Summary Figs/' guiParams.scoringID '/']);
        mkdir(dirpath);
    end
    
    % Create a summary figure for each successful trial.
    if ~isempty(GT_AnalysisInfo.(guiParams.scoringID).data)
        uniqueSleepFiles = unique(GT_AnalysisInfo.(guiParams.scoringID).data.fileIDs);
        for k=1:size(fileIDs,1)
            filenames{k}=fileIDs{k,1}{1,1};
        end
        uniqueNoSleepFiles=setdiff(filenames,uniqueSleepFiles);
        for blockEightProg = 1:size(uniqueSleepFiles, 1)
            uniqueSleepFile = ([animalID '_' hem '_' char(uniqueSleepFiles(blockEightProg, :)) '_SleepScoringData.mat']);
            % Feed the function one file at a time along with the summary structure and gui parameters.
            GT_CreateSingleTrialFigs(uniqueSleepFile, GT_AnalysisInfo, guiParams);
            GT_multiWaitbar('Generating Single Trial Summary Figures', blockEightProg/(size(uniqueSleepFiles, 1)+size(uniqueNoSleepFiles,2)));   % Update progress bar.
        end
        for blockEightProg = 1:size(uniqueNoSleepFiles, 2)
            uniqueFile = ([animalID '_' hem '_' char(uniqueNoSleepFiles(1,blockEightProg)) '_SleepScoringData.mat']);
            % Feed the function one file at a time along with the summary structure and gui parameters.
            GT_CreateSingleTrialFigs_NoSleep(uniqueFile, GT_AnalysisInfo, guiParams);
            GT_multiWaitbar('Generating Single Trial Summary Figures', (blockEightProg+size(uniqueSleepFiles, 1))/(size(uniqueSleepFiles, 1)+size(uniqueNoSleepFiles,2)));   % Update progress bar.
        end
%     else
%         uniqueNoSleepFiles = unique(GT_AnalysisInfo.(guiParams.scoringID).data.fileIDs);
%          for blockEightProg = 1:size(uniqueNoSleepFiles, 1)
%             uniqueNoSleepFile = ([animalID '_' hem '_' char(uniqueNoSleepFiles(blockEightProg, :)) '_SleepScoringData.mat']);
%             % Feed the function one file at a time along with the summary structure and gui parameters.
%             GT_CreateSingleTrialFigs_NoSleep(uniqueNoSleepFile, GT_AnalysisInfo, guiParams);
%             GT_multiWaitbar('Generating Single Trial Summary Figures', blockEightProg/size(uniqueNoSleepFiles, 1));   % Update progress bar.
%         end
    end
end

%% Display the results of the analysis.
GT_MessageAlert('Complete', GT_AnalysisInfo, guiParams);
GT_multiWaitbar('CloseAll');

% Display the summary figures (if they exist) and if the user prompted for them to be saved.
% if guiParams.saveFigsToggle == true
%     % Find the figures' location
%     if exist(['Sleep Summary Figs/' guiParams.scoringID '/']) == 7
%         % Verify the figures exist, gather their names, and CD to the folder
%         if ~isempty(['Sleep Summary Figs/' guiParams.scoringID '/'])
             curDir = cd;
%             cd (['Sleep Summary Figs/' guiParams.scoringID '/']);
%             figDirectory = dir('*.fig');
%             figFiles = char({figDirectory.name}');
%             % Re-open each summary figure.
%             for f = 1:size(figFiles, 1)
%                 figF = figFiles(f, :);
%                 openfig(figF, 'visible');
%             end
%         end
%     end
% end

% Change back to the original directory.
cd(curDir);
warning('on', id)
clear id 

end

