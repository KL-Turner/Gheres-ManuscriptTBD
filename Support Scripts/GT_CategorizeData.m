function [GT_AnalysisInfo] = GT_CategorizeData(sleepScoringDataFile, GT_AnalysisInfo)
%___________________________________________________________________________________________________
% Edited by Kevin L. Turner 
% Ph.D. Candidate, Department of Bioengineering 
% The Pennsylvania State University
%
% Originally written by Aaron T. Winder
%
%   Last Revised: August 8th, 2018
%___________________________________________________________________________________________________
%
%   Author: Aaron Winder
%   Affiliation: Engineering Science and Mechanics, Penn State University
%   https://github.com/awinde
%
%   DESCRIPTION: Identifies periods of sensory stimulation, volitional
%   movement, and rest. Calculates relevant details for each behavioral
%   period:
%           Stimulation:    Run Score - measure of the intensity of 
%                           runing before and after onset of a puff. 
%                           A 0 indicates no runing, a 1 indicates 
%                           maximum runing over a 1 second period.
%                           Movement Score - Same as run score except
%                           uses the force sensor beneath the animal to
%                           detect body movment.
%
%           Runing:       Duration - the time, in seconds, from onset to
%                           cessation of a runing event.
%                           Rest Time - the duration of resting behavior
%                           prior to onset of the volitional run
%                           Run Score - a measure of the intensity of
%                           runing for the duration of the run a
%                           maximum run for the whole duration will give
%                           a score of 1. No runing will give a score of
%                           0.
%                           Movement Score - Same as run score exept uses
%                           the force sensor beneath the animal to detect
%                           body movement over the duration of the
%                           volitional run.
%                           Puff Distance - The time, in seconds, between
%                           the onset of each run an every puff
%                           administered during the trial.
%
%
%          Rest:            Duration - the time, in seconds without any 
%                           detected runing or body movement.
%                           Start Time - the trial time corresponding to
%                           the cessation of all volitional movement.
%   
%_______________________________________________________________
%   PARAMETERS:             
%                           filename - [string] file identifier                      
%_______________________________________________________________
%   RETURN:                     
%                           None, output of the script is additions to the
%                           SleepScoringData structure.
%_______________________________________________________________

load(sleepScoringDataFile)
downSampled_Fs = SleepScoringData.downSampled_Fs;

%% Process binary runing waveform to detect runing events
% Setup parameters for link_binary_events
linkThresh = 0.5;   % seconds, Link events < 0.5 seconds apart
breakThresh = 0;   % seconds changed by atw on 2/6/18 from 0.07

% Assume that runs at the beginning/end of trial continue outside of the
% trial time. This will link any event occurring within "link_thresh"
% seconds to the beginning/end of the trial rather than assuming that it is
% a new/isolated event.
modBinVel = SleepScoringData.binBallVelocity;

% Link the binarized runing for use in GetRunningData function
binVel = GT_LinkBinaryEvents(gt(modBinVel,0), [linkThresh breakThresh]*downSampled_Fs);

% Added 2/6/18 with atw. Code throws errors if binRuns(1)=1 and binRuns(2) = 0, or if 
% binRuns(1) = 0 and binRuns(2) = 1. This happens in GetRunningData because starts of 
% runs are detected by taking the derivative of binRuns. Purpose of following lines is to 
% handle trials where the above conditions occur and avoid difficult dimension errors.
if binVel(1)==0 && binVel(2)==1
    binVel(1) = 1;
elseif binVel(1)==1 && binVel(2)==0
    binVel(1) = 0;
end

if binVel(end)==0 && binVel(end-1)==1
    binVel(end) = 1;
elseif binVel(end)==1 && binVel(end-1)==0
    binVel(end) = 0;
end

%% Categorize data by behavior

% Retrieve details on runing events
[SleepScoringData.Flags.run] = GetRunningData(SleepScoringData, binVel);

% Retrieve details on puffing events
[SleepScoringData.Flags.stim] = GetStimData(SleepScoringData);

% Identify and separate resting data
[SleepScoringData.Flags.rest] = GetRestData(SleepScoringData);

% Save SleepScoringData structure
save(sleepScoringDataFile, 'SleepScoringData');

