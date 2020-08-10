function [figHandle] = GenerateSingleFigures_GT(samplingRate,ballVelocity,EMG,dHbT,SpecData)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: Generate figure for visualized sleep scoring
%________________________________________________________________________________________________________________________

%% prepare data
trialDuration = round(length(ballVelocity)/samplingRate);
timeVec = (1:length(ballVelocity))/samplingRate;
[B,A] = butter(3,1/(samplingRate/2),'low');
% ball velocity - apply any extra processing or filters
ballVelocity = ballVelocity(1:trialDuration*samplingRate); 
% EMG - apply any extra processing or filters
EMG = log(EMG(1:trialDuration*samplingRate)); 
% change in total hemoglobin
procHbT = filtfilt(B,A,dHbT(1:trialDuration*samplingRate));
% hippocampal LFP
S = SpecData.S5_Norm*100;
T = SpecData.T5;
F = SpecData.F5;

%% Figure
figHandle = figure;
% ball velocity and EMG
ax1 = subplot(3,1,1);
yyaxis left
plot(timeVec,ballVelocity,'LineWidth',1,'color',colors_GT('sapphire'));
ylabel('Ball velocity')
yyaxis right
plot(timeVec,EMG,'LineWidth',1,'color',colors_GT('deep carrot orange'));
ylabel('EMG')
% dHbT
ax2 = subplot(3,1,2);
plot(timeVec,procHbT,'LineWidth',1,'color',colors_GT('dark candy apple red'));
ylabel('\DeltaHbT (\muM)')
% hippocampal spec
ax3 = subplot(3,1,3);
SemiLogImageSC_GT(T,F,S,'y')
c8 = colorbar;
ylabel(c8,'\DeltaP/P (%)')
caxis([-100,200])
xlabel('Time (s)')
ylabel({'Hippocampal LFP';'Frequency (Hz)'})
xlim([0,trialDuration])
set(gca,'TickLength',[0,0])
set(gca,'box','off')
% align axes in position after colorbar
ax1Pos = get(ax1,'position');
ax2Pos = get(ax2,'position');
ax3Pos = get(ax3,'position');
ax2Pos(3:4) = ax1Pos(3:4);
ax3Pos(3:4) = ax1Pos(3:4);
set(ax2,'position',ax2Pos);
set(ax3,'position',ax3Pos);
linkaxes([ax1,ax2],'x')

end
