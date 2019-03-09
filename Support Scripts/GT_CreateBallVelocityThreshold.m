function [threshold] = GT_CreateBallVelocityThreshold(ballVelocity, fs)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%________________________________________________________________________________________________________________________
%
%   Purpose: Prompt the user to create a threshold for a given signal, in this instance ball velocity.
%________________________________________________________________________________________________________________________
%
%   Inputs: velocity (double) array of the ball's velocity over time.
%           fs (double) the sampling rate of the ball velocity.
%
%   Outputs: threshold (double) a value that denotes the ball's maximum allowable acceleration before a movement
%            event is recognized.
%
%   Last Revised: March 8th, 2019
%________________________________________________________________________________________________________________________

isok = 'n';
ballAcceleration = diff(ballVelocity, 1);   % Derive velocity -> acceleration.

% Create a figure showing the ball's acceleration and prompt the user to type a value into the command
% window corresponding to the desired threshold. Once a vlue is entered, verify that the user is sure
% this is the correct value by showing a subplot of the original velocity, acceleration, and corresponding 
% movement-binarization using the entered value. If the value is too high/low, the user can enter 'n' to reset
% the threshold to a different value.
while strcmp(isok,'y') == 0   
    fig = figure;
    plot((1:length(ballAcceleration))/fs, ballAcceleration, 'k');
    xlabel('Time (sec)')
    ylabel('Acceleration')
    axis tight
    
    threshold = input('No Threshold for resting behavior found. Please enter a threshold: '); disp(' ')
    binVel = abs(ballAcceleration) > threshold;
    
    ax1 = subplot(3,1,1); 
    plot((1:length(ballVelocity))/fs, ballVelocity, 'k'); 
    xlabel('Time (sec)')
    ylabel('Velocity')
    axis tight; 
    
    ax2 = subplot(3,1,2);
    plot((1:length(ballAcceleration))/fs, ballAcceleration, 'k');
    xlabel('Time (sec)')
    ylabel('Acceleration')
    axis tight
    
    ax3 = subplot(3,1,3); 
    plot((1:length(binVel))/fs, binVel, 'k'); 
    xlabel('Time (sec)')
    ylabel('Binarization')
    axis tight;
    
    linkaxes([ax1, ax2, ax3], 'x');
    isok = input('Is this threshold okay? (y/n) ','s'); disp(' ')
end

close(fig)
clc

end

