function [GT_AnalysisInfo] = GT_ProcessRawData(rawDataFiles, GT_AnalysisInfo)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: 
%________________________________________________________________________________________________________________________
%
%   Inputs: 
%
%   Outputs: 
%
%   Last Revised: 
%________________________________________________________________________________________________________________________

if ~isfield(GT_AnalysisInfo, 'GT_ProcessNeuro_Complete')
    for f = 1:size(rawDataFiles, 1)
        rawDataFile = rawDataFiles(f, :);
        [animalID, hem, fileDate, fileID] = GT_GetFileInfo(rawDataFile);
        strDay = GT_ConvertDate(fileDate);
        load(rawDataFile)
        trialDuration_Seconds = 300;
        expectedLength = trialDuration_Seconds*RawData.an_fs;
        
        % Delta [1 - 4 Hz]
        [RawData.SleepAnalysis.Neural_Bands.DeltaBand_Power, RawData.SleepAnalysis.Neural_Bands.downSampled_Fs] = ...
            ProcessNeuro(RawData, 'Delta', trialDuration_Seconds);
        
        % Theta [4 - 8 Hz]
        [RawData.SleepAnalysis.Neural_Bands.ThetaBand_Power, ~] = ProcessNeuro(RawData, 'Theta', trialDuration_Seconds);
        
        % Gamma Band [40 - 100]
        [RawData.SleepAnalysis.Neural_Bands.GammaBand_Power, ~] = ProcessNeuro(RawData, 'Gam', trialDuration_Seconds);
        
        
        
        %% Downsample and binarize the ball velocity.
        % Trim any additional data points for resample
        trimmedBallVelocity = RawData.vBall(1:min(expectedLength, length(RawData.vBall)));
        
        % Filter then downsample the ball velocity waveform to desired frequency
        downSampled_Fs = RawData.dal_fr;   % Downsample to CBV Camera Fs
        ballVelocityFilterThreshold = 20;
        ballVelocityFilterOrder = 2;
        [z, p, k] = butter(ballVelocityFilterOrder, ballVelocityFilterThreshold / (RawData.an_fs / 2), 'low');
        [sos, g] = zp2sos(z, p, k);
        filteredBallVelocity = filtfilt(sos, g, trimmedBallVelocity);
        
        resampledBallVelocity = resample(filteredBallVelocity, downSampled_Fs, RawData.an_fs);
        
        % Binarize the ball velocity waveform
        [ok] = CheckForThreshold(['binarizedBallVelocity_' strDay], animal);
        
        if ok == 0
            [ballVelocityThreshold] = CreateBallVelocityThreshold(RawData.vBall);
            GT_AnalysisInfo.Thresholds.(['binarizedBallVelocity_' strDay]) = ballVelocityThreshold;
            save([animal '_GT_AnalysisInfo.mat'], 'GT_AnalysisInfo');
        end
        
        binarizedBallVelocity = BinarizeBallVelocity(RawData.vBall, GT_AnalysisInfo.(['binarizedBallVelocity_' strDay]));
        [linkedBinarizedVelocity] = LinkBinaryEvents(gt(binarizedWhiskers,0), [round(whiskerDownsampledSamplingRate/3), 0]);
        
        inds = linkedBinarizedVelocity == 0;
        restVelocity = mean(resampledBallVelocity(inds));

        RawData.SleepAnalysis.ballVelocity = resampledBallVelocity - restVelocity;
        RawData.SleepAnalysis.binBallVelocity = binarizedBallVelocity;
        
        %% Save the processed rawdata structure.
        disp(['Saving RawData file ' fileID '...']); disp(' ')
%         save([fileName(1:(underscoreIndexes(end) - 1)) '_ProcData.mat'], 'ProcData');
        
    end
    
end
