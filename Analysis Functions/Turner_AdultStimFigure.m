function [] = Turner_AdultStimFigure(rootFolder,saveFigs,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Generate temporary supplemental figure panel for Gheres (TBD)
%________________________________________________________________________________________________________________________

%% sensory stimulation based on arousal state prior to stimulus
animalIDs = {'T99','T101','T102','T103','T105','T108','T109','T110','T111','T119','T120','T121','T122','T123'};
solenoidNames = {'LPadSol','RPadSol','AudSol'};
compDataTypes = {'Ipsi','Contra','Auditory'};
dataTypes = {'adjLH','adjRH'};
arousalStates = {'Awake','NREM','Together'};
% cd through each animal's directory and extract the appropriate analysis results
for aa = 1:length(animalIDs)
    animalID = animalIDs{1,aa};
    for bb = 1:length(arousalStates)
        arousalState = arousalStates{1,bb};
        for cc = 1:length(dataTypes)
            dataType = dataTypes{1,cc};
            for dd = 1:length(solenoidNames)
                solenoidName = solenoidNames{1,dd};
                data.(arousalState).(dataType).(solenoidName).HbT(:,aa) = AnalysisResults.(animalID).EvokedAvgs.(arousalState).(dataType).(solenoidName).HbT;
                data.(arousalState).(dataType).(solenoidName).count(:,aa) = AnalysisResults.(animalID).EvokedAvgs.(arousalState).(dataType).(solenoidName).count;
                data.(arousalState).(dataType).(solenoidName).timeVector(:,aa) = AnalysisResults.(animalID).EvokedAvgs.(arousalState).(dataType).(solenoidName).timeVector;
            end
        end
    end
end
% designate contralateral sitmuli
for aa = 1:length(arousalStates)
    arousalState = arousalStates{1,aa};
    % contralateral stimulation
    data.(arousalState).Contra.HbT = cat(2,data.(arousalState).adjLH.RPadSol.HbT,data.(arousalState).adjRH.LPadSol.HbT);
    data.(arousalState).Contra.count = cat(2,data.(arousalState).adjLH.RPadSol.count,data.(arousalState).adjRH.LPadSol.count);
    data.(arousalState).Contra.timeVector = cat(2,data.(arousalState).adjLH.RPadSol.timeVector,data.(arousalState).adjRH.LPadSol.timeVector);
    % ipsilateral stimulation
    data.(arousalState).Ipsi.HbT = cat(2,data.(arousalState).adjLH.LPadSol.HbT,data.(arousalState).adjRH.RPadSol.HbT);
    data.(arousalState).Ipsi.count = cat(2,data.(arousalState).adjLH.LPadSol.count,data.(arousalState).adjRH.RPadSol.count);
    data.(arousalState).Ipsi.timeVector = cat(2,data.(arousalState).adjLH.LPadSol.timeVector,data.(arousalState).adjRH.RPadSol.timeVector);
    % auditory stimulation
    data.(arousalState).Auditory.HbT = cat(2,data.(arousalState).adjLH.AudSol.HbT,data.(arousalState).adjRH.AudSol.HbT);
    data.(arousalState).Auditory.count = cat(2,data.(arousalState).adjLH.AudSol.count,data.(arousalState).adjRH.AudSol.count);
    data.(arousalState).Auditory.timeVector = cat(2,data.(arousalState).adjLH.AudSol.timeVector,data.(arousalState).adjRH.AudSol.timeVector);
end
% take the averages of each field through the proper dimension
for aa = 1:length(arousalStates)
    arousalState = arousalStates{1,aa};
    for bb = 1:length(compDataTypes)
        compDataType = compDataTypes{1,bb};
        cc = 1;
        data.(arousalState).(compDataType).nMice = length(data.(arousalState).(compDataType).count)/2;
        data.(arousalState).(compDataType).nHem= sum(data.(arousalState).(compDataType).count ~= 0);
        % check cortical data for missing points
        for dd = 1:length(data.(arousalState).(compDataType).count)
            if data.(arousalState).(compDataType).count(1,dd) ~= 0
                procData.(arousalState).(compDataType).HbT(:,cc) = data.(arousalState).(compDataType).HbT(:,dd);
                procData.(arousalState).(compDataType).count(1,cc) = data.(arousalState).(compDataType).count(1,dd);
                procData.(arousalState).(compDataType).timeVector(:,cc) = data.(arousalState).(compDataType).timeVector(:,dd);
                cc = cc + 1;
            end
        end
        data.(arousalState).(compDataType).meanHbT = mean(procData.(arousalState).(compDataType).HbT,2);
        data.(arousalState).(compDataType).stdHbT = std(procData.(arousalState).(compDataType).HbT,0,2);
        data.(arousalState).(compDataType).meanCount = mean(procData.(arousalState).(compDataType).count,2);
        data.(arousalState).(compDataType).stdCount = std(procData.(arousalState).(compDataType).count,0,2);
        data.(arousalState).(compDataType).meanTimeVector = mean(procData.(arousalState).(compDataType).timeVector,2);
    end
end
%% transitions between each arousal-state
transitions = {'NREMtoAWAKE',};
% cd through each animal's directory and extract the appropriate analysis results
for aa = 1:length(animalIDs)
    animalID = animalIDs{1,aa};
    for bb = 1:length(transitions)
        transition = transitions{1,bb};
        data.(transition).HbT(aa,:) = AnalysisResults.(animalID).Transitions.(transition).HbT;
    end
end
% take average for each behavioral transition
for cc = 1:length(transitions)
    transition = transitions{1,cc};
    data.(transition).meanHbT = mean(data.(transition).HbT,1);
    data.(transition).stdHbT = std(data.(transition).HbT,0,1);
end
T1 = -26.5 + (1/30):(1/30):33.5;
%% probability of peri-stimulus arousal state
data.awakeProbability = []; data.awakeNumerics = []; data.asleepProbability = []; data.asleepNumerics = [];
for aa  = 1:length(animalIDs)
    animalID = animalIDs{1,aa};
    data.awakeProbability = cat(1,data.awakeProbability,AnalysisResults.(animalID).Probability.awakeProbability);
    data.asleepProbability = cat(1,data.asleepProbability,AnalysisResults.(animalID).Probability.asleepProbability);
end
data.meanAwakeProb = mean(data.awakeProbability,1);
data.stdAwakeProb = std(data.awakeProbability,0,1);
data.meanAsleepProb = mean(data.asleepProbability,1);
data.stdAsleepProb = std(data.asleepProbability,0,1);
%% Fig. 1
summaryFigure = figure('Name','Gheres et al TBD');
%% [1d] Comb states CBV HbT Contra Stim
ax1 = subplot(1,2,1);
p1 = plot(data.Awake.Contra.meanTimeVector,data.Awake.Contra.meanHbT,'color',colors('candy apple red'),'LineWidth',2);
hold on
plot(data.Awake.Contra.meanTimeVector,data.Awake.Contra.meanHbT + data.Awake.Contra.stdHbT,'color',colors('candy apple red'),'LineWidth',0.5)
plot(data.Awake.Contra.meanTimeVector,data.Awake.Contra.meanHbT - data.Awake.Contra.stdHbT,'color',colors('candy apple red'),'LineWidth',0.5)
p2 = plot(data.NREM.Contra.meanTimeVector,data.NREM.Contra.meanHbT,'color',colors('sapphire'),'LineWidth',2);
plot(data.NREM.Contra.meanTimeVector,data.NREM.Contra.meanHbT + data.NREM.Contra.stdHbT,'color',colors('sapphire'),'LineWidth',0.5)
plot(data.NREM.Contra.meanTimeVector,data.NREM.Contra.meanHbT - data.NREM.Contra.stdHbT,'color',colors('sapphire'),'LineWidth',0.5)
p3 = plot(T1,data.NREMtoAWAKE.meanHbT,'-','color',colors('royal purple'),'LineWidth',2);
hold on
plot(T1,data.NREMtoAWAKE.meanHbT + data.NREMtoAWAKE.stdHbT,'-','color',colors('royal purple'),'LineWidth',0.5)
plot(T1,data.NREMtoAWAKE.meanHbT - data.NREMtoAWAKE.stdHbT,'-','color',colors('royal purple'),'LineWidth',0.5)
p4 = plot(data.Together.Contra.meanTimeVector,data.Together.Contra.meanHbT,'color',colors('black'),'LineWidth',2);
plot(data.Together.Contra.meanTimeVector,data.Together.Contra.meanHbT + data.Together.Contra.stdHbT,'color',colors('black'),'LineWidth',0.5)
plot(data.Together.Contra.meanTimeVector,data.Together.Contra.meanHbT - data.Together.Contra.stdHbT,'color',colors('black'),'LineWidth',0.5)
ylabel('\Delta[HbT] (\muM)')
xlabel('Time (sec)')
xlim([-5,15])
legend([p1,p2,p3,p4],'Awake','NREM','NREM to Awake Transition','Unsorted Stimulus')
axis square
set(gca,'box','off')
ax1.TickLength = [0.03,0.03];
%% Probability of arousal during a stimulation
ax2 = subplot(1,2,2);
p1 = plot([-10,-5,0,5,10],data.meanAwakeProb,'color',colors('black'),'LineWidth',2);
hold on
% plot([-10,-5,0,5,10],data.meanAwakeProb + data.stdAwakeProb,'color',colors('black'),'LineWidth',0.5);
% plot([-10,-5,0,5,10],data.meanAwakeProb - data.stdAwakeProb,'color',colors('black'),'LineWidth',0.5);
p2 = plot([-10,-5,0,5,10],data.meanAsleepProb,'color',colors('candy apple red'),'LineWidth',2);
% plot([-10,-5,0,5,10],data.meanAsleepProb + data.stdAsleepProb,'color',colors('candy apple red'),'LineWidth',0.5);
% plot([-10,-5,0,5,10],data.meanAsleepProb - data.stdAsleepProb,'color',colors('candy apple red'),'LineWidth',0.5);
ylabel('Probability of Arousal State')
xlabel('Time (sec)')
legend([p1,p2],'Awake','Asleep')
ylim([0,1])
axis square
set(gca,'box','off')
xticks([-10,-5,0,5,10])
ax2.TickLength = [0.03,0.03];
%% save figure(s)
if strcmp(saveFigs,'y') == true
    dirpath = [rootFolder '\Gheres Summary Figures and Structures\MATLAB Analysis Figures\'];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(summaryFigure,[dirpath 'Turner_AdultStimFigure']);
    set(summaryFigure,'PaperPositionMode','auto');
    print('-vector','-dpdf','-fillpage',[dirpath 'Turner_AdultStimFigure'])
end
