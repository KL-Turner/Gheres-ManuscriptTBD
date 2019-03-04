function [ok] = GT_CheckForThreshold(sfield, animalID, GT_AnalysisInfo)
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
ok = 0;
if ~isfield(GT_AnalysisInfo, 'thresholds')
    GT_AnalysisInfo.thresholds = [];
else
    if isfield(GT_AnalysisInfo.thresholds, sfield)
        ok = 1;
    end
end

end
