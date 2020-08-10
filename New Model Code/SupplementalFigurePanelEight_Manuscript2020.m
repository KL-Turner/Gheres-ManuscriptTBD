function [] = SupplementalFigurePanelEight_Manuscript2020(rootFolder,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: 
%________________________________________________________________________________________________________________________

IOSanimalIDs = {'T99','T101','T102','T103','T105','T108','T109','T110','T111','T119','T120','T121','T122','T123'};
solenoidNames = {'LPadSol','RPadSol','AudSol'};
compDataTypes = {'Ipsi','Contra','Auditory'};
dataTypes = {'adjLH','adjRH'};
%% cd through each animal's directory and extract the appropriate analysis results
for a = 1:length(IOSanimalIDs)
    animalID = IOSanimalIDs{1,a};
    for b = 1:length(dataTypes)
        dataType = dataTypes{1,b};
        for d = 1:length(solenoidNames)
            solenoidName = solenoidNames{1,d};
            if a == 1
                data.(dataType).(solenoidName).HbT = [];
                data.(dataType).(solenoidName).CBV = [];
                data.(dataType).(solenoidName).cortMUA = [];
                data.(dataType).(solenoidName).hipMUA = [];
                data.(dataType).(solenoidName).timeVector = [];
                data.(dataType).(solenoidName).cortS = [];
                data.(dataType).(solenoidName).hipS = [];
                data.(dataType).(solenoidName).T = [];
                data.(dataType).(solenoidName).F = [];
            end
%             if isfield(AnalysisResults.(animalID).EvokedAvgs.nremStim,dataType) == true
            data.(dataType).(solenoidName).HbT = horzcat(data.(dataType).(solenoidName).HbT,AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoidName).CBV_HbT.HbT');
            data.(dataType).(solenoidName).CBV = horzcat(data.(dataType).(solenoidName).CBV,AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoidName).CBV.CBV');
            data.(dataType).(solenoidName).cortMUA = horzcat(data.(dataType).(solenoidName).cortMUA,AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoidName).MUA.corticalData');
            data.(dataType).(solenoidName).hipMUA = horzcat(data.(dataType).(solenoidName).hipMUA,AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoidName).MUA.hippocampalData');
            data.(dataType).(solenoidName).timeVector = horzcat(data.(dataType).(solenoidName).timeVector,AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoidName).timeVector');
            data.(dataType).(solenoidName).cortS = cat(3,data.(dataType).(solenoidName).cortS,AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoidName).LFP.corticalS);
            data.(dataType).(solenoidName).hipS = cat(3,data.(dataType).(solenoidName).hipS,AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoidName).LFP.hippocampalS);
            data.(dataType).(solenoidName).T = horzcat(data.(dataType).(solenoidName).T,AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoidName).LFP.T');
            data.(dataType).(solenoidName).F = horzcat(data.(dataType).(solenoidName).F,AnalysisResults.(animalID).EvokedAvgs.nremStim.(dataType).(solenoidName).LFP.F');
        end
    end
end
% concatenate the data from the contra and ipsi data
data.Contra.HbT = cat(2,data.adjLH.RPadSol.HbT,data.adjRH.LPadSol.HbT);
data.Contra.CBV = cat(2,data.adjLH.RPadSol.CBV,data.adjRH.LPadSol.CBV);
data.Contra.cortMUA = cat(2,data.adjLH.RPadSol.cortMUA,data.adjRH.LPadSol.cortMUA);
data.Contra.hipMUA = data.adjRH.RPadSol.hipMUA;
data.Contra.timeVector = cat(2,data.adjLH.RPadSol.timeVector,data.adjRH.LPadSol.timeVector);
data.Contra.cortS = cat(3,data.adjLH.RPadSol.cortS,data.adjRH.LPadSol.cortS);
data.Contra.hipS = data.adjRH.RPadSol.hipS;
data.Contra.T = cat(2,data.adjLH.RPadSol.T,data.adjRH.LPadSol.T);
data.Contra.F = cat(2,data.adjLH.RPadSol.F,data.adjRH.LPadSol.F);
data.Ipsi.HbT = cat(2,data.adjLH.LPadSol.HbT,data.adjRH.RPadSol.HbT);
data.Ipsi.CBV = cat(2,data.adjLH.LPadSol.CBV,data.adjRH.RPadSol.CBV);
data.Ipsi.cortMUA = cat(2,data.adjLH.LPadSol.cortMUA,data.adjRH.RPadSol.cortMUA);
data.Ipsi.hipMUA = data.adjRH.LPadSol.hipMUA;
data.Ipsi.timeVector = cat(2,data.adjLH.LPadSol.timeVector,data.adjRH.RPadSol.timeVector);
data.Ipsi.cortS = cat(3,data.adjLH.LPadSol.cortS,data.adjRH.RPadSol.cortS);
data.Ipsi.hipS = data.adjRH.LPadSol.hipS;
data.Ipsi.T = cat(2,data.adjLH.LPadSol.T,data.adjRH.RPadSol.T);
data.Ipsi.F = cat(2,data.adjLH.LPadSol.F,data.adjRH.RPadSol.F);
data.Auditory.HbT = cat(2,data.adjLH.AudSol.HbT,data.adjRH.AudSol.HbT);
data.Auditory.CBV = cat(2,data.adjLH.AudSol.CBV,data.adjRH.AudSol.CBV);
data.Auditory.cortMUA = cat(2,data.adjLH.AudSol.cortMUA,data.adjRH.AudSol.cortMUA);
data.Auditory.hipMUA = data.adjRH.AudSol.hipMUA;
data.Auditory.timeVector = cat(2,data.adjLH.AudSol.timeVector,data.adjRH.AudSol.timeVector);
data.Auditory.cortS = cat(3,data.adjLH.AudSol.cortS,data.adjRH.AudSol.cortS);
data.Auditory.hipS = data.adjRH.AudSol.hipS;
data.Auditory.T = cat(2,data.adjLH.AudSol.T,data.adjRH.AudSol.T);
data.Auditory.F = cat(2,data.adjLH.AudSol.F,data.adjRH.AudSol.F);
% take the averages of each field through the proper dimension
for f = 1:length(compDataTypes)
    compDataType = compDataTypes{1,f};
    data.(compDataType).mean_HbT = mean(data.(compDataType).HbT,2);
    data.(compDataType).std_HbT = std(data.(compDataType).HbT,0,2);
    data.(compDataType).mean_CBV = mean(data.(compDataType).CBV,2);
    data.(compDataType).std_CBV = std(data.(compDataType).CBV,0,2);
    data.(compDataType).mean_CortMUA = mean(data.(compDataType).cortMUA,2);
    data.(compDataType).std_CortMUA = std(data.(compDataType).cortMUA,0,2);
    data.(compDataType).mean_HipMUA = mean(data.(compDataType).hipMUA,2);
    data.(compDataType).std_HipMUA = std(data.(compDataType).hipMUA,0,2);
    data.(compDataType).mean_timeVector = mean(data.(compDataType).timeVector,2);
    data.(compDataType).mean_CortS = mean(data.(compDataType).cortS,3).*100;
    data.(compDataType).mean_HipS = mean(data.(compDataType).hipS,3).*100;
    data.(compDataType).mean_T = mean(data.(compDataType).T,2);
    data.(compDataType).mean_F = mean(data.(compDataType).F,2);
end
%% summary figure(s)
summaryFigure = figure;
sgtitle({'Supplemental Figure Panel 8 - Turner Manuscript 2020','NREM stimulations'})
%% [A] Cortical MUA Contra Stim
ax1 = subplot(6,3,1);
plot(data.Contra.mean_timeVector,data.Contra.mean_CortMUA,'color',colors_Manuscript2020('rich black'),'LineWidth',1)
hold on
plot(data.Contra.mean_timeVector,data.Contra.mean_CortMUA + data.Contra.std_CortMUA,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
plot(data.Contra.mean_timeVector,data.Contra.mean_CortMUA - data.Contra.std_CortMUA,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
title('[A] Contra stim cortical MUA')
ylabel('\DeltaP/P (%)')
xlabel('Peri-stimuls time (s)')  
axis square
set(gca,'box','off')
ax1.TickLength = [0.03,0.03];
%% [B] Cortical MUA Ispi Stim
ax2 = subplot(6,3,2);
plot(data.Ipsi.mean_timeVector,data.Ipsi.mean_CortMUA,'color',colors_Manuscript2020('rich black'),'LineWidth',1)
hold on
plot(data.Ipsi.mean_timeVector,data.Ipsi.mean_CortMUA + data.Ipsi.std_CortMUA,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
plot(data.Ipsi.mean_timeVector,data.Ipsi.mean_CortMUA - data.Ipsi.std_CortMUA,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
title('[B] Ipsi stim cortical MUA')
ylabel('\DeltaP/P (%)')
xlabel('Peri-stimuls time (s)')  
axis square
set(gca,'box','off')
ax2.TickLength = [0.03,0.03];
%% [C] Cortical MUA Auditory Stim
ax3 = subplot(6,3,3);
plot(data.Auditory.mean_timeVector,data.Auditory.mean_CortMUA,'color',colors_Manuscript2020('rich black'),'LineWidth',1)
hold on
plot(data.Auditory.mean_timeVector,data.Auditory.mean_CortMUA + data.Auditory.std_CortMUA,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
plot(data.Auditory.mean_timeVector,data.Auditory.mean_CortMUA - data.Auditory.std_CortMUA,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
title('[C] Aud stim cortical MUA')
ylabel('\DeltaP/P (%)')
xlabel('Peri-stimuls time (s)')  
axis square
set(gca,'box','off')
ax3.TickLength = [0.03,0.03];
%% [D] Cortical LFP Contra Stim
ax4 = subplot(6,3,4);
imagesc(data.Contra.mean_T,data.Contra.mean_F,data.Contra.mean_CortS)
title('[D] Contra stim cortical LFP')
ylabel('Freq (Hz)')
xlabel('Peri-stimuls time (s)')  
c4 = colorbar;
ylabel(c4,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
caxis([-50,75]) 
axis square
axis xy
set(gca,'box','off')
ax4.TickLength = [0.03,0.03];
%% [E] Cortical LFP Ispi Stim
ax5 = subplot(6,3,5);
imagesc(data.Ipsi.mean_T,data.Ipsi.mean_F,data.Ipsi.mean_CortS)
title('[E] Ipsi stim cortical LFP')
ylabel('Freq (Hz)')
xlabel('Peri-stimuls time (s)')  
c5 = colorbar;
ylabel(c5,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
caxis([-50,75])  
axis square
axis xy
set(gca,'box','off')
ax5.TickLength = [0.03,0.03];
%% [F] Cortical LFP Auditory Stim
ax6 = subplot(6,3,6);
imagesc(data.Auditory.mean_T,data.Auditory.mean_F,data.Auditory.mean_CortS)
title('[F] Aud stim cortical LFP')
ylabel('Freq (Hz)')
xlabel('Peri-stimuls time (s)')  
c6 = colorbar;
ylabel(c6,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
caxis([-50,75])  
axis square
axis xy
set(gca,'box','off')
ax6.TickLength = [0.03,0.03];
%% G] Hippocampal MUA Contra Stim
ax7 = subplot(6,3,7);
plot(data.Contra.mean_timeVector,data.Contra.mean_HipMUA,'color',colors_Manuscript2020('rich black'),'LineWidth',1)
hold on
plot(data.Contra.mean_timeVector,data.Contra.mean_HipMUA + data.Contra.std_HipMUA,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
plot(data.Contra.mean_timeVector,data.Contra.mean_HipMUA - data.Contra.std_HipMUA,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
title('[G] Contra stim hippocampal MUA')
ylabel('\DeltaP/P (%)')
xlabel('Peri-stimuls time (s)')  
axis square
set(gca,'box','off')
ax7.TickLength = [0.03,0.03];
%% [H] Hippocampal MUA Ispi Stim
ax8 = subplot(6,3,8);
plot(data.Ipsi.mean_timeVector,data.Ipsi.mean_HipMUA,'color',colors_Manuscript2020('rich black'),'LineWidth',1)
hold on
plot(data.Ipsi.mean_timeVector,data.Ipsi.mean_HipMUA + data.Ipsi.std_HipMUA,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
plot(data.Ipsi.mean_timeVector,data.Ipsi.mean_HipMUA - data.Ipsi.std_HipMUA,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
title('[H] Ipsi stim hippocampal MUA')
ylabel('\DeltaP/P (%)')
xlabel('Peri-stimuls time (s)')  
axis square
set(gca,'box','off')
ax8.TickLength = [0.03,0.03];
%% [I] Hippocampal MUA Auditory Stim
ax9 = subplot(6,3,9);
plot(data.Auditory.mean_timeVector,data.Auditory.mean_HipMUA,'color',colors_Manuscript2020('rich black'),'LineWidth',1)
hold on
plot(data.Auditory.mean_timeVector,data.Auditory.mean_HipMUA + data.Auditory.std_HipMUA,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
plot(data.Auditory.mean_timeVector,data.Auditory.mean_HipMUA - data.Auditory.std_HipMUA,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
title('[I] Aud stim hippocampal MUA')
ylabel('\DeltaP/P (%)')
xlabel('Peri-stimuls time (s)')  
axis square
set(gca,'box','off')
ax9.TickLength = [0.03,0.03];
%% [J] Hippocampal LFP Contra Stim
ax10 = subplot(6,3,10);
imagesc(data.Contra.mean_T,data.Contra.mean_F,data.Contra.mean_HipS)
title('[J] Contra stim hippocampal LFP')
ylabel('Freq (Hz)')
xlabel('Peri-stimuls time (s)')  
c10 = colorbar;
ylabel(c10,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
caxis([-50,75])  
axis square
axis xy
set(gca,'box','off')
ax10.TickLength = [0.03,0.03];
%% [K] Hippocampal LFP Ispi Stim
ax11 = subplot(6,3,11);
imagesc(data.Ipsi.mean_T,data.Ipsi.mean_F,data.Ipsi.mean_HipS)
title('[K] Ipsi stim hippocampal LFP')
ylabel('Freq (Hz)')
xlabel('Peri-stimuls time (s)')  
c11 = colorbar;
ylabel(c11,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
caxis([-50,75])  
axis square
axis xy
set(gca,'box','off')
ax11.TickLength = [0.03,0.03];
%% [L] Hippocampal LFP Auditory Stim
ax12 = subplot(6,3,12);
imagesc(data.Auditory.mean_T,data.Auditory.mean_F,data.Auditory.mean_HipS)
title('[L] Aud stim hippocampal LFP')
ylabel('Freq (Hz)')
xlabel('Peri-stimuls time (s)')  
c12 = colorbar;
ylabel(c12,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
caxis([-50,75])  
axis square
axis xy
set(gca,'box','off')
ax12.TickLength = [0.03,0.03];
%% [M] CBV HbT Contra Stim
ax13 = subplot(6,3,13);
plot(data.Contra.mean_timeVector,data.Contra.mean_HbT,'color',colors_Manuscript2020('rich black'),'LineWidth',1)
hold on
plot(data.Contra.mean_timeVector,data.Contra.mean_HbT + data.Contra.std_HbT,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
plot(data.Contra.mean_timeVector,data.Contra.mean_HbT - data.Contra.std_HbT,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
title('[M] Contra stim \DeltaHbT (\muM)')
ylabel('\DeltaHbT (\muM)')
xlabel('Peri-stimuls time (s)')  
axis square
set(gca,'box','off')
ax13.TickLength = [0.03,0.03];
%% [N] CBV HbT Ispi Stim
ax14 = subplot(6,3,14);
plot(data.Ipsi.mean_timeVector,data.Ipsi.mean_HbT,'color',colors_Manuscript2020('rich black'),'LineWidth',1)
hold on
plot(data.Ipsi.mean_timeVector,data.Ipsi.mean_HbT + data.Ipsi.std_HbT,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
plot(data.Ipsi.mean_timeVector,data.Ipsi.mean_HbT - data.Ipsi.std_HbT,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
title('[N] Ipsi stim \DeltaHbT (\muM)')
ylabel('\DeltaHbT (\muM)')
xlabel('Peri-stimuls time (s)')  
axis square
set(gca,'box','off')
ax14.TickLength = [0.03,0.03];
%% [O] CBV HbT Auditory Stim
ax15 = subplot(6,3,15);
plot(data.Auditory.mean_timeVector,data.Auditory.mean_HbT,'color',colors_Manuscript2020('rich black'),'LineWidth',1)
hold on
plot(data.Auditory.mean_timeVector,data.Auditory.mean_HbT + data.Auditory.std_HbT,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
plot(data.Auditory.mean_timeVector,data.Auditory.mean_HbT - data.Auditory.std_HbT,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
title('[O] Aud stim \DeltaHbT (\muM)')
ylabel('\DeltaHbT (\muM)')
xlabel('Peri-stimuls time (s)')  
axis square
set(gca,'box','off')
ax15.TickLength = [0.03,0.03];
%% [P] CBV Refl Contra Stim
ax16 = subplot(6,3,16);
plot(data.Contra.mean_timeVector,data.Contra.mean_CBV,'color',colors_Manuscript2020('rich black'),'LineWidth',1)
hold on
plot(data.Contra.mean_timeVector,data.Contra.mean_CBV + data.Contra.std_CBV,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
plot(data.Contra.mean_timeVector,data.Contra.mean_CBV - data.Contra.std_CBV,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
title('[P] Contra stim reflectance')
ylabel('\DeltaR/R (%)')
xlabel('Peri-stimuls time (s)')  
axis square
set(gca,'box','off')
ax16.TickLength = [0.03,0.03];
%% [Q] CBV Refl Ispi Stim
ax17 = subplot(6,3,17);
plot(data.Ipsi.mean_timeVector,data.Ipsi.mean_CBV,'color',colors_Manuscript2020('rich black'),'LineWidth',1)
hold on
plot(data.Ipsi.mean_timeVector,data.Ipsi.mean_CBV + data.Ipsi.std_CBV,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
plot(data.Ipsi.mean_timeVector,data.Ipsi.mean_CBV - data.Ipsi.std_CBV,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
title('[Q] Ipsi stim reflectance')
ylabel('\DeltaR/R (%)')
xlabel('Peri-stimuls time (s)')  
axis square
set(gca,'box','off')
ax17.TickLength = [0.03,0.03];
%% [R] CBV Refl Auditory Stim
ax18 = subplot(6,3,18);
plot(data.Auditory.mean_timeVector,data.Auditory.mean_CBV,'color',colors_Manuscript2020('rich black'),'LineWidth',1)
hold on
plot(data.Auditory.mean_timeVector,data.Auditory.mean_CBV + data.Auditory.std_CBV,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
plot(data.Auditory.mean_timeVector,data.Auditory.mean_CBV - data.Auditory.std_CBV,'color',colors_Manuscript2020('battleship grey'),'LineWidth',0.5)
title('[R] Aud stim reflectance')
ylabel('\DeltaR/R (%)')
xlabel('Peri-stimuls time (s)')  
axis square
set(gca,'box','off')
ax18.TickLength = [0.03,0.03];
%% adjust and link axes
linkaxes([ax1,ax2,ax3,ax7,ax8,ax9],'xy')
linkaxes([ax4,ax5,ax6,ax10,ax11,ax12],'xy')
linkaxes([ax13,ax14,ax15],'xy')
linkaxes([ax16,ax17,ax18],'xy')
ax1Pos = get(ax1,'position');
ax2Pos = get(ax2,'position');
ax3Pos = get(ax3,'position');
ax4Pos = get(ax4,'position');
ax5Pos = get(ax5,'position');
ax6Pos = get(ax6,'position');
ax10Pos = get(ax10,'position');
ax11Pos = get(ax11,'position');
ax12Pos = get(ax12,'position');
ax4Pos(3:4) = ax1Pos(3:4);
ax5Pos(3:4) = ax2Pos(3:4);
ax6Pos(3:4) = ax3Pos(3:4);
ax10Pos(3:4) = ax1Pos(3:4);
ax11Pos(3:4) = ax2Pos(3:4);
ax12Pos(3:4) = ax3Pos(3:4);
set(ax4,'position',ax4Pos);
set(ax5,'position',ax5Pos);
set(ax6,'position',ax6Pos);
set(ax10,'position',ax10Pos);
set(ax11,'position',ax11Pos);
set(ax12,'position',ax12Pos);
%% save figure(s)
dirpath = [rootFolder '\Summary Figures and Structures\'];
if ~exist(dirpath,'dir')
    mkdir(dirpath);
end
savefig(summaryFigure,[dirpath 'Supplemental Figure Panel 8']);
set(summaryFigure,'PaperPositionMode','auto');
print('-painters','-dpdf','-fillpage',[dirpath 'Supplemental Figure Panel 8'])

end

