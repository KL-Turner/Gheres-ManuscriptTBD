%% choose a file containing all the potential training data for a single animal
clear; clc; close all;
SleepTrainingData = uigetfile('*_SleepTraining.mat');
load(SleepTrainingData)
% pull animal ID and age
animalID = strrep(SleepTraining.AnimalParams.ID,'_',' ');
animalAge = SleepTraining.AnimalParams.Age;
%% go through each sleep scoring parameter and take the proper representative value from each cell
numFiles = size(SleepTraining.IOS.dHbT,1);
numCells = size(SleepTraining.IOS.dHbT,2);
paramsTables = cell(numFiles,1);
for aa = 1:numFiles
    variableNames = {'meanHipDelta','meanHippTheta','meanHipBeta','meanHipGamma','numBallEvents','medEMG','sleepLabel'};
    % pre-allocation for each table's column of representative values
    meanHipDeltaColumn = zeros(numCells,1);
    meanHipThetaColumn = zeros(numCells,1);
    meanHipBetaColumn = zeros(numCells,1);
    meanHipGammaColumn = zeros(numCells,1);
    numBallEventsColumn = zeros(numCells,1);
    medianEMGColumn = zeros(numCells,1);
    sleepLabelColumn = cell(numCells,1);
    % take each parameter's representative value during each 5 second epoch
    for bb = 1:numCells
        meanHipDeltaColumn(bb,1) = mean(mean(SleepTraining.Spectrograms.DeltaPwr{aa,bb},1),2);
        meanHipThetaColumn(bb,1) = mean(mean(SleepTraining.Spectrograms.ThetaPwr{aa,bb},1),2);
        meanHipBetaColumn(bb,1) = mean(mean(SleepTraining.Spectrograms.BetaPwr{aa,bb},1),2);
        meanHipGammaColumn(bb,1) = mean(mean(SleepTraining.Spectrograms.GammaPwr{aa,bb},1),2);
        numBallEventsColumn(bb,1) = sum(SleepTraining.Behavior.binBall{aa,bb});
        medianEMGColumn(bb,1) = median(SleepTraining.EMG.EMGpwr{aa,bb});
        sleepLabelColumn{bb,1} = SleepTraining.ManualScores.binLabels{aa,bb};
    end
    % create table of values for each file
    paramsTables{aa,1} = table(meanHipDeltaColumn,meanHipThetaColumn,meanHipBetaColumn,meanHipGammaColumn,numBallEventsColumn,medianEMGColumn,sleepLabelColumn,'VariableNames',variableNames);
end
%% create a single table of odd files for training model
oddInds = 1:2:numFiles;
oddTables = paramsTables(oddInds);
joinedOddTables = [];
for cc = 1:length(oddTables)
    joinedOddTables = cat(1,joinedOddTables,oddTables{cc,1});
end
Xodd = joinedOddTables(:,1:end - 1);   % representative values (X-block)
Yodd = joinedOddTables(:,end);         % sleep labels (Y-block)
% create a single table of even files for testing unseen data
evenInds = 2:2:numFiles;
evenTables = paramsTables(evenInds);
joinedEvenTables = [];
for dd = 1:length(evenTables)
    joinedEvenTables = cat(1,joinedEvenTables,evenTables{dd,1});
end
Xeven = joinedEvenTables(:,1:end - 1); % representative values (X-block)
Yeven = joinedEvenTables(:,end);       % sleep labels (Y-block)
%% Random forest classifier
numTrees = 128;
disp(['Training boostrap-aggregated random forest classifier with ' num2str(numTrees) ' trees']); disp(' ')
RF_MDL = TreeBagger(numTrees,Xodd,Yodd,'Method','Classification','Surrogate','all','OOBPrediction','on','ClassNames',{'Not Sleep','NREM Sleep','REM Sleep'});
% % determine the misclassification probability (for classification trees) for out-of-bag observations in the training data
RF_OOBerror = oobError(RF_MDL,'Mode','Ensemble');
disp(['Random Forest out-of-bag error: ' num2str(RF_OOBerror*100) '%']); disp(' ')
% use the model to generate a set of scores for the two sets of data
[YoddPredLabels,~] = predict(RF_MDL,Xodd);
[YevenPredLabels,~] = predict(RF_MDL,Xeven);
%% confusion matrix
RF_confMat = figure;
sgtitle({[animalID ' ' animalAge],'Random Forest Classifier Confusion Matrix'})
% training data confusion chart
subplot(1,2,1)
oddCM = confusionchart(Yodd.sleepLabel,YoddPredLabels);
oddCM.ColumnSummary = 'column-normalized';
oddCM.RowSummary = 'row-normalized';
oddCM.Title = 'Training Data';
oddConfVals = oddCM.NormalizedValues;
oddTotalScores = sum(oddConfVals(:));
oddRF_accuracy = (sum(oddConfVals([1,5,9])/oddTotalScores))*100;
disp(['Random Forest model prediction accuracy (training): ' num2str(oddRF_accuracy) '%']); disp(' ')
% testing data confusion chart
subplot(1,2,2)
evenCM = confusionchart(Yeven.sleepLabel,YevenPredLabels);
evenCM.ColumnSummary = 'column-normalized';
evenCM.RowSummary = 'row-normalized';
evenCM.Title = 'Testing Data';
evenConfVals = evenCM.NormalizedValues;
evenTotalScores = sum(evenConfVals(:));
evenRF_accuracy = (sum(evenConfVals([1,5,9])/evenTotalScores))*100;
disp(['Random Forest model prediction accuracy (testing): ' num2str(evenRF_accuracy) '%']); disp(' ')
% %% analyze the cross validation distribution of 100 iterations of real data and shuffled data
% iterations = 100;
% disp(['Checking mean out-of-bag error with ' num2str(iterations) ' iterations of shuffled data']); disp(' ')
%  X = RF_MDL.X;   % same data as Xodd
%  Y = RF_MDL.Y;   % same data as Yodd
%  shuff_OOBerror = zeros(iterations,1);
% for ff = 1:iterations
%     shuffYIdx = randperm(numel(Y));
%     shuffY = Y(shuffYIdx);
%     shuffRF_MDL = TreeBagger(numTrees,X,shuffY,'Method','Classification','Surrogate','all','OOBPrediction','on','ClassNames',{'Not Sleep','NREM Sleep','REM Sleep'});
%     shuff_OOBerror(ff,1) = oobError(shuffRF_MDL,'Mode','Ensemble');
% end
% meanShuff_OOBerror = mean(shuff_OOBerror);
% disp(['Shuffled data out-of-bag error: ' num2str(meanShuff_OOBerror*100) '%']); disp(' ')
% %% check the oob-error as a function of the total number of trees used
% disp('Checking out-of-bag error as a function of tree number'); disp(' ')
% treeTest_OOBerror = zeros(1,numTrees);
% for ee = 1:numTrees
%     treeTest_MDL = TreeBagger(ee,Xodd,Yodd,'Method','Classification','Surrogate','all','OOBPrediction','on','ClassNames',{'Not Sleep','NREM Sleep','REM Sleep'});
%     % % determine the misclassification probability (for classification trees) for out-of-bag observations in the training data
%     treeTest_OOBerror(1,ee) = oobError(treeTest_MDL,'Mode','Ensemble');
% end
% figure;
% scatter(1:numTrees,treeTest_OOBerror*100,'k')
% xlabel('Number of trees')
% ylabel('Out-of-bag error (%)')
% title({[animalID ' ' animalAge],'Out-of-bag error vs. number of trees'})