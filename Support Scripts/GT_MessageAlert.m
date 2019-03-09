function GT_MessageAlert(message, GT_AnalysisInfo, guiParams)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Output the results of the sleep scoring analysis or display an error message for invalid parameters.
%________________________________________________________________________________________________________________________
%
%   Inputs: message type (string)
%           GT_AnalysisInfo (struct) with the results
%           guiParams (struct) with the GUI's results (input parameters)
%
%   Outputs: a msgbox displaying the results/message/error
%
%   Last Revised: March 8th, 2019
%________________________________________________________________________________________________________________________

% 'Complete' message is called when the full sleep scoring analysis runs sucessfully to display the results.
if strcmp(message, 'Complete')
    % Note if the user denoted whether or not to save the results of the analysis. Control for whether the analysis
    % was successful or not.
    if guiParams.saveStructToggle == true
        try
            if length(GT_AnalysisInfo.(guiParams.scoringID).data.fileIDs) >= 1
                structSaved = 'yes';
            end
        catch
            structSaved = 'yes, but it is empty [  ]';
        end
    else
        structSaved = 'no';
    end 
    
    % Note if the user denoted whether or not to save the figs from the analysis. Control for whether the analysis
    % was successful or not,
    if guiParams.saveFigsToggle == true
        try
            if length(GT_AnalysisInfo.(guiParams.scoringID).data.fileIDs) >= 1
                figsSaved = num2str(length(unique(GT_AnalysisInfo.(guiParams.scoringID).data.fileIDs)));
            end
        catch
            figsSaved = '0';
        end
    else
        figsSaved = 'none';
    end
    
    % If the analysis did not detect any sleep scoring epochs...
    if isempty(GT_AnalysisInfo.(guiParams.scoringID).data)
        msg = msgbox({'Sleep Scoring Analysis Results:', ...
            ' ', ...
            ['Parameters ID: ' guiParams.scoringID], ...
            ' ',...
            ' - No sleep data was found.', ...
            ' ', ...
            [' - Results saved: ' structSaved], ...
            ' ', ...
            [' - Summary figures: ' figsSaved],...
            ' '}, 'Analysis Complete', 'warn');
        waitfor(msg)
    else   % The analysis did detect any sleep scoring epochs...
        % Determine how many minutes of sleep were found.
        sleepTime = 0;
        numberOfTrials = length(unique(GT_AnalysisInfo.(guiParams.scoringID).data.fileIDs));
        for f = 1:length(GT_AnalysisInfo.(guiParams.scoringID).data.binTimes)
            sleepTime = sleepTime + length(GT_AnalysisInfo.(guiParams.scoringID).data.binTimes{f,1});
        end
        sleepTime_min = (sleepTime*5)/60;     
        msg = msgbox({'Sleep Scoring Analysis Results:', ...
            ' ', ...
            ['Parameters ID: ' guiParams.scoringID], ...
            ' ', ...
            [' - ' num2str(sleepTime_min) ' minutes of sleep data was found.']...
            ' ' ...
            [' - ' num2str(numberOfTrials) ' unique trials.']...
            ' ', ...
            [' - ' num2str(length(GT_AnalysisInfo.(guiParams.scoringID).data.fileIDs)) ' unique events.']...
            ' ', ...
            [' - Results saved: ' structSaved], ...;
            ' ', ...
            [' - Summary figures saved: ' figsSaved]...
            ' '}, 'Analysis Complete', 'help');
        waitfor(msg)
    end
    
% 'Invalid' message is called when the GT_CheckGUIVals detects an incorrect input parameter to the GUI.
elseif strcmp(message, 'Invalid')
    msg = msgbox({'One of the parameters you entered is not a valid criteria. Please check the README.md document for a list of valid inputs.'...
        ' ',...
        'Aborting Analysis...',...
        ' '}, 'Invalid input', 'error');
    waitfor(msg)
end

end