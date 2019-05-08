function [Error] = GT_CheckGUIVals(guiParams)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Check the inputs to the sleep scoring GUI. If any of the parameters are outside an allowable range,
%            return the error as true.
%________________________________________________________________________________________________________________________
%
%   Inputs: guiParams (struct) with the GUI's results.
%
%   Outputs: Error (true/false). Default to false, set to true if incorrect parameter is detected.
%
%   Last Revised: March 8th, 2019
%________________________________________________________________________________________________________________________

if guiParams.neurCrit <= 0   % Neural LFP needs to be greater than 1-fold change of baseline.
    Error = true;
elseif guiParams.ballCrit < 0   % There cannot be less than 0 binarized events for the ball velocity.
    Error = true;
elseif guiParams.hrCrit <= 5 || guiParams.hrCrit >= 16 % Heart rate's physiological range is typically 5-16 Hz.
    Error = true;
elseif guiParams.awakeDuration < 5 || mod(guiParams.awakeDuration, 5) ~= 0   % Data is in 5 second bins. Must be multiple of 5.
    Error = true;
elseif guiParams.minSleepTime < 5 || guiParams.minSleepTime > 300 || mod(guiParams.minSleepTime, 5) ~= 0 % ^same as above.
    Error = true;
else
    Error = false;
end

end