function [puffTimes] = GetPuffTimes(SleepScoringData)
%   function [Puff_Times] = GetPuffTimes(SleepScoringData)
%
%   Author: Aaron Winder
%   Affiliation: Engineering Science and Mechanics, Penn State University
%   https://github.com/awinde
%
%   DESCRIPTION: Gets the time in seconds of all puffs administered during
%   a trial.
%   
%_______________________________________________________________
%   PARAMETERS:             
%                       SleepScoringData - [struct] structure obtained using the 
%                       function ProcessSleepScoringDataFile.
%_______________________________________________________________
%   RETURN:                     
%                       Puff_Times - [array] time in seconds of all puffs              
%_______________________________________________________________

solNames = fieldnames(SleepScoringData.Sol);
puffList = cell(1, length(solNames));

for sN = 1:length(solNames)
    puffList{sN} = SleepScoringData.Sol.(solNames{sN});
end

puffTimes = cell2mat(puffList);

function [Stim] = GetStimData(SleepScoringData)
%   function [Stim] = GetStimData(SleepScoringData)
%
%   Author: Aaron Winder
%   Affiliation: Engineering Science and Mechanics, Penn State University
%   https://github.com/awinde
%
%   DESCRIPTION: Returns details on puffs administered during a trial.
%   Including: 
%                           Run Score - measure of the intensity of 
%                           runing before and after onset of a puff. 
%                           A 0 indicates no runing, a 1 indicates 
%                           maximum runing over a 1 second period.
%                           Movement Score - Same as run score except
%                           uses the force sensor beneath the animal to
%                           detect body movment.
%   
%_______________________________________________________________
%   PARAMETERS:             
%                       SleepScoringData - [struct] structure obtained using the 
%                       function ProcessSleepScoringDataFile.    
%_______________________________________________________________
%   RETURN:                     
%                       Stim - [struct] structure containing a nested 
%                       structure for each puff administered. Each nested 
%                       structure contains details about puffs from a
%                       single solenoid.
%_______________________________________________________________

% Setup
downSampled_Fs = SleepScoringData.downSampled_Fs;
puffTimes = GetPuffTimes(SleepScoringData);
trialDuration = 300;

% Set time intervals for calculation of the run scores
preTime = 1;
postTime = 1;

% Get puffer IDs
solNames = fieldnames(SleepScoringData.Sol);
Stim.solenoidName = cell(length(puffTimes), 1);
Stim.eventTime = zeros(length(puffTimes), 1);
Stim.runScore_Pre = zeros(length(puffTimes), 1);
Stim.runScore_Post = zeros(length(puffTimes), 1);
i = 1;

for sN = 1:length(solNames)
    solPuffTimes = SleepScoringData.Sol.(solNames{sN});
    for spT = 1:length(solPuffTimes) 
        if trialDuration - solPuffTimes(spT) <= postTime
            disp(['Puff at time: ' solPuffTimes(spT) ' is too close to trial end'])
            continue;
        end
        % Set indexes for pre and post periods
        rPuffInd = round(solPuffTimes(spT)*downSampled_Fs);
        rPreStart = max(round((solPuffTimes(spT)-preTime)*downSampled_Fs), 1);
        rPostEnd = round((solPuffTimes(spT) + postTime)*downSampled_Fs);
        
        % Calculate the percent of the pre-stim time that the animal ran
        runScorePre = sum(SleepScoringData.binBallVelocity(rPreStart:rPuffInd))/(preTime*downSampled_Fs);
        runScorePost = sum(SleepScoringData.binBallVelocity(rPuffInd:rPostEnd))/(postTime*downSampled_Fs);
        
        % Add to Stim structure
        Stim.solenoidName{i} = solNames{sN};
        Stim.eventTime(i) = solPuffTimes(spT)';
        Stim.runScore_Pre(i) = runScorePre';
        Stim.runScore_Post(i) = runScorePost';
        i = i + 1;
    end
end

