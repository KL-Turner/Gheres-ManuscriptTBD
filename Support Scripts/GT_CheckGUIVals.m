function [Error] = GT_CheckGUIVals(guiParams)

if guiParams.neurCrit <= 1 
    Error = true;
elseif guiParams.ballCrit < 0
    Error = true;
elseif guiParams.hrCrit <= 5 || guiParams.hrCrit >= 16
    Error = true;
elseif guiParams.awakeDuration < 5 || mod(guiParams.awakeDuration, 5) ~= 0
    Error = true;
elseif guiParams.minSleepTime < 5 || guiParams.minSleepTime > 300 || mod(guiParams.minSleepTime, 5) ~= 0
    Error = true;
else
    Error = false;
end