function GT_AddHeartRate(fileName)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Add the heart rate from IOS data via FindHeartRate.m to the ProcData.mat structure.
%________________________________________________________________________________________________________________________
%
%   Inputs: ProcData.mat file name.
%
%   Outputs: None - but saves the updated ProcData.mat file to the current folder.
%
%   Last Revised: February 29th, 2019
%________________________________________________________________________________________________________________________

load(fileName)
[~, tr, ~, HR] = FindHeartRate(RawData.barrels.CBVrefl_barrels, RawData.dal_fr);
RawData.HR = HR;
RawData.HR_tr = tr;
save(fileName, 'RawData');

end
