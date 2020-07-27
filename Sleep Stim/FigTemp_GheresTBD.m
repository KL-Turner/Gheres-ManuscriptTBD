function [AnalysisResults] = FigTemp_GheresTBD(rootFolder,saveFigs,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Generate figure panel S3 for Turner_Kederasetti_Gheres_Proctor_Costanzo_Drew_Manuscript2020
%________________________________________________________________________________________________________________________

%% set-up and process data
animalIDs = {'T99','T101','T102','T103','T105','T108','T109','T110','T111','T119','T120','T121','T122','T123'};
whiskDataTypes = {'ShortWhisks','IntermediateWhisks','LongWhisks'};
% cd through each animal's directory and extract the appropriate analysis results
for a = 1:length(animalIDs)
    animalID = animalIDs{1,a};
    for c = 1:length(whiskDataTypes)
        whiskDataType = whiskDataTypes{1,c};
        % LH cortical
        data.(whiskDataType).adjLH.HbT(:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjLH.(whiskDataType).CBV_HbT.HbT;
        data.(whiskDataType).adjLH.CBV(:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjLH.(whiskDataType).CBV.CBV;
        data.(whiskDataType).adjLH.EMG(:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjLH.(whiskDataType).EMG.EMG;
        data.(whiskDataType).adjLH.cortMUA(:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjLH.(whiskDataType).MUA.corticalData;
        data.(whiskDataType).adjLH.cortGam(:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjLH.(whiskDataType).Gam.corticalData;
        data.(whiskDataType).adjLH.cortS(:,:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjLH.(whiskDataType).LFP.corticalS;
        data.(whiskDataType).adjLH.cortS_Gam(:,:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjLH.(whiskDataType).LFP.corticalS(49:end,20:23);
        data.(whiskDataType).adjLH.cortT(:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjLH.(whiskDataType).LFP.T;
        data.(whiskDataType).adjLH.cortF(:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjLH.(whiskDataType).LFP.F;
        % RH cortical
        data.(whiskDataType).adjRH.HbT(:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjRH.(whiskDataType).CBV_HbT.HbT;
        data.(whiskDataType).adjRH.CBV(:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjRH.(whiskDataType).CBV.CBV;
        data.(whiskDataType).adjRH.cortMUA(:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjRH.(whiskDataType).MUA.corticalData;
        data.(whiskDataType).adjRH.cortGam(:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjRH.(whiskDataType).Gam.corticalData;
        data.(whiskDataType).adjRH.cortS(:,:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjRH.(whiskDataType).LFP.corticalS;
        data.(whiskDataType).adjRH.cortS_Gam(:,:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjRH.(whiskDataType).LFP.corticalS(49:end,20:23);
        data.(whiskDataType).adjRH.cortT(:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjRH.(whiskDataType).LFP.T;
        data.(whiskDataType).adjRH.cortF(:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjRH.(whiskDataType).LFP.F;
        % hippocampal
        data.(whiskDataType).Hip.hipMUA(:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjLH.(whiskDataType).MUA.hippocampalData;
        data.(whiskDataType).Hip.hipGam(:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjLH.(whiskDataType).Gam.hippocampalData;
        data.(whiskDataType).Hip.hipS(:,:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjLH.(whiskDataType).LFP.hippocampalS;
        data.(whiskDataType).Hip.hipS_Gam(:,:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjLH.(whiskDataType).LFP.hippocampalS(49:end,20:23);
        data.(whiskDataType).Hip.hipT(:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjLH.(whiskDataType).LFP.T;
        data.(whiskDataType).Hip.hipF(:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjLH.(whiskDataType).LFP.F;
        % time vector
        data.(whiskDataType).timeVector(:,a) = AnalysisResults.(animalID).EvokedAvgs.Whisk.adjLH.(whiskDataType).timeVector;
    end
end
% concatenate the data from the contra and ipsi data
for e = 1:length(whiskDataTypes)
    whiskDataType = whiskDataTypes{1,e};
    data.(whiskDataType).HbT = cat(2,data.(whiskDataType).adjLH.HbT,data.(whiskDataType).adjRH.HbT);
    data.(whiskDataType).CBV = cat(2,data.(whiskDataType).adjLH.CBV,data.(whiskDataType).adjRH.CBV);
    data.(whiskDataType).EMG = data.(whiskDataType).adjLH.EMG;
    data.(whiskDataType).cortMUA = cat(2,data.(whiskDataType).adjLH.cortMUA,data.(whiskDataType).adjRH.cortMUA);
    data.(whiskDataType).cortGam = cat(2,data.(whiskDataType).adjLH.cortGam,data.(whiskDataType).adjRH.cortGam);
    data.(whiskDataType).cortS = cat(3,data.(whiskDataType).adjLH.cortS,data.(whiskDataType).adjRH.cortS);
    data.(whiskDataType).cortS_Gam = cat(3,data.(whiskDataType).adjLH.cortS_Gam,data.(whiskDataType).adjRH.cortS_Gam);
    data.(whiskDataType).cortT = cat(2,data.(whiskDataType).adjLH.cortT,data.(whiskDataType).adjRH.cortT);
    data.(whiskDataType).cortF = cat(2,data.(whiskDataType).adjLH.cortF,data.(whiskDataType).adjRH.cortF);
end
% concatenate the data from the contra and ipsi data
for e = 1:length(whiskDataTypes)
    whiskDataType = whiskDataTypes{1,e};
    data.(whiskDataType).meanHbT = mean(data.(whiskDataType).HbT,2);
    data.(whiskDataType).stdHbT = std(data.(whiskDataType).HbT,0,2);
    data.(whiskDataType).meanCBV = mean(data.(whiskDataType).CBV,2);
    data.(whiskDataType).stdCBV = std(data.(whiskDataType).CBV,0,2);   
    data.(whiskDataType).meanEMG = mean(data.(whiskDataType).EMG,2);
    data.(whiskDataType).stdEMG = std(data.(whiskDataType).EMG,0,2);
    data.(whiskDataType).meanCortMUA = mean(data.(whiskDataType).cortMUA,2);
    data.(whiskDataType).stdCortMUA = std(data.(whiskDataType).cortMUA,0,2);
    data.(whiskDataType).meanCortGam = mean(data.(whiskDataType).cortGam,2);
    data.(whiskDataType).stdCortGam = std(data.(whiskDataType).cortGam,0,2);
    data.(whiskDataType).meanCortS = mean(data.(whiskDataType).cortS,3).*100;
    data.(whiskDataType).mean_CortS_Gam = mean(mean(mean(data.(whiskDataType).cortS_Gam.*100,2),1),3);
    data.(whiskDataType).std_CortS_Gam = std(mean(mean(data.(whiskDataType).cortS_Gam.*100,2),1),0,3);
    data.(whiskDataType).meanCortT = mean(data.(whiskDataType).cortT,2);
    data.(whiskDataType).meanCortF = mean(data.(whiskDataType).cortF,2);
    data.(whiskDataType).meanHipMUA = mean(data.(whiskDataType).Hip.hipMUA,2);
    data.(whiskDataType).stdHipMUA = std(data.(whiskDataType).Hip.hipMUA,0,2);
    data.(whiskDataType).meanHipGam = mean(data.(whiskDataType).Hip.hipGam,2);
    data.(whiskDataType).stdHipGam = std(data.(whiskDataType).Hip.hipGam,0,2);
    data.(whiskDataType).meanHipS = mean(data.(whiskDataType).Hip.hipS,3).*100;
    data.(whiskDataType).mean_HipS_Gam = mean(mean(mean(data.(whiskDataType).Hip.hipS_Gam.*100,2),1),3);
    data.(whiskDataType).std_HipS_Gam = std(mean(mean(data.(whiskDataType).Hip.hipS_Gam.*100,2),1),0,3);
    data.(whiskDataType).meanHipT = mean(data.(whiskDataType).Hip.hipT,2);
    data.(whiskDataType).meanHipF = mean(data.(whiskDataType).Hip.hipF,2);
    data.(whiskDataType).meanTimeVector = mean(data.(whiskDataType).timeVector(:,a),2);
end
%% Fig. S3
summaryFigure = figure('Name','Fig'); %#ok<*NASGU>
% sgtitle('EMG vs. Whisking behaviors')
%% [] ShortWhisks whisks cortical MUA
ax1 = subplot(2,3,1);
plot(data.ShortWhisks.meanTimeVector,data.ShortWhisks.meanCortMUA,'-','color',colors_Manuscript2020('rich black'),'LineWidth',1);
hold on
plot(data.ShortWhisks.meanTimeVector,data.ShortWhisks.meanCortMUA + data.ShortWhisks.stdCortMUA,'-','color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
plot(data.ShortWhisks.meanTimeVector,data.ShortWhisks.meanCortMUA - data.ShortWhisks.stdCortMUA,'-','color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
xline(0,'color','k','LineWidth',2);
ylabel('\DeltaP/P (%)')
ylim([-15,30])
yyaxis right
semilogy(data.ShortWhisks.meanTimeVector,data.ShortWhisks.meanEMG,'-','color',colors_Manuscript2020('deep carrot orange'),'LineWidth',1);
hold on
semilogy(data.ShortWhisks.meanTimeVector,data.ShortWhisks.meanEMG + data.IntermediateWhisks.stdEMG,'-','color',colors_Manuscript2020('carrot orange'),'LineWidth',0.5)
semilogy(data.ShortWhisks.meanTimeVector,data.ShortWhisks.meanEMG - data.IntermediateWhisks.stdEMG,'-','color',colors_Manuscript2020('carrot orange'),'LineWidth',0.5)
ylabel('EMG power (a.u.)','rotation',-90,'VerticalAlignment','bottom')
title('Brief whisk cortical MUA/EMG')
xlabel('Peri-whisk time (s)')
axis square
xlim([-2,10])
ylim([0,1.5])
set(gca,'box','off')
ax1.YAxis(1).Color = colors_Manuscript2020('rich black');
ax1.YAxis(2).Color = colors_Manuscript2020('deep carrot orange');
ax1.TickLength = [0.03,0.03];
%% [] IntermediateWhisks whisks cortical MUA
ax2 = subplot(2,3,2);
plot(data.IntermediateWhisks.meanTimeVector,data.IntermediateWhisks.meanCortMUA,'-','color',colors_Manuscript2020('rich black'),'LineWidth',1);
hold on
plot(data.IntermediateWhisks.meanTimeVector,data.IntermediateWhisks.meanCortMUA + data.IntermediateWhisks.stdCortMUA,'-','color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
plot(data.IntermediateWhisks.meanTimeVector,data.IntermediateWhisks.meanCortMUA - data.IntermediateWhisks.stdCortMUA,'-','color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
xline(0,'color','k','LineWidth',2);
ylabel('\DeltaP/P (%)')
ylim([-15,30])
yyaxis right
semilogy(data.IntermediateWhisks.meanTimeVector,data.IntermediateWhisks.meanEMG,'-','color',colors_Manuscript2020('deep carrot orange'),'LineWidth',1);
hold on
semilogy(data.IntermediateWhisks.meanTimeVector,data.IntermediateWhisks.meanEMG + data.IntermediateWhisks.stdEMG,'-','color',colors_Manuscript2020('carrot orange'),'LineWidth',0.5)
semilogy(data.IntermediateWhisks.meanTimeVector,data.IntermediateWhisks.meanEMG - data.IntermediateWhisks.stdEMG,'-','color',colors_Manuscript2020('carrot orange'),'LineWidth',0.5)
ylabel('EMG power (a.u.)','rotation',-90,'VerticalAlignment','bottom')
title('Moderate whisk cortical MUA/EMG')
xlabel('Peri-whisk time (s)')
axis square
xlim([-2,10])
ylim([0,1.5])
set(gca,'box','off')
ax2.YAxis(1).Color = colors_Manuscript2020('rich black');
ax2.YAxis(2).Color = colors_Manuscript2020('deep carrot orange');
ax2.TickLength = [0.03,0.03];
%% [] LongWhisks whisks cortical MUA
ax3 = subplot(2,3,3);
plot(data.LongWhisks.meanTimeVector,data.LongWhisks.meanCortMUA,'-','color',colors_Manuscript2020('rich black'),'LineWidth',1);
hold on
plot(data.LongWhisks.meanTimeVector,data.LongWhisks.meanCortMUA + data.LongWhisks.stdCortMUA,'-','color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
plot(data.LongWhisks.meanTimeVector,data.LongWhisks.meanCortMUA - data.LongWhisks.stdCortMUA,'-','color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
xline(0,'color','k','LineWidth',2);
ylabel('\DeltaP/P (%)')
ylim([-15,30])
yyaxis right
semilogy(data.LongWhisks.meanTimeVector,data.LongWhisks.meanEMG,'-','color',colors_Manuscript2020('deep carrot orange'),'LineWidth',1);
hold on
semilogy(data.LongWhisks.meanTimeVector,data.LongWhisks.meanEMG + data.LongWhisks.stdEMG,'-','color',colors_Manuscript2020('carrot orange'),'LineWidth',0.5)
semilogy(data.LongWhisks.meanTimeVector,data.LongWhisks.meanEMG - data.LongWhisks.stdEMG,'-','color',colors_Manuscript2020('carrot orange'),'LineWidth',0.5)
ylabel('EMG power (a.u.)','rotation',-90,'VerticalAlignment','bottom')
title('Extended whisk cortical MUA/EMG')
xlabel('Peri-whisk time (s)')
axis square
xlim([-2,10])
ylim([0,1.5])
set(gca,'box','off')
ax3.YAxis(1).Color = colors_Manuscript2020('rich black');
ax3.YAxis(2).Color = colors_Manuscript2020('deep carrot orange');
ax3.TickLength = [0.03,0.03];
%% [] Short whisks HbT
ax4 = subplot(2,3,4);
plot(data.ShortWhisks.meanTimeVector,data.ShortWhisks.meanHbT,'-','color',colors_Manuscript2020('rich black'),'LineWidth',1);
hold on
plot(data.ShortWhisks.meanTimeVector,data.ShortWhisks.meanHbT + data.ShortWhisks.stdHbT,'-','color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
plot(data.ShortWhisks.meanTimeVector,data.ShortWhisks.meanHbT - data.ShortWhisks.stdHbT,'-','color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
xline(0,'color','k','LineWidth',2);
ylabel('\Delta[HbT] (\muM)')
ylim([-5,20])
yyaxis right
semilogy(data.ShortWhisks.meanTimeVector,data.ShortWhisks.meanEMG,'-','color',colors_Manuscript2020('deep carrot orange'),'LineWidth',1);
hold on
semilogy(data.ShortWhisks.meanTimeVector,data.ShortWhisks.meanEMG + data.ShortWhisks.stdEMG,'-','color',colors_Manuscript2020('carrot orange'),'LineWidth',0.5)
semilogy(data.ShortWhisks.meanTimeVector,data.ShortWhisks.meanEMG - data.ShortWhisks.stdEMG,'-','color',colors_Manuscript2020('carrot orange'),'LineWidth',0.5)
ylabel('EMG power (a.u.)','rotation',-90,'VerticalAlignment','bottom')
title('Brief whisk \Delta[HbT]/EMG')
xlabel('Peri-whisk time (s)')
axis square
xlim([-2,10])
ylim([0,1.5])
set(gca,'box','off')
ax4.YAxis(1).Color = colors_Manuscript2020('rich black');
ax4.YAxis(2).Color = colors_Manuscript2020('deep carrot orange');
ax4.TickLength = [0.03,0.03];
%% [] Intermediate whisks HbT
ax5 = subplot(2,3,5);
plot(data.IntermediateWhisks.meanTimeVector,data.IntermediateWhisks.meanHbT,'-','color',colors_Manuscript2020('rich black'),'LineWidth',1);
hold on
plot(data.IntermediateWhisks.meanTimeVector,data.IntermediateWhisks.meanHbT + data.IntermediateWhisks.stdHbT,'-','color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
plot(data.IntermediateWhisks.meanTimeVector,data.IntermediateWhisks.meanHbT - data.IntermediateWhisks.stdHbT,'-','color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
xline(0,'color','k','LineWidth',2);
ylabel('\Delta[HbT] (\muM)')
ylim([-5,20])
yyaxis right
semilogy(data.IntermediateWhisks.meanTimeVector,data.IntermediateWhisks.meanEMG,'-','color',colors_Manuscript2020('deep carrot orange'),'LineWidth',1);
hold on
semilogy(data.IntermediateWhisks.meanTimeVector,data.IntermediateWhisks.meanEMG + data.IntermediateWhisks.stdEMG,'-','color',colors_Manuscript2020('carrot orange'),'LineWidth',0.5)
semilogy(data.IntermediateWhisks.meanTimeVector,data.IntermediateWhisks.meanEMG - data.IntermediateWhisks.stdEMG,'-','color',colors_Manuscript2020('carrot orange'),'LineWidth',0.5)
ylabel('EMG power (a.u.)','rotation',-90,'VerticalAlignment','bottom')
title('Moderate whisk \Delta[HbT]/EMG')
xlabel('Peri-whisk time (s)')
axis square
xlim([-2,10])
ylim([0,1.5])
set(gca,'box','off')
ax5.YAxis(1).Color = colors_Manuscript2020('rich black');
ax5.YAxis(2).Color = colors_Manuscript2020('deep carrot orange');
ax5.TickLength = [0.03,0.03];
%% [] Long whisks HbT
ax6 = subplot(2,3,6);
plot(data.LongWhisks.meanTimeVector,data.LongWhisks.meanHbT,'-','color',colors_Manuscript2020('rich black'),'LineWidth',1);
hold on
plot(data.LongWhisks.meanTimeVector,data.LongWhisks.meanHbT + data.LongWhisks.stdHbT,'-','color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
plot(data.LongWhisks.meanTimeVector,data.LongWhisks.meanHbT - data.LongWhisks.stdHbT,'-','color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
xline(0,'color','k','LineWidth',2);
ylabel('\Delta[HbT] (\muM)')
ylim([-5,20])
yyaxis right
semilogy(data.LongWhisks.meanTimeVector,data.LongWhisks.meanEMG,'-','color',colors_Manuscript2020('deep carrot orange'),'LineWidth',1);
hold on
semilogy(data.LongWhisks.meanTimeVector,data.LongWhisks.meanEMG + data.LongWhisks.stdEMG,'-','color',colors_Manuscript2020('carrot orange'),'LineWidth',0.5)
semilogy(data.LongWhisks.meanTimeVector,data.LongWhisks.meanEMG - data.LongWhisks.stdEMG,'-','color',colors_Manuscript2020('carrot orange'),'LineWidth',0.5)
ylabel('EMG power (a.u.)','rotation',-90,'VerticalAlignment','bottom')
title('Extended whisk \Delta[HbT]/EMG')
xlabel('Peri-whisk time (s)')
axis square
xlim([-2,10])
ylim([0,1.5])
set(gca,'box','off')
ax6.YAxis(1).Color = colors_Manuscript2020('rich black');
ax6.YAxis(2).Color = colors_Manuscript2020('deep carrot orange');
ax6.TickLength = [0.03,0.03];
%% axes positions
% %% save figure(s)
% if strcmp(saveFigs,'y') == true
%     dirpath = [rootFolder delim 'Summary Figures and Structures' delim 'MATLAB Analysis Figures' delim];
%     if ~exist(dirpath, 'dir')
%         mkdir(dirpath);
%     end
%     savefig(summaryFigure,[dirpath 'FigS3']);
%     set(summaryFigure,'PaperPositionMode','auto');
%     print('-painters','-dpdf','-fillpage',[dirpath 'FigS3'])
%     %% Text diary
%     diaryFile = [dirpath 'FigS3_Statistics.txt'];
%     if exist(diaryFile,'file') == 2
%         delete(diaryFile)
%     end
%     diary(diaryFile)
%     diary on
%     % text values
%     disp('======================================================================================================================')
%     disp('[S3] Text values for gamma/HbT changes')
%     disp('======================================================================================================================')
%     disp('----------------------------------------------------------------------------------------------------------------------')
%      % cortical MUA/LFP
%     [~,index] = max(data.ShortWhisks.meanCortMUA);
%     disp(['Brief whisk Cort gamma MUA P/P (%): ' num2str(round(data.ShortWhisks.meanCortMUA(index),1)) ' +/- ' num2str(round(data.ShortWhisks.stdCortMUA(index),1))]); disp(' ')
%     [~,index] = max(data.IntermediateWhisks.meanCortMUA);
%     disp(['Moderate whisk Cort gamma MUA P/P (%): ' num2str(round(data.IntermediateWhisks.meanCortMUA(index),1)) ' +/- ' num2str(round(data.IntermediateWhisks.stdCortMUA(index),1))]); disp(' ')
%     [~,index] = max(data.LongWhisks.meanCortMUA);
%     disp(['Extended whisk Cort gamma MUA P/P (%): ' num2str(round(data.LongWhisks.meanCortMUA(index),1)) ' +/- ' num2str(round(data.LongWhisks.stdCortMUA(index),1))]); disp(' ')
%     % cortical LFP
%     disp(['Brief whisk Cort gamma LFP P/P (%): ' num2str(round(data.ShortWhisks.mean_CortS_Gam,1)) ' +/- ' num2str(round(data.ShortWhisks.std_CortS_Gam,1))]); disp(' ')
%     disp(['Moderate whisk Cort gamma LFP P/P (%): ' num2str(round(data.IntermediateWhisks.mean_CortS_Gam,1)) ' +/- ' num2str(round(data.IntermediateWhisks.std_CortS_Gam,1))]); disp(' ')
%     disp(['Extended whisk Cort gamma LFP P/P (%): ' num2str(round(data.LongWhisks.mean_CortS_Gam,1)) ' +/- ' num2str(round(data.LongWhisks.std_CortS_Gam,1))]); disp(' ')
%     % hippocampal MUA
%     [~,index] = max(data.ShortWhisks.meanHipMUA);
%     disp(['Brief whisk Hip gamma MUA P/P (%): ' num2str(round(data.ShortWhisks.meanHipMUA(index),1)) ' +/- ' num2str(round(data.ShortWhisks.stdHipMUA(index),1))]); disp(' ')
%     [~,index] = max(data.IntermediateWhisks.meanHipMUA);
%     disp(['Moderate whisk Hip gamma MUA P/P (%): ' num2str(round(data.IntermediateWhisks.meanHipMUA(index),1)) ' +/- ' num2str(round(data.IntermediateWhisks.stdHipMUA(index),1))]); disp(' ')
%     [~,index] = max(data.LongWhisks.meanHipMUA);
%     disp(['Extended whisk Hip gamma MUA P/P (%): ' num2str(round(data.LongWhisks.meanHipMUA(index),1)) ' +/- ' num2str(round(data.LongWhisks.stdHipMUA(index),1))]); disp(' ')
%     % hipocampal LFP
%     disp(['Brief whisk Hip gamma LFP P/P (%): ' num2str(round(data.ShortWhisks.mean_HipS_Gam,1)) ' +/- ' num2str(round(data.ShortWhisks.std_HipS_Gam,1))]); disp(' ')
%     disp(['Moderate whisk Hip gamma LFP P/P (%): ' num2str(round(data.IntermediateWhisks.mean_HipS_Gam,1)) ' +/- ' num2str(round(data.IntermediateWhisks.std_HipS_Gam,1))]); disp(' ')
%     disp(['Extended whisk Hip gamma LFP P/P (%): ' num2str(round(data.LongWhisks.mean_HipS_Gam,1)) ' +/- ' num2str(round(data.LongWhisks.std_HipS_Gam,1))]); disp(' ')
%     % HbT
%     [~,index] = max(data.ShortWhisks.meanHbT);
%     disp(['Brief whisk [HbT] (uM): ' num2str(round(data.ShortWhisks.meanHbT(index),1)) ' +/- ' num2str(round(data.ShortWhisks.stdHbT(index),1))]); disp(' ')
%     [~,index] = max(data.IntermediateWhisks.meanHbT);
%     disp(['Moderate whisk [HbT] (uM): ' num2str(round(data.IntermediateWhisks.meanHbT(index),1)) ' +/- ' num2str(round(data.IntermediateWhisks.stdHbT(index),1))]); disp(' ')
%     [~,index] = max(data.LongWhisks.meanHbT);
%     disp(['Extended whisk [HbT] (uM): ' num2str(round(data.LongWhisks.meanHbT(index),1)) ' +/- ' num2str(round(data.LongWhisks.stdHbT(index),1))]); disp(' ')
%     % R/R
%     [~,index] = min(data.ShortWhisks.meanCBV);
%     disp(['Brief whisk refl R/R (%): ' num2str(round(data.ShortWhisks.meanCBV(index),1)) ' +/- ' num2str(round(data.ShortWhisks.stdCBV(index),1))]); disp(' ')
%     [~,index] = min(data.IntermediateWhisks.meanCBV);
%     disp(['Moderate whisk refl R/R (%): ' num2str(round(data.IntermediateWhisks.meanCBV(index),1)) ' +/- ' num2str(round(data.IntermediateWhisks.stdCBV(index),1))]); disp(' ')
%     [~,index] = min(data.LongWhisks.meanCBV);
%     disp(['Extended whisk refl R/R (%): ' num2str(round(data.LongWhisks.meanCBV(index),1)) ' +/- ' num2str(round(data.LongWhisks.stdCBV(index),1))]); disp(' ')
%     disp('----------------------------------------------------------------------------------------------------------------------')
%     diary off
% end

end
