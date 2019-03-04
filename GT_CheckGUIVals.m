function [Error] = CheckGUIVals(guiParams)

if guiParams.hrCrit == 8
    Error = true;
else
    Error = false;
end