function GT_CreateSingleTrialFigs_NoSleep(sleepScoringDataFile, GT_AnalysisInfo, guiParams)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Create a summary figure of each trial that was identified with at least one sleeping period that met
%            the given criteria.
%________________________________________________________________________________________________________________________
%
%   Inputs: sleepScoringDataFile (string) name of the file whose data is to be loaded.
%           GT_AnalysisInfo.mat (struct) summary structure of sleep scoring analysis.
%           guiParams.mat (struct) analysis parameters from the GUI.
%
%   Outputs: None, but saves the figure in a folder corresponding to this analysis' scoring ID.
%
%   Last Revised: March 8th, 2019
%________________________________________________________________________________________________________________________

[animalID, hem, ~, fileID] = GT_GetFileInfo(sleepScoringDataFile);
load(sleepScoringDataFile);

%% BLOCK PURPOSE: Find the sleeping times from the SleepEventData for this particular trial
% This loop creates a logical that matches the inputed FileID with all potential sleeping trials.
% for f = 1:length(GT_AnalysisInfo.(guiParams.scoringID).data.fileIDs)
%     if strcmp(GT_AnalysisInfo.(guiParams.scoringID).data.fileIDs{f,1}, fileID)
%         sleepTimeLogical{f, 1} = 1;
%     else
%         sleepTimeLogical{f, 1} = 0;
%     end
% end

% Now that we have a logical showing the sleeping events that match this specific trial, we want to pull out the sleep times
% for that specific trial
% x = 1;
% for f = 1:length(sleepTimeLogical) 
%     if sleepTimeLogical{f, 1} == 1  
%         sleepTimes{x, 1} = GT_AnalysisInfo.(guiParams.scoringID).data.binTimes{f, 1};  % Pull out the associated bin times
%         x = x + 1;
%     end
% end

%% BLOCK PURPOSE: Identify the solenoid timing and location.
% Identify the solenoid times from the ProcData file.
solenoidContra = floor(SleepScoringData.Sol.solenoidContralateral);
solenoidIpsi = floor(SleepScoringData.Sol.solenoidIpsilateral);
solenoidTail = floor(SleepScoringData.Sol.solenoidTail);
OptoStim=floor(SleepScoringData.Opto.OptoStim(1,:));
%% BLOCK PURPOSE: Load in data and apply smoothing filters.
[B, A] = butter(4, 4 / (30 / 2), 'low');
HeartRate = zeros(1,300);
HeartRate(2:298) = filtfilt(B, A, SleepScoringData.HeartRate);
HeartRate(1) = HeartRate(2);
HeartRate(299:end) = HeartRate(298);

[D, C] = butter(4, 1/ (30 / 2), 'low');
if isempty(OptoStim)
    CBV = filtfilt(D, C, SleepScoringData.normCBV(1:end - 1))*100;
else
    FlashCatch=diff(SleepScoringData.normCBV*100);
    if max(FlashCatch)>=10
        HoldRefl=SleepScoringData.normCBV;
        Flash_Points=HoldRefl>=(3*std(SleepScoringData.normCBV));
        HoldRefl(Flash_Points)=NaN;
        [Interp_Data,Interp_Points]=fillmissing(HoldRefl,'spline');
        Interp_Refl=Interp_Data;
        CBV = filtfilt(D, C, Interp_Refl(1:end - 1))*100;
    else
        CBV = filtfilt(D, C, SleepScoringData.normCBV(1:end - 1))*100;
    end
end
timeVec = (1:length(CBV))/30;
delta = filtfilt(D, C, SleepScoringData.normDeltaBandPower);
theta = filtfilt(D, C, SleepScoringData.normThetaBandPower);
gamma = filtfilt(D, C, SleepScoringData.normGammaBandPower);
ballVelocity = SleepScoringData.ballVelocity;
binBallVelocity = SleepScoringData.binBallVelocity;

 sleepPoints=[];
% for k = 1:length(sleepTimes)
%     temp = sleepTimes{k};
%     sleepPoints = horzcat(sleepPoints, temp);
% end

