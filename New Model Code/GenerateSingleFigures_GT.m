function [figHandle] = GenerateSingleFigures_GT(RawData)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: Generate figure for visualized sleep scoring
%________________________________________________________________________________________________________________________

%% load/process data
% ball velocity (raw)
trialDuration = round(length(RawData.vBall)/RawData.an_fs);
ballVelocity = RawData.vBall(1:trialDuration*RawData.an_fs);
anTimeVec = (1:length(ballVelocity))/RawData.an_fs;

% hemodynamics
[B,A] = butter(3,1/(RawData.dal_fr/2),'low');
barrelsRefl = filtfilt(B,A,RawData.IOS.barrels.CBVrefl(1:trialDuration*RawData.dal_fr));
dsTimeVec = (1:length(barrelsRefl))/RawData.dal_fr;
% Hippocampal LFP

%% Figure
figHandle = figure;
ax1 = subplot(2,1,1);
plot(anTimeVec,ballVelocity,'LineWidth',1,'color','k');

ax2 = subplot(2,1,2);
plot(dsTimeVec,barrelsRefl,'LineWidth',1,'color','r');

linkaxes([ax1,ax2],'x')

end
