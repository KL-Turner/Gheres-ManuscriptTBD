function [ok] = GT_CheckForThreshold(sfield, GT_AnalysisInfo)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%________________________________________________________________________________________________________________________
%
%   Purpose: Check for a threshold value for a given day.
%________________________________________________________________________________________________________________________
%
%   Inputs: sfield (string) corresponding to the threhold name (ball, force, whiskers, etc) and string day.
%           GT_AnalysisInfo (struct) containing this analysis' information and sleep scoring results.
%
%   Outputs: ok (double) of whether the threshold exists or not.
%
%   Last Revised: March 8th, 2019
%________________________________________________________________________________________________________________________

ok = 0;
% If the summary structure does not have a thresholds field, create one.
if ~isfield(GT_AnalysisInfo, 'thresholds')
    GT_AnalysisInfo.thresholds = [];
else
    % If the summary structure does have a thresholds field, check that a threshold exists for the specific
    % parameter of interest (ball, whisk, foce, etc) on this specific day.
    if isfield(GT_AnalysisInfo.thresholds, sfield)
        ok = 1;
    end
end

end