%% Yvals for behavior Indices
ball_YVals = 1.10*max(CBV)*ones(size(binBallVelocity));
solenoidContra_YVals = 1.20*max(CBV)*ones(size(solenoidContra));
solenoidIpsi_YVals = 1.20*max(CBV)*ones(size(solenoidIpsi));
solenoidTail_YVals = 1.20*max(CBV)*ones(size(solenoidTail));
sleeping_YVal = 1.30*max(CBV)*ones(size(sleepPoints));
OptoStim_YVals=1.20*max(CBV)*ones(size(OptoStim));
%% Figure
singleSleepTrial = figure;
ax1 = subplot(5,1,1);
plot(timeVec, ballVelocity, 'LineWidth', 1, 'color', GT_colors('ash grey'));
hold on;
axis tight
ylabel('a.u.');
yyaxis right
ylim([6 15]);
plot(1:length(HeartRate), HeartRate, 'LineWidth', 1, 'color', GT_colors('carrot orange'));
ylabel('Heart Rate (Hz)');
animalname=strrep(animalID,'_',' ');
thefile=strrep(fileID,'_', ' ');
title([animalname ' ' thefile ' Sleep Scoring']);
set(gca, 'Ticklength', [0 0])
legend('ball velocity', 'heart rate', 'Location', 'NorthEast')

ax2 = subplot(5,1,2:3);
yyaxis right
plot(timeVec, delta, '-', 'LineWidth', 1, 'color', GT_colors('sapphire'));
hold on
plot(timeVec, theta, '-', 'LineWidth', 1, 'color', GT_colors('harvest gold'));
plot(timeVec, gamma, '-', 'LineWidth', 1, 'color', GT_colors('royal purple'));
ylim([-2 15])
ylabel('Normalized Power')

yyaxis left
plot(timeVec, CBV, 'color', GT_colors('Dark Candy Apple Red'), 'LineWidth', 2);
hold on;
scatter(sleepPoints,sleeping_YVal, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', GT_colors('rich electric blue'))
scatter(solenoidContra, solenoidContra_YVals, 'v', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', GT_colors('raspberry'));
scatter(solenoidIpsi, solenoidIpsi_YVals, 'v', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', GT_colors('teal blue'));
scatter(solenoidTail, solenoidTail_YVals, 'v', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', GT_colors('rose pink'));
scatter(OptoStim,OptoStim_YVals,'v','MarkerEdgeColor','k','MarkerFaceColor',GT_colors('baby blue eyes'));

title('Normalized CBV reflectance and individual neural bands of interest');
ylabel('Reflectance (%)','Color', GT_colors('Dark Candy Apple Red'))
if ~isempty(solenoidContra_YVals)
ylim([(min(CBV)+min(CBV)*0.25),max(solenoidContra_YVals)+(max(solenoidContra_YVals)*0.1)]);
end
 
legend('CBV', 'sleep epochs', 'contra stim', 'ipsi stim', 'tail stim','Opto stim', 'delta power', 'theta power', 'gamma power', 'Location', 'NorthEast')
set(gca, 'Ticklength', [0 0]);
set(gca,'YColor', GT_colors('Dark Candy Apple Red'));

ax3 = subplot(5,1,4:5);
imagesc(SleepScoringData.Spectrograms.FiveSec.T5, SleepScoringData.Spectrograms.FiveSec.F5, SleepScoringData.Spectrograms.FiveSec.S5_Norm)
%imagesc(SleepScoringData.Spectrograms.OneSec.T1, SleepScoringData.Spectrograms.OneSec.F1, SleepScoringData.Spectrograms.OneSec.S1_Norm)
axis xy
caxis([-1 2])
title('Normalized spectrogram - caxis default [-1:2]')
ylabel('Frequency (Hz)')
xlabel('Time (sec)')
linkaxes([ax1 ax2 ax3], 'x')

%% Save the file to directory.
guiParams.scoringID='SleepParams_Test001';
dirpath = ([cd '/Sleep Summary Figs/' guiParams.scoringID '/']);
savefig(singleSleepTrial, [dirpath animalID '_' hem '_' fileID '_SingleTrialSummaryFig']);%[dirpath animalID '_' hem '_' fileID '_SingleTrialSummaryFig']);

end