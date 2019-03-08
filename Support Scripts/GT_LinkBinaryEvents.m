function [linkedWF] = GT_LinkBinaryEvents(binWF, dCrit)
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

%% Identify Edges, control for trial start/stop
dBinWF = diff(gt(binWF, 0));
upInd = find(dBinWF == 1);
downInd = find(dBinWF == -1);
if size(dBinWF, 1) == 1
    if binWF(end) > 0
        downInd = horzcat(downInd, length(binWF));
    end
    if binWF(1) > 0
        upInd = horzcat(1, upInd);
    end
else
    if binWF(end) > 0
        downInd = vertcat(downInd, length(binWF));
    end
    if binWF(1) > 0
        upInd = vertcat(1, upInd);
    end
end

%% Link periods of bin_wf==0 together if less than dCrit(1)
% Calculate time between events
brkTimes = upInd(2:length(upInd)) - downInd(1:(length(downInd) - 1));
% Identify times less than user-defined period
sub_dCritDowns = find(lt(brkTimes, dCrit(1)));

% Link any identified breaks together
if isempty(sub_dCritDowns) == 0
    for d = 1:length(sub_dCritDowns)
        start = downInd(sub_dCritDowns(d));
        stop = upInd(sub_dCritDowns(d) + 1);
        binWF(start:stop) = 1;
    end
end

%% Link periods of bin_wf==1 together if less than dCrit(2)
dBinWF = diff(gt(binWF, 0)); %reestablish state change indecies 
upInd = find(dBinWF == 1); %find when animal starts running
downInd = find(dBinWF == -1); %find when animal stops running
if size(dBinWF, 1) == 1
    if binWF(end) > 0
        downInd = horzcat(downInd, length(binWF));
    end
    if binWF(1) > 0
        upInd = horzcat(1, upInd);
    end
else
    if binWF(end) > 0
        downInd = vertcat(downInd, length(binWF));
    end
    if binWF(1) > 0
        upInd = vertcat(1, upInd);
    end
end
hitimes = downInd - upInd;
blips = find(lt(hitimes, dCrit(2)) == 1); %find periods where animal moves less than threshold duration
if isempty(blips) == 0
    for b = 1:length(blips) %Mark below threshold points as rest
        start = upInd(blips(b));
        stop = downInd(blips(b));
        binWF(start:stop) = 0;
    end
end

linkedWF = binWF;

end