% Calculate the time to the closest puff, omit comparison of puff to itself
% (see nonzeros)
puffMat = ones(length(puffTimes),1)*puffTimes;
timeElapsed = abs(nonzeros(puffMat - puffMat'));

% If no other puff occurred during the trial, store 0 as a place holder.
if isempty(timeElapsed)
    puffTimeElapsed = 0;
else
% if not empty, Reshape the array to compensate for nonzeros command
    puffTimeElapsed = reshape(timeElapsed, numel(puffTimes) - 1,...
        numel(puffTimes));
end

% Convert to cell and add to struct, if length of Puff_Times = 0, coerce to
% 1 to accommodate the NaN entry.
puffTimeCell = mat2cell(puffTimeElapsed', ones(max(length(puffTimes), 1), 1));
Stim.PuffDistance = puffTimeCell;

function [Run] = GetRunningData(SleepScoringData, binarizedRuns)
%   function [Run] = GetRunningData(SleepScoringData, Bin_wwf)
%
%   Author: Aaron Winder
%   Affiliation: Engineering Science and Mechanics, Penn State University
%   https://github.com/awinde
%
%   DESCRIPTION: Returns details on runs which occurred during a trial.
%   Including:
%                           Duration - the time, in seconds, from onset to
%                           cessation of a runing event.
%                           Rest Time - the duration of resting behavior
%                           prior to onset of the volitional run
%                           Run Score - a measure of the intensity of
%                           runing for the duration of the run a
%                           maximum run for the whole duration will give
%                           a score of 1. No runing will give a score of
%                           0.
%                           Movement Score - Same as run score exept uses
%                           the force sensor beneath the animal to detect
%                           body movement over the duration of the
%                           volitional run.
%                           Puff Distance - The time, in seconds, between
%                           the onset of each run an every puff
%                           administered during the trial.
%_______________________________________________________________
%   PARAMETERS:             
%                       SleepScoringData - [struct] structure obtained using the 
%                       function ProcessSleepScoringDataFile.    
%_______________________________________________________________
%   RETURN:                     
%                       Run - [struct] structure containing a nested 
%                       structure for each run performed.
%_______________________________________________________________

%% Setup
downSampled_Fs = SleepScoringData.downSampled_Fs;

%% Get Puff Times
[puffTimes] = GetPuffTimes(SleepScoringData);

%% Find the starts of runing
runEdge = diff(binarizedRuns);
runSamples = find(runEdge > 0);
runStarts = runSamples / downSampled_Fs;

%% Classify each runing event by duration, runing intensity, rest durations
sampleVec = 1:length(binarizedRuns); 

% Identify periods of runing/resting, include beginning and end of trial
% if needed (hence unique command) for correct interval calculation
highSamples = unique([1, sampleVec(binarizedRuns), sampleVec(end)]); 
lowSamples = unique([1, sampleVec(not(binarizedRuns)), sampleVec(end)]);

% Calculate the number of samples between consecutive high/low samples.
dHigh = diff(highSamples);
dLow = diff(lowSamples);

% Identify skips in sample numbers which correspond to rests/runs,
% convert from samples to seconds.
restLength = dHigh(dHigh > 1);
runLength = dLow(dLow > 1);
restDur = restLength / downSampled_Fs;
runDur = runLength / downSampled_Fs;

% Control for the beginning/end of the trial to correctly map rests/runs
% onto the run_starts.
if binarizedRuns(1)
    runDur(1) = [];
    runLength(1) = [];
end

if not(binarizedRuns(end))
    restDur(end) = [];
end


% Calculate the runing intensity -> sum(SleepScoringData.Bin_wwf)/sum(Bin_wwf)
% over the duration of the run. Calculate the movement intensity over the
% same interval.
runInt = zeros(size(runStarts));

for wS = 1:length(runSamples)
    % Runing intensity
    runInds = runSamples(wS):runSamples(wS) + runLength(wS);
    runInt(wS) = sum(SleepScoringData.binBallVelocity(runInds)) / numel(runInds);
end

% Calculate the time to the closest puff
% If no puff occurred during the trial, store 0 as a place holder.
if isempty(puffTimes)
    puffTimes = 0;
end

puffMat = ones(length(runSamples), 1)*puffTimes;
runMat = runSamples'*ones(1, length(puffTimes)) / downSampled_Fs;
puffTimeElapsed = abs(runMat - puffMat);

% Convert to cell
puffTimeCell = mat2cell(puffTimeElapsed, ones(length(runStarts), 1));

%% Error handle

if length(restDur) ~= length(runDur)
    disp('Error in GetRunData! The number of runs does not equal the number of rests...')
    disp(' ')
    keyboard;
end
%% Compile into final structure

Run.eventTime = runStarts';
Run.duration = runDur';
Run.restTime = restDur';
Run.runScore = runInt';
Run.puffDistance = puffTimeCell;

function [Rest] = GetRestData(SleepScoringData)
%   function [Rest] = GetRestData(SleepScoringData)
%
%   Author: Aaron Winder
%   Affiliation: Engineering Science and Mechanics, Penn State University
%   https://github.com/awinde
%
%   DESCRIPTION: Returns details on periods of rest during a trial.
%   Including:
%          Rest:            Duration - the time, in seconds without any 
%                           detected runing or body movement.
%                           Start Time - the trial time corresponding to
%                           the cessation of all volitional movement.   
%_______________________________________________________________
%   PARAMETERS:             
%                       SleepScoringData - [struct] structure obtained using the 
%                       function ProcessSleepScoringDataFile.    
%_______________________________________________________________
%   RETURN:                     
%                       Rest - [struct] structure containing a nested 
%                       structure for each period of rest.
%_______________________________________________________________

% Setup
downSampled_Fs = SleepScoringData.downSampled_Fs;

%% Get stimulation times
[puffTimes] = GetPuffTimes(SleepScoringData);

%% Recalculate linked binarized wwf without omitting any possible runs,
% this avoids inclusion of brief runer movements in periods of rest.

% Assume that runs at the beginning/end of trial continue outside of the
% trial time. This will link any event occurring within "link_thresh"
% seconds to the beginning/end of the trial rather than assuming that it is
% a new/isolated event.
modBinarizedRuns = SleepScoringData.binBallVelocity;
modBinarizedRuns([1, end]) = 1;

linkThresh = 0.5; % seconds
breakThresh = 0;% seconds
binarizedRuns = GT_LinkBinaryEvents(gt(modBinarizedRuns, 0), [linkThresh breakThresh]*downSampled_Fs);

%% Combine binarizedRuns, binarizedForceSensor, and puffTimes, to find periods of rest. 

% Add puff times into the Bin_wf
puffInds = round(puffTimes*downSampled_Fs);
binarizedRuns(puffInds) = 1;

% Find index for end of runing event
edge = diff(binarizedRuns);
samples = find([not(binarizedRuns(1)) edge < 0]);
stops = samples / downSampled_Fs;

% Identify periods of runing/resting, include beginning and end of trial
% if needed (hence unique command) for correct interval calculation
sampleVec = 1:length(logical(binarizedRuns));
highSamples = unique([1, sampleVec(binarizedRuns), sampleVec(end)]); 
lowSamples = unique([1, sampleVec(not(binarizedRuns)), sampleVec(end)]); 

% Calculate the number of samples between consecutive high/low samples.
dHigh = diff(highSamples);
dLow = diff(lowSamples);

% Identify skips in sample numbers which correspond to rests/runs,
% convert from samples to seconds.
restLength = dHigh(dHigh > 1);
restDur = restLength / downSampled_Fs;
runLength = dLow(dLow > 1);
runDur = runLength / downSampled_Fs;

% Control for the beginning/end of the trial to correctly map rests/runs
% onto the run_starts. Use index 2 and end-1 since it is assumed that the
% first and last indexes of a trial are the end/beginning of a volitional
% movement.
if not(binarizedRuns(2)) 
    runDur = [NaN runDur];
end

if binarizedRuns(end - 1)
    runDur(end) = [];
end

% Calculate the time to the closest puff
% If no puff occurred during the trial, store 0 as a place holder.
if isempty(puffTimes)
    puffTimes = 0;
end

puffMat = ones(length(samples), 1)*puffTimes;
restMat = samples'*ones(1, length(puffTimes)) / downSampled_Fs;
puffTimeElapsed = abs(restMat - puffMat);

% Convert to cell
puffTimeCell = mat2cell(puffTimeElapsed, ones(length(samples), 1));

% Compile into a structure
Rest.eventTime = stops';
Rest.duration = restDur';
Rest.puffDistance = puffTimeCell;
Rest.runDuration = runDur';
