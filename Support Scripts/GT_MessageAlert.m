function GT_MessageAlert(messageType, guiParams)
x = 3;
if x == 2
    x = 5;
elseif strcmp(messageType, 'Complete')
    analysisInfo = dir('*_GT_AnalysisInfo.mat');
    load(analysisInfo.name);
    
        scoringID = guiParams.scoringID;
        saveStructToggle = guiParams.saveStructToggle;
        saveFigsToggle = guiParams.saveFigsToggle;
        
        if saveStructToggle == 1
            if length(GT_AnalysisInfo.SleepData.scoringID.fileIDs) >= 1
                structSaved = 'yes';
            else
                structSaved = 'yes, but it is empty []';
            end
        else
            structSaved = 'no';
        end
        
        if saveFigsToggle == 1
            if length(GT_AnalysisInfo.SleepData.scoringID.fileIDs) >= 1
                figsSaved = num2str(length(unique(GT_AnalysisInfo.SleepData.scoringID.fileIDs)));
            else
                figsSaved = '0';
            end
        else
            figsSaved = 'none';
        end
        
    if isempty(GT_AnalysisInfo.SleepData)
        msg = msgbox({'Sleep Scoring Analysis Complete.', ...
                      ' ', ...
                     ['No sleep data was found using scoring parameter ID :' paramID], ...
                     ' ', ...
                     'SleepData structure saved: no', ...;
                     ' ', ...
                     'Summary figures saved: none'}, 'Analysis Complete', 'warn');
        waitfor(msg)
    else
        numberOfTrials = length(unique(GT_AnalysisInfo.SleepData));
        nremSleepTime = sum(GT_AnalysisInfo.SleepData);
        remSleepTime = sum(GT_AnalysisInfo.SleepData);
        
        msg = msgbox({'Sleep Scoring Analysis Complete.', ...
                      ' ', ...
                     ['No sleep data was found using scoring parameter ID :' paramID], ...
                     ' ', ...
                     ['SleepData structure saved: ' structSaved], ...;
                     ' ', ...
                     ['Summary figures saved: ' figsSaved]}, 'Analysis Complete', 'help');
        waitfor(msg)
    end
end

end