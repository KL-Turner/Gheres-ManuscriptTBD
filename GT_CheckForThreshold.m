function [ok] = GT_CheckForThreshold(sfield, animalID)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%________________________________________________________________________________________________________________________
%
%   Purpose:
%________________________________________________________________________________________________________________________
%
%   Inputs:
%
%   Outputs: 
%
%   Last Revised: February 29th, 2019
%________________________________________________________________________________________________________________________

% Navigate to Shared Variables folder
disp(['GT_CheckForThreshold.m: Checking for Threshold field: ' sfield '...']); disp(' ')
% Begin Check
ok = 0;
if exist([animalID '_GT_AnalysisInfo.mat'],'file') == 2
    load([animalID '_GT_AnalysisInfo.mat']);
    if isfield(Thresholds, sfield)
        ok = 1;
        disp(['GT_CheckForThreshold.m: Threshold: ' sfield ' found.']); disp(' ')
    else
        disp(['GT_CheckForThreshold.m: Threshold: ' sfield ' not found.']); disp(' ')
    end
end

end
