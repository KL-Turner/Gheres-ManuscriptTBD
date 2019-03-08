function GT_CreateSingleTrialFigs(sleepScoringDataFile, GT_AnalysisInfo, guiParams)

[animalID, hem, ~, fileID] = GT_GetFileInfo(sleepScoringDataFile);
load(sleepScoringDataFile);

%% BLOCK PURPOSE: Find the sleeping times from the SleepEventData for this particular trial
% This loop creates a logical that matches the inputed FileID with all potential sleeping trials
for f = 1:length(GT_AnalysisInfo.(guiParams.scoringID).data.fileIDs)                   % Loop through each sleeping event
    if strcmp(GT_AnalysisInfo.(guiParams.scoringID).data.fileIDs{f,1}, fileID)        % If the fileID matches the sleep event, create a 1
        sleepTimeLogical{f, 1} = 1;
    else
        sleepTimeLogical{f, 1} = 0;                        % Else create a 0
    end
end

% Now that we have a logical showing the sleeping events that match this specific trial, we want to pull out the sleep times
% for that specific trial
x = 1;                                              % This is the first index point for our new "Sleeping times" cell
for f = 1:length(sleepTimeLogical)         % Loop through the sleep logical
    if sleepTimeLogical{f, 1} == 1         % If the logical denotes a 1, aka the fileID matches the sleep logical
        sleepTimes{x, 1} = GT_AnalysisInfo.(guiParams.scoringID).data.binTimes{f, 1};  % Pull out the associated bin times
        x = x + 1;                                                  % This adds additional times within the same trial down the new struct
    end
end

%% BLOCK PURPOSE: Filter the whisker angle and identify the solenoid timing and location.
% Setup butterworth filter coefficients for a 10 Hz lowpass based on the sampling rate (150 Hz).

% Identify the solenoid times from the ProcData file.
solenoidContra = floor(SleepScoringData.Sol.solenoidContralateral);
solenoidIpsi = floor(SleepScoringData.Sol.solenoidIpsilateral);
solenoidTail = floor(SleepScoringData.Sol.solenoidTail);

%% CBV data loaded in the GetBilateralCBV function
[B, A] = butter(4, 4 / (30 / 2), 'low');
HeartRate = zeros(1,300);
HeartRate(2:298) = filtfilt(B, A, SleepScoringData.HeartRate);
HeartRate(1) = HeartRate(2);
HeartRate(299:end) = HeartRate(298);

[D, C] = butter(4, 1 / (30 / 2), 'low');
CBV = filtfilt(D, C, SleepScoringData.normCBV(1:end - 1));
timeVec = (1:length(CBV))/30;
delta = filtfilt(D, C, SleepScoringData.normDeltaBandPower);
theta = filtfilt(D, C, SleepScoringData.normThetaBandPower);
gamma = filtfilt(D, C, SleepScoringData.normGammaBandPower);
ballVelocity = SleepScoringData.ballVelocity;
binBallVelocity = SleepScoringData.binBallVelocity;

%% Yvals for behavior Indices
ball_YVals = 1.10*max(CBV)*ones(size(binBallVelocity));
solenoidContra_YVals = 1.20*max(CBV)*ones(size(solenoidContra));
solenoidIpsi_YVals = 1.20*max(CBV)*ones(size(solenoidIpsi));
solenoidTail_YVals = 1.20*max(CBV)*ones(size(solenoidTail));
sleeping_YVal = 1.30*max(CBV);

%% Figure
singleSleepTrial = figure;
ax1 = subplot(5,1,1);
plot(timeVec, ballVelocity, 'LineWidth', 1, 'color', GT_colors('ash grey'));
hold on;
axis tight
ylabel('Degrees');
yyaxis right
ylim([6 15]);
plot(1:length(HeartRate), HeartRate, 'LineWidth', 1, 'color', GT_colors('carrot orange'));
ylabel('Heart Rate (Hz)');
title([animalID ' ' fileID ' Sleep Scoring']);
set(gca, 'Ticklength', [0 0])
legend('ball velocity', 'heart rate', 'Location', 'NorthEast')

ax2 = subplot(5,1,2:3);
yyaxis right
plot(timeVec, delta, '-', 'LineWidth', 1, 'color', GT_colors('sapphire'));
hold on
plot(timeVec, theta, '-', 'LineWidth', 1, 'color', GT_colors('harvest gold'));
plot(timeVec, gamma, '-', 'LineWidth', 1, 'color', GT_colors('royal purple'));
ylim([-2 10])
ylabel('Normalized Power')

yyaxis left
plot(timeVec, CBV, 'color', GT_colors('Dark Candy Apple Red'), 'LineWidth', 2);
hold on;
for sleepT = 1:length(sleepTimes)
    scatter(sleepTimes{sleepT, 1}, (ones(1, length(sleepTimes{sleepT, 1})))*sleeping_YVal, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', GT_colors('rich electric blue'))
end
scatter(solenoidContra, solenoidContra_YVals, 'v', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', GT_colors('raspberry'));
scatter(solenoidIpsi, solenoidIpsi, 'v', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', GT_colors('teal blue'));
scatter(solenoidTail, solenoidTail_YVals, 'v', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', GT_colors('rose pink'));

title('Normalized CBV reflectance and individual neural bands of interest');
ylabel('Reflectance (%)')
legend('CBV', 'sleep epochs', 'contra stim', 'ipsi stim', 'tail stim', 'delta power', 'theta power', 'gamma power', 'Location', 'NorthEast')
set(gca, 'Ticklength', [0 0])

ax3 = subplot(5,1,4:5);
imagesc(SleepScoringData.Spectrograms.FiveSec.T5, SleepScoringData.Spectrograms.FiveSec.F5, SleepScoringData.Spectrograms.FiveSec.S5_Norm)
axis xy
caxis([-1 2])
title('Normalized spectrogram - caxis default [-1:2]')
ylabel('Frequency (Hz)')
xlabel('Time (sec)')
linkaxes([ax1 ax2 ax3], 'x')

%% Save the file to directory.
dirpath = ([cd '/Sleep Summary Figs/' guiParams.scoringID '/']);
savefig(singleSleepTrial, [dirpath animalID '_' hem '_' fileID '_SingleTrialSummaryFig']);

end