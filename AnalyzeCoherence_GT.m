function [AnalysisResults] = AnalyzeCoherence_GT(animalID,rootFolder,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Analyze the spectral coherence between bilateral hemodynamic [HbT] and neural signals (IOS)
%________________________________________________________________________________________________________________________

%% function parameters
animalIDs = {'T99','T101','T102','T103','T105','T108','T109','T110','T111','T119','T120','T121','T122','T123'};
%% only run analysis for valid animal IDs
if any(strcmp(animalIDs,animalID))
    dataLocation = [rootFolder '/' animalID '/Bilateral Imaging/'];
    cd(dataLocation)
    % character list of all ProcData file IDs
    procDataFileStruct = dir('*_ProcData.mat');
    procDataFiles = {procDataFileStruct.name}';
    procDataFileIDs = char(procDataFiles);
    % find and load RestData.mat struct
    restDataFileStruct = dir('*_RestData.mat');
    restDataFile = {restDataFileStruct.name}';
    restDataFileID = char(restDataFile);
    load(restDataFileID)
    % find and load manual baseline event information
    manualBaselineFileStruct = dir('*_ManualBaselineFileList.mat');
    manualBaselineFile = {manualBaselineFileStruct.name}';
    manualBaselineFileID = char(manualBaselineFile);
    load(manualBaselineFileID)
    % find and load RestingBaselines.mat struct
    baselineDataFileStruct = dir('*_RestingBaselines.mat');
    baselineDataFile = {baselineDataFileStruct.name}';
    baselineDataFileID = char(baselineDataFile);
    load(baselineDataFileID)
    % find and load SleepData.mat struct
    sleepDataFileStruct = dir('*_SleepData.mat');
    sleepDataFile = {sleepDataFileStruct.name}';
    sleepDataFileID = char(sleepDataFile);
    load(sleepDataFileID)
    % find and load Forest_ScoringResults.mat struct
    forestScoringResultsFileID = 'Forest_ScoringResults.mat';
    load(forestScoringResultsFileID,'-mat')
    % lowpass filter
    samplingRate = RestData.CBV_HbT.adjLH.CBVCamSamplingRate;
    % go through each valid data type for arousal-based coherence analysis
    
    %% analyze bilateral coherence during periods of alert
    zz = 1;
    clear LH_AwakeData RH_AwakeData LH_ProcAwakeData RH_ProcAwakeData
    LH_AwakeData = [];
    for bb = 1:size(procDataFileIDs,1)
        procDataFileID = procDataFileIDs(bb,:);
        [animalID,~,allDataFileID] = GetFileInfo_IOS_Manuscript2020(procDataFileID);
        scoringLabels = [];
        for cc = 1:length(ScoringResults.fileIDs)
            if strcmp(allDataFileID,ScoringResults.fileIDs{cc,1}) == true
                scoringLabels = ScoringResults.labels{cc,1};
            end
        end
        % check labels to match arousal state
        if sum(strcmp(scoringLabels,'Not Sleep')) > 144   % 36 bins (180 total) or 3 minutes of sleep
            load(procDataFileID)
            puffs = ProcData.data.solenoids.LPadSol;
            % don't include trials with stimulation
            if isempty(puffs) == true
                LH_AwakeData{zz,1} = ProcData.data.CBV_HbT.adjLH; %#ok<*AGROW>
                RH_AwakeData{zz,1} = ProcData.data.CBV_HbT.adjRH;
                whiskAngle_AwakeData{zz,1} = ProcData.data.whiskerAngle;
                params.tapers = [5,9];
                params.Fs = 30;
                params.fpass = [1,15];
                params.err = [2,1];
                movingwin = [5,1/5];
                [LH_C,~,~,~,~,LH_t,LH_f,~,~,~] = cohgramc(detrend(LH_AwakeData{zz,1},'constant')',detrend(whiskAngle_AwakeData{zz,1},'constant')',movingwin,params);
                [RH_C,~,~,~,~,~,~,~,~,~] = cohgramc(detrend(RH_AwakeData{zz,1},'constant')',detrend(whiskAngle_AwakeData{zz,1},'constant')',movingwin,params);
                CohGram.LH_C = LH_C;
                CohGram.RH_C = RH_C;
                CohGram.t = LH_t;
                CohGram.f = LH_f;
                save([animalID '_' allDataFileID '_CohGram.mat'],'CohGram')
                zz = zz + 1;
            end
        end
    end
    % filter and detrend data
    if isempty(LH_AwakeData) == false
        for bb = 1:length(LH_AwakeData)
            LH_ProcAwakeData{bb,1} = detrend(LH_AwakeData{bb,1},'constant');
            RH_ProcAwakeData{bb,1} = detrend(RH_AwakeData{bb,1},'constant');
            whiskAngle_ProcAwakeData{bb,1} = detrend(whiskAngle_AwakeData{bb,1},'constant');
        end
        % input data as time (1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
        LH_awakeData = zeros(length(LH_ProcAwakeData{1,1}),length(LH_ProcAwakeData));
        RH_awakeData = zeros(length(RH_ProcAwakeData{1,1}),length(RH_ProcAwakeData));
        whiskAngle_awakeData = zeros(length(whiskAngle_ProcAwakeData{1,1}),length(whiskAngle_ProcAwakeData));
        for cc = 1:length(LH_ProcAwakeData)
            LH_awakeData(:,cc) = LH_ProcAwakeData{cc,1};
            RH_awakeData(:,cc) = RH_ProcAwakeData{cc,1};
            whiskAngle_awakeData(:,cc) = whiskAngle_ProcAwakeData{cc,1};
        end
        % parameters for coherencyc - information available in function
        params.tapers = [25,49];   % Tapers [n, 2n - 1]
        params.pad = 1;
        params.Fs = samplingRate;
        params.fpass = [2,15];   % Pass band [0, nyquist]
        params.trialave = 1;
        params.err = [2,0.05];
        % calculate the coherence between desired signals
        [LH_C_AwakeData,~,~,~,~,LH_f_AwakeData,LH_confC_AwakeData,~,LH_cErr_AwakeData] = coherencyc_Manuscript2020(LH_awakeData,whiskAngle_awakeData,params);
        [RH_C_AwakeData,~,~,~,~,RH_f_AwakeData,RH_confC_AwakeData,~,RH_cErr_AwakeData] = coherencyc_Manuscript2020(RH_awakeData,whiskAngle_awakeData,params);
        % save results
        AnalysisResults.(animalID).Coherence.Awake.LH.C = LH_C_AwakeData;
        AnalysisResults.(animalID).Coherence.Awake.LH.f = LH_f_AwakeData;
        AnalysisResults.(animalID).Coherence.Awake.LH.confC = LH_confC_AwakeData;
        AnalysisResults.(animalID).Coherence.Awake.LH.cErr = LH_cErr_AwakeData;        
        AnalysisResults.(animalID).Coherence.Awake.RH.C = RH_C_AwakeData;
        AnalysisResults.(animalID).Coherence.Awake.RH.f = RH_f_AwakeData;
        AnalysisResults.(animalID).Coherence.Awake.RH.confC = RH_confC_AwakeData;
        AnalysisResults.(animalID).Coherence.Awake.RH.cErr = RH_cErr_AwakeData;
    else
        % save results
        AnalysisResults.(animalID).Coherence.Awake.LH.C = [];
        AnalysisResults.(animalID).Coherence.Awake.LH.f = [];
        AnalysisResults.(animalID).Coherence.Awake.LH.confC = [];
        AnalysisResults.(animalID).Coherence.Awake.LH.cErr = [];
        AnalysisResults.(animalID).Coherence.Awake.RH.C = [];
        AnalysisResults.(animalID).Coherence.Awake.RH.f = [];
        AnalysisResults.(animalID).Coherence.Awake.RH.confC = [];
        AnalysisResults.(animalID).Coherence.Awake.RH.cErr = [];
    end
%     %% analyze bilateral coherence during periods of asleep
%     zz = 1;
%     clear LH_SleepData RH_SleepData LH_ProcSleepData RH_ProcSleepData
%     LH_SleepData = [];
%     for bb = 1:size(procDataFileIDs,1)
%         procDataFileID = procDataFileIDs(bb,:);
%         [~,~,allDataFileID] = GetFileInfo_IOS_Manuscript2020(procDataFileID);
%         scoringLabels = [];
%         for cc = 1:length(ScoringResults.fileIDs)
%             if strcmp(allDataFileID,ScoringResults.fileIDs{cc,1}) == true
%                 scoringLabels = ScoringResults.labels{cc,1};
%             end
%         end
%         % check labels to match arousal state
%         if sum(strcmp(scoringLabels,'Not Sleep')) < 36   % 36 bins (180 total) or 3 minutes of awake
%             load(procDataFileID)
%             puffs = ProcData.data.solenoids.LPadSol;
%             % don't include trials with stimulation
%             if isempty(puffs) == true
%                 LH_SleepData{zz,1} = ProcData.data.CBV_HbT.adjLH;
%                 RH_SleepData{zz,1} = ProcData.data.CBV_HbT.adjRH;
%                 whiskAngle_SleepData{zz,1} = ProcData.data.whiskerAngle;
%                 zz = zz + 1;
%             end
%         end
%     end
%     % ilter and detrend data
%     if isempty(LH_SleepData) == false
%         for bb = 1:length(LH_SleepData)
%             LH_ProcSleepData{bb,1} = detrend(LH_SleepData{bb,1},'constant');
%             RH_ProcSleepData{bb,1} = detrend(RH_SleepData{bb,1},'constant');
%             whiskAngle_ProcSleepData{bb,1} = detrend(whiskAngle_SleepData{bb,1},'constant');
%         end
%         % input data as time (1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
%         LH_sleepData = zeros(length(LH_ProcSleepData{1,1}),length(LH_ProcSleepData));
%         RH_sleepData = zeros(length(RH_ProcSleepData{1,1}),length(RH_ProcSleepData));
%         whiskAngle_sleepData = zeros(length(whiskAngle_ProcSleepData{1,1}),length(whiskAngle_ProcSleepData));
%         for cc = 1:length(LH_ProcSleepData)
%             LH_sleepData(:,cc) = LH_ProcSleepData{cc,1};
%             RH_sleepData(:,cc) = RH_ProcSleepData{cc,1};
%             whiskAngle_sleepData(:,cc) = whiskAngle_ProcSleepData{cc,1};
%         end
%         % parameters for coherencyc - information available in function
%         params.tapers = [25,49];   % Tapers [n, 2n - 1]
%         params.pad = 1;
%         params.Fs = samplingRate;
%         params.fpass = [2,15];   % Pass band [0, nyquist]
%         params.trialave = 1;
%         params.err = [2,0.05];
%         % calculate the coherence between desired signals
%         [LH_C_SleepData,~,~,~,~,LH_f_SleepData,LH_confC_SleepData,~,LH_cErr_SleepData] = coherencyc_Manuscript2020(LH_sleepData,whiskAngle_sleepData,params);
%         [RH_C_SleepData,~,~,~,~,RH_f_SleepData,RH_confC_SleepData,~,RH_cErr_SleepData] = coherencyc_Manuscript2020(RH_sleepData,whiskAngle_sleepData,params);
%         % save results
%         AnalysisResults.(animalID).Coherence.Sleep.LH.C = LH_C_SleepData;
%         AnalysisResults.(animalID).Coherence.Sleep.LH.f = LH_f_SleepData;
%         AnalysisResults.(animalID).Coherence.Sleep.LH.confC = LH_confC_SleepData;
%         AnalysisResults.(animalID).Coherence.Sleep.LH.cErr = LH_cErr_SleepData;
%         AnalysisResults.(animalID).Coherence.Sleep.RH.C = RH_C_SleepData;
%         AnalysisResults.(animalID).Coherence.Sleep.RH.f = RH_f_SleepData;
%         AnalysisResults.(animalID).Coherence.Sleep.RH.confC = RH_confC_SleepData;
%         AnalysisResults.(animalID).Coherence.Sleep.RH.cErr = RH_cErr_SleepData;
%     else
%         % save results
%         AnalysisResults.(animalID).Coherence.Sleep.LH.C = [];
%         AnalysisResults.(animalID).Coherence.Sleep.LH.f = [];
%         AnalysisResults.(animalID).Coherence.Sleep.LH.confC = [];
%         AnalysisResults.(animalID).Coherence.Sleep.LH.cErr = [];
%         AnalysisResults.(animalID).Coherence.Sleep.RH.C = [];
%         AnalysisResults.(animalID).Coherence.Sleep.RH.f = [];
%         AnalysisResults.(animalID).Coherence.Sleep.RH.confC = [];
%         AnalysisResults.(animalID).Coherence.Sleep.RH.cErr = [];
%     end
%     %% analyze bilateral coherence during periods of all data
%     zz = 1;
%     clear LH_AllUnstimData RH_AllUnstimData LH_ProcAllUnstimData RH_ProcAllUnstimData
%     LH_AllUnstimData = [];
%     for bb = 1:size(procDataFileIDs,1)
%         procDataFileID = procDataFileIDs(bb,:);
%         load(procDataFileID)
%         puffs = ProcData.data.solenoids.LPadSol;
%         % don't include trials with stimulation
%         if isempty(puffs) == true
%             if strcmp(dataType,'CBV_HbT') == true
%                 LH_AllUnstimData{zz,1} = ProcData.data.CBV_HbT.adjLH;
%                 RH_AllUnstimData{zz,1} = ProcData.data.CBV_HbT.adjRH;
%                 whiskAngle_AllUnstimData{zz,1} = ProcData.data.whiskerAngle;
%             end
%             zz = zz + 1;
%         end
%     end
%     % filter and detrend data
%     if isempty(LH_AllUnstimData) == false
%         for bb = 1:length(LH_AllUnstimData)
%             LH_ProcAllUnstimData{bb,1} = detrend(LH_AllUnstimData{bb,1},'constant');
%             RH_ProcAllUnstimData{bb,1} = detrend(RH_AllUnstimData{bb,1},'constant');
%             whiskAngle_ProcAllUnstimData{bb,1} = detrend(whiskAngle_AllUnstimData{bb,1},'constant');
%         end
%         % input data as time(1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
%         LH_allUnstimData = zeros(length(LH_ProcAllUnstimData{1,1}),length(LH_ProcAllUnstimData));
%         RH_allUnstimData = zeros(length(RH_ProcAllUnstimData{1,1}),length(RH_ProcAllUnstimData));
%         whiskAngle_allUnstimData = zeros(length(whiskAngle_ProcAllUnstimData{1,1}),length(whiskAngle_ProcAllUnstimData));
%         for cc = 1:length(LH_ProcAllUnstimData)
%             LH_allUnstimData(:,cc) = LH_ProcAllUnstimData{cc,1};
%             RH_allUnstimData(:,cc) = RH_ProcAllUnstimData{cc,1};
%             whiskAngle_allUnstimData(:,cc) = whiskAngle_ProcAllUnstimData{cc,1};
%         end
%         % parameters for coherencyc - information available in function
%         params.tapers = [25,49];   % Tapers [n, 2n - 1]
%         params.pad = 1;
%         params.Fs = samplingRate;   % Sampling Rate
%         params.fpass = [2,15];   % Pass band [0, nyquist]
%         params.trialave = 1;
%         params.err = [2,0.05];
%         % calculate the coherence between desired signals
%         [C_AllUnstimData,~,~,~,~,f_AllUnstimData,confC_AllUnstimData,~,cErr_AllUnstimData] = coherencyc_Manuscript2020(LH_allUnstimData,RH_allUnstimData,params);
%         % save results
%         AnalysisResults.(animalID).Coherence.All.(dataType).C = C_AllUnstimData;
%         AnalysisResults.(animalID).Coherence.All.(dataType).f = f_AllUnstimData;
%         AnalysisResults.(animalID).Coherence.All.(dataType).confC = confC_AllUnstimData;
%         AnalysisResults.(animalID).Coherence.All.(dataType).cErr = cErr_AllUnstimData;
%         % save figures if desired
%         if strcmp(saveFigs,'y') == true
%             allUnstimCoherence = figure;
%             semilogx(f_AllUnstimData,C_AllUnstimData,'k')
%             hold on;
%             semilogx(f_AllUnstimData,cErr_AllUnstimData,'color',colors_Manuscript2020('battleship grey'))
%             xlabel('Freq (Hz)');
%             ylabel('Coherence');
%             title([animalID  ' ' dataType ' coherence for all unstim data']);
%             set(gca,'Ticklength',[0,0]);
%             legend('Coherence','Jackknife Lower','Jackknife Upper','Location','Southeast');
%             set(legend,'FontSize',6);
%             ylim([0,1])
%             xlim([0,0.5])
%             axis square
%             set(gca,'box','off')
%             [pathstr,~,~] = fileparts(cd);
%             dirpath = [pathstr '/Figures/Coherence/'];
%             if ~exist(dirpath,'dir')
%                 mkdir(dirpath);
%             end
%             savefig(allUnstimCoherence,[dirpath animalID '_AllUnstim_' dataType '_Coherence']);
%             close(allUnstimCoherence)
%         end
%     end
    %% save data
    cd(rootFolder)
    save('AnalysisResults.mat','AnalysisResults')
end

end
