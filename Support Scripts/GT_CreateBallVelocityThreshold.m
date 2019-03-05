function [thresh] = GT_CreateBallVelocityThreshold(vel, fs)
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

isok = 'n';
accel = diff(vel, 1);

while strcmp(isok,'y') == 0   
    fig = figure;
    plot((1:length(accel))/fs, accel, 'k');
    xlabel('Time (sec)')
    ylabel('Acceleration')
    axis tight
    
    thresh = input('No Threshold for resting behavior found. Please enter a threshold: '); disp(' ')
    binVel = abs(accel) > thresh;
    
    ax1 = subplot(3,1,1); 
    plot((1:length(vel))/fs, vel, 'k'); 
    xlabel('Time (sec)')
    ylabel('Velocity')
    axis tight; 
    
    ax2 = subplot(3,1,2);
    plot((1:length(accel))/fs, accel, 'k');
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

