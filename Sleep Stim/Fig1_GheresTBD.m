function [AnalysisResults] = Fig1_GheresTBD(rootFolder,saveFigs,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Generate temporary supplemental figure panel for Gheres (TBD)
%________________________________________________________________________________________________________________________

colorRfcAwake = [(0/256),(64/256),(64/256)];
colorRfcNREM = [(0/256),(174/256),(239/256)];
colorRfcREM = [(190/256),(30/256),(45/256)];
%% Fig. 1
summaryFigure = figure('Name','Fig1 (a-r)'); %#ok<*NASGU>
sgtitle('Gheres et al. TBD')
%% [1a top] Awake Cortical LFP Contra Stim
ax1 = subplot(2,4,1);
imagesc(AnalysisResults.Awake.T,AnalysisResults.Awake.F,AnalysisResults.Awake.cortLFP)
title('[S1a] Awake Contra stim cortical LFP')
ylabel('Freq (Hz)')
xlabel('Peri-stimulus time (s)')
caxis([-50,100])
xlim([-2,5])
ylim([1,100])
axis square
axis xy
set(gca,'box','off')
ax1.TickLength = [0.03,0.03];
%% [1a bottom] Awake CBV HbT Contra Stim
ax2 = subplot(2,4,5);
plot(AnalysisResults.Awake.timeVector,AnalysisResults.Awake.meanHbT,'color',colorRfcAwake,'LineWidth',2)
hold on
plot(AnalysisResults.Awake.timeVector,AnalysisResults.Awake.meanHbT + AnalysisResults.Awake.stdHbT,'color',colorRfcAwake,'LineWidth',0.5)
plot(AnalysisResults.Awake.timeVector,AnalysisResults.Awake.meanHbT - AnalysisResults.Awake.stdHbT,'color',colorRfcAwake,'LineWidth',0.5)
title('[S1a] Awake Contra stim \Delta[HbT] (\muM)')
ylabel('\Delta[HbT] (\muM)')
xlabel('Peri-stimulus time (s)')
xlim([-2,5])
ylim([-30,25])
axis square
set(gca,'box','off')
ax2.TickLength = [0.03,0.03];
%% [1b top] NREM Cortical LFP Contra Stim
ax3 = subplot(2,4,2);
imagesc(AnalysisResults.NREM.T,AnalysisResults.NREM.F,AnalysisResults.NREM.cortLFP)
title('[S1b] NREM Contra stim cortical LFP')
ylabel('Freq (Hz)')
xlabel('Peri-stimulus time (s)')
caxis([-50,100])
xlim([-2,5])
ylim([1,100])
axis square
axis xy
set(gca,'box','off')
ax3.TickLength = [0.03,0.03];
%% [1b bottom] NREM CBV HbT Contra Stim
ax4 = subplot(2,4,6);
plot(AnalysisResults.NREM.timeVector,AnalysisResults.NREM.meanHbT,'color',colorRfcNREM,'LineWidth',2)
hold on
plot(AnalysisResults.NREM.timeVector,AnalysisResults.NREM.meanHbT + AnalysisResults.NREM.stdHbT,'color',colorRfcNREM,'LineWidth',0.5)
plot(AnalysisResults.NREM.timeVector,AnalysisResults.NREM.meanHbT - AnalysisResults.NREM.stdHbT,'color',colorRfcNREM,'LineWidth',0.5)
title('[S1b] NREM Contra stim \Delta[HbT] (\muM)')
ylabel('\Delta[HbT] (\muM)')
xlabel('Peri-stimulus time (s)')
xlim([-2,5])
ylim([-30,25])
axis square
set(gca,'box','off')
ax4.TickLength = [0.03,0.03];
%% [1c top] REM Cortical LFP Contra Stim
ax5 = subplot(2,4,3);
imagesc(AnalysisResults.REM.T,AnalysisResults.REM.F,AnalysisResults.REM.cortLFP)
title('[S1c] REM Contra stim cortical LFP')
ylabel('Freq (Hz)')
xlabel('Peri-stimulus time (s)')
c5 = colorbar;
ylabel(c5,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
caxis([-50,100])
xlim([-2,5])
ylim([1,100])
axis square
axis xy
set(gca,'box','off')
ax5.TickLength = [0.03,0.03];
%% [1c bottom] REM CBV HbT Contra Stim
ax6 = subplot(2,4,7);
plot(AnalysisResults.REM.timeVector,AnalysisResults.REM.meanHbT,'color',colorRfcREM,'LineWidth',2)
hold on
plot(AnalysisResults.REM.timeVector,AnalysisResults.REM.meanHbT + AnalysisResults.REM.stdHbT,'color',colorRfcREM,'LineWidth',0.5)
plot(AnalysisResults.REM.timeVector,AnalysisResults.REM.meanHbT - AnalysisResults.REM.stdHbT,'color',colorRfcREM,'LineWidth',0.5)
title('[S1c] REM Contra stim \Delta[HbT] (\muM)')
ylabel('\Delta[HbT] (\muM)')
xlabel('Peri-stimulus time (s)')
xlim([-2,5])
ylim([-30,25])
axis square
set(gca,'box','off')
ax6.TickLength = [0.03,0.03];
%% [1d] Comb states CBV HbT Contra Stim
ax7 = subplot(2,4,[4,8]);
p1 = plot(AnalysisResults.Awake.timeVector,AnalysisResults.Awake.meanHbT,'color',colorRfcAwake,'LineWidth',2);
hold on
plot(AnalysisResults.Awake.timeVector,AnalysisResults.Awake.meanHbT + AnalysisResults.Awake.stdHbT,'color',colorRfcAwake,'LineWidth',0.5)
plot(AnalysisResults.Awake.timeVector,AnalysisResults.Awake.meanHbT - AnalysisResults.Awake.stdHbT,'color',colorRfcAwake,'LineWidth',0.5)
plot(AnalysisResults.NREM.timeVector,AnalysisResults.NREM.meanHbT,'color',colorRfcNREM,'LineWidth',2)
plot(AnalysisResults.NREM.timeVector,AnalysisResults.NREM.meanHbT + AnalysisResults.NREM.stdHbT,'color',colorRfcNREM,'LineWidth',0.5)
plot(AnalysisResults.NREM.timeVector,AnalysisResults.NREM.meanHbT - AnalysisResults.NREM.stdHbT,'color',colorRfcNREM,'LineWidth',0.5)
plot(AnalysisResults.REM.timeVector,AnalysisResults.REM.meanHbT,'color',colorRfcREM,'LineWidth',2)
plot(AnalysisResults.REM.timeVector,AnalysisResults.REM.meanHbT + AnalysisResults.REM.stdHbT,'color',colorRfcREM,'LineWidth',0.5)
plot(AnalysisResults.REM.timeVector,AnalysisResults.REM.meanHbT - AnalysisResults.REM.stdHbT,'color',colorRfcREM,'LineWidth',0.5)
title('[S1d] Contra stim \Delta[HbT] (\muM)')
ylabel('\Delta[HbT] (\muM)')
xlabel('Peri-stimulus time (s)')
xlim([-2,5])
ylim([-30,25])
axis square
set(gca,'box','off')
ax7.TickLength = [0.03,0.03];
%% adjust and link axes
ax1Pos = get(ax1,'position');
ax3Pos = get(ax3,'position');
ax5Pos = get(ax5,'position');
ax2Pos = get(ax2,'position');
ax4Pos = get(ax4,'position');
ax6Pos = get(ax6,'position');
ax1Pos(3:4) = ax2Pos(3:4);
ax3Pos(3:4) = ax4Pos(3:4);
ax5Pos(3:4) = ax6Pos(3:4);
set(ax1,'position',ax1Pos);
set(ax3,'position',ax3Pos);
set(ax5,'position',ax5Pos);
%% save figure(s)
if strcmp(saveFigs,'y') == true
    dirpath = [rootFolder '\Gheres Summary Figures and Structures\MATLAB Analysis Figures\'];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(summaryFigure,[dirpath 'Fig1']);
    set(summaryFigure,'PaperPositionMode','auto');
    print('-painters','-dpdf','-fillpage',[dirpath 'Fig1'])
end
