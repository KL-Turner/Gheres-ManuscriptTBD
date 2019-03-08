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
boom;
rawDataDirectory = dir('*_RawData.mat');
rawDataFiles = char({rawDataDirectory.name}');
animalFile = rawDataFiles(1, :);
[animalID, hem, ~, ~] = GT_GetFileInfo(animalFile);

analysisInfo = dir('*_GT_AnalysisInfo.mat');
if ~isempty(analysisInfo)
    load(analysisInfo.name);
else
    GT_AnalysisInfo.analysisChecklist.GT_ProcessRawData = false;
    GT_AnalysisInfo.analysisChecklist.GT_CategorizeData = false;
    GT_AnalysisInfo.analysisChecklist.GT_CreateTrialSpectrograms = false;
    GT_AnalysisInfo.analysisChecklist.GT_CalculateRestingBaselines = false;
end

specDataFile = dir('*_GT_SpectrogramData.mat');
if ~isempty(specDataFile)
    load(specDataFile.name);
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
        guiParams.scoringID = strrep(guiResults.scoringID.String, ' ', '_');
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

guiParams.rerunBase = true;
guiParams.rerunCatData = true;

% Handle invalid inputs to GUI
[Error] = GT_CheckGUIVals(guiParams);
if Error == true
    GT_MessageAlert('Invalid', GT_AnalysisInfo, guiParams)
    return;
end

% Progress Bars
pause(0.25)
GT_multiWaitbar('Processing RawData Files', 0, 'Color', [0.720000 0.530000 0.040000]);
pause(0.25)
GT_multiWaitbar('Categorizing Behavioral Data', 0, 'Color', [0.720000 0.530000 0.040000]);
pause(0.25)
GT_multiWaitbar('Finding Resting Epochs (Data Types)', 0, 'Color', [0.720000 0.530000 0.040000]);
pause(0.25)
GT_multiWaitbar('Finding Resting Epochs (Files per Data Type)', 0, 'Color', [0.720000 0.530000 0.040000]);
pause(0.25)
GT_multiWaitbar('Creating Neural Spectrograms', 0, 'Color', [0.720000 0.530000 0.040000]);
pause(0.25)
GT_multiWaitbar('Calculating Resting Baselines', 0, 'Color', [0.720000 0.530000 0.040000]);
pause(0.25)
GT_multiWaitbar('Normalizing Data by Baselines', 0, 'Color', [0.720000 0.530000 0.040000]);
pause(0.25)
GT_multiWaitbar('Running Sleep Scoring Analysis (part 1)', 0, 'Color', [0.720000 0.530000 0.040000]);
pause(0.25)
GT_multiWaitbar('Running Sleep Scoring Analysis (part 2)', 0, 'Color', [0.720000 0.530000 0.040000]);
pause(0.25)
if guiParams.saveFigsToggle == true
    GT_multiWaitbar('Generating Single Trial Summary Figures', 0, 'Color', [0.720000 0.530000 0.040000]);
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
        pause(0.1)
    end
end
sleepScoringDataDirectory = dir('*_SleepScoringData.mat');
sleepScoringDataFiles = char({sleepScoringDataDirectory.name}');

%% BLOCK PURPOSE: [2] Categorize the animal's behavior using ball velocity.
if ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_CategorizeData') || GT_AnalysisInfo.analysisChecklist.GT_CategorizeData == false || guiParams.rerunCatData == true 
    for blockTwoProg = 1:size(sleepScoringDataFiles, 1)
        sleepScoringDataFile = sleepScoringDataFiles(blockTwoProg, :);
        [GT_AnalysisInfo] = GT_CategorizeData(sleepScoringDataFile, GT_AnalysisInfo);
        GT_multiWaitbar('Categorizing Behavioral Data', blockTwoProg/size(sleepScoringDataFiles, 1));
    end
else
    for blockTwoProg = 1:size(sleepScoringDataFiles, 1)
        GT_multiWaitbar('Categorizing Behavioral Data', blockTwoProg/size(sleepScoringDataFiles, 1));
        pause(0.1)
    end
end

%% BLOCK PURPOSE: [3] Find resting epochs. (This block is programmatically coupled with Block [2])
% To properly utilize the progress bars, this function's code has been pasted into this block. 
dataTypes = {'CBV', 'deltaBandPower', 'thetaBandPower', 'gammaBandPower'};
if ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_CategorizeData') || GT_AnalysisInfo.analysisChecklist.GT_CategorizeData == false || guiParams.rerunCatData == true
    for blockThreeProgA = 1:length(dataTypes)
        GT_multiWaitbar('Finding Resting Epochs (Data Types)', blockThreeProgA/length(dataTypes));
        restVals = cell(size(sleepScoringDataFiles, 1), 1);
        eventTimes = cell(size(sleepScoringDataFiles, 1), 1);
        durations = cell(size(sleepScoringDataFiles, 1), 1);
        puffDistances = cell(size(sleepScoringDataFiles, 1), 1);
        fileIDs = cell(size(sleepScoringDataFiles, 1), 1);
        fileDates = cell(size(sleepScoringDataFiles, 1), 1);
        
        for blockThreeProgB = 1:size(sleepScoringDataFiles, 1)
            filename = sleepScoringDataFiles(blockThreeProgB, :);
            load(filename);
            
            % Get the date and file identifier for the data to be saved with each resting event
            [~, ~, fileDate, fileID] = GT_GetFileInfo(filename);
            
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
    for blockThreeProgB = 1:size(sleepScoringDataFiles, 1)
        GT_multiWaitbar('Finding Resting Epochs (Data Types)', blockThreeProgB/size(sleepScoringDataFiles, 1));
        GT_multiWaitbar('Finding Resting Epochs (Files per Data Type)', blockThreeProgB/size(sleepScoringDataFiles, 1));
        pause(0.1)
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
%         w0 = 60/(RawData.an_fs/2);  bw = w0/35;
%         [num,den] = iirnotch(w0, bw);
%         filtRawNeuro = filtfilt(num, den, RawNeuro);
          filtRawNeuro=RawNeuro-mean(RawNeuro);
        
        % Spectrogram parameters
        params.tapers = [5 9];
        params.Fs = RawData.an_fs;
        params.fpass = [0.1 100];
        movingwin1 = [1 1/5];
        movingwin5 = [5 1/5]; 
        [Neural_S1, Neural_T1, Neural_F1] = mtspecgramc_GPU(filtRawNeuro, movingwin1, params);
        [Neural_S5, Neural_T5, Neural_F5] = mtspecgramc_GPU(filtRawNeuro, movingwin5, params);
 
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
        pause(0.1)
    end
end

%% BLOCK PURPOSE: [5] Determine resting baseline values using the animal's behavior flags.
if ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_CalculateRestingBaselines') || GT_AnalysisInfo.analysisChecklist.GT_CalculateRestingBaselines == false || guiParams.rerunBase == true
    [GT_AnalysisInfo] = GT_CalculateRestingBaselines(GT_AnalysisInfo, guiParams);
    [GT_AnalysisInfo] = GT_CalculateSpectrogramBaselines(GT_AnalysisInfo, SpectrogramData);
    for blockFiveProg = 1:size(sleepScoringDataFiles, 1)
        GT_multiWaitbar('Calculating Resting Baselines', blockFiveProg/size(sleepScoringDataFiles, 1));
        pause(0.1)
    end
    save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo');
else
    for blockFiveProg = 1:size(sleepScoringDataFiles, 1)
        GT_multiWaitbar('Calculating Resting Baselines', blockFiveProg/size(sleepScoringDataFiles, 1));
        pause(0.1)
    end
end

%% BLOCK PURPOSE: [6] Normalize data by resting baselines. (This block is programmatically coupled with Block [5])
if ~isfield(GT_AnalysisInfo.analysisChecklist, 'GT_CalculateRestingBaselines') || GT_AnalysisInfo.analysisChecklist.GT_CalculateRestingBaselines == false || guiParams.rerunBase == true
    for blockSixProg = 1:size(sleepScoringDataFiles, 1)
        sleepScoringDataFile = sleepScoringDataFiles(blockSixProg, :);
        [GT_AnalysisInfo] = GT_NormalizeData(sleepScoringDataFile, GT_AnalysisInfo, SpectrogramData);
        GT_multiWaitbar('Normalizing Data by Baselines', blockSixProg/size(sleepScoringDataFiles, 1));
    end
    GT_AnalysisInfo.analysisChecklist.GT_CalculateRestingBaselines = true;
    save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo');
else
    for blockSixProg = 1:size(sleepScoringDataFiles, 1)
        GT_multiWaitbar('Normalizing Data by Baselines', blockSixProg/size(sleepScoringDataFiles, 1));
        pause(0.1)
    end
end

%% BLOCK PURPOSE: [7] Run sleep scoring analysis functions.
GT_AnalysisInfo.(guiParams.scoringID).guiParams = guiParams;
for blockSevenProgA = 1:size(sleepScoringDataFiles, 1)
    sleepScoringDataFile = sleepScoringDataFiles(blockSevenProgA, :);
    GT_AddSleepParameters(sleepScoringDataFile);
    GT_multiWaitbar('Running Sleep Scoring Analysis (part 1)', blockSevenProgA/size(sleepScoringDataFiles, 1));
end

for blockSevenProgB = 1:size(sleepScoringDataFiles, 1)
    sleepScoringDataFile = sleepScoringDataFiles(blockSevenProgB, :);
    [GT_AnalysisInfo] = GT_AddSleepLogicals(sleepScoringDataFile, GT_AnalysisInfo, guiParams, blockSevenProgB);
    GT_multiWaitbar('Running Sleep Scoring Analysis (part 2)', blockSevenProgB/size(sleepScoringDataFiles, 1));
end

[GT_AnalysisInfo] = GT_FindSleepData(sleepScoringDataFiles, GT_AnalysisInfo, guiParams);   % Create struct containing sleep epochs

if guiParams.saveStructToggle == true
    save([animalID '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo');
end

%% BLOCK PURPOSE: [8] Create single trial summary figures if prompted.
if guiParams.saveFigsToggle == true
    if exist('Sleep Summary Figs') == 7
        if exist(['Sleep Summary Figs/' guiParams.scoringID '/']) == 7
            % Get a list of all files in the folder with the desired file name pattern.
            filePattern = fullfile(['Sleep Summary Figs/' guiParams.scoringID '/'], '*.fig'); % Change to whatever pattern you need.
            theFiles = dir(filePattern);
            for k = 1 : length(theFiles)
                baseFileName = theFiles(k).name;
                fullFileName = fullfile(['Sleep Summary Figs/' guiParams.scoringID '/'], baseFileName);
                delete(fullFileName);
            end
        else
            dirpath = ([cd '/Sleep Summary Figs/' guiParams.scoringID '/']);
            mkdir(dirpath);
        end
    else
        dirpath = ([cd '/Sleep Summary Figs/' guiParams.scoringID '/']);
        mkdir(dirpath);
    end
    if ~isempty(GT_AnalysisInfo.(guiParams.scoringID).data)
        uniqueSleepFiles = unique(GT_AnalysisInfo.(guiParams.scoringID).data.fileIDs);
        for blockEightProg = 1:size(uniqueSleepFiles, 1)
            uniqueSleepFile = ([animalID '_' hem '_' char(uniqueSleepFiles(blockEightProg, :)) '_SleepScoringData.mat']);
            GT_CreateSingleTrialFigs(uniqueSleepFile, GT_AnalysisInfo, guiParams);
            GT_multiWaitbar('Generating Single Trial Summary Figures', blockEightProg/size(uniqueSleepFiles, 1));
        end
    end
end

%% Results
GT_MessageAlert('Complete', GT_AnalysisInfo, guiParams);
GT_multiWaitbar('CloseAll');

if guiParams.saveFigsToggle == true
    if exist(['Sleep Summary Figs/' guiParams.scoringID '/']) == 7
        if ~isempty(['Sleep Summary Figs/' guiParams.scoringID '/'])
            curDir = cd;
            cd (['Sleep Summary Figs/' guiParams.scoringID '/']);
            figDirectory = dir('*.fig');
            figFiles = char({figDirectory.name}');
            for f = 1:size(figFiles, 1)
                figF = figFiles(f, :);
                openfig(figF, 'visible');
            end
        end
    end
end
cd(curDir);

end

