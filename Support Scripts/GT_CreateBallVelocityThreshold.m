function [thresh] = GT_CreateBallVelocityThreshold(vel, an_fs)
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
dVel = abs((diff(vel, 1)))*an_fs^2;

while strcmp(isok,'y') == 0
    fig = figure;
    plot(dVel,'k');
    title('Raw acceleration signal')
    thresh = input('No Threshold for resting behavior found. Please enter a threshold: '); disp(' ')
    bin_vel = GT_BinarizeBallVelocity(dVel, thresh);
    ax1 = subplot(311); 
    plot(vel, 'k'); 
    axis tight; 
    ylabel('Velocity')
    ax2 = subplot(312);
    plot(abs(diff(vel, 1))*an_fs^2, 'k'); 
    axis tight; 
    ylabel('Acceleration')
    ax3 = subplot(313); 
    plot(bin_vel, 'k'); 
    axis tight;
    ylabel('Binarization')
    linkaxes([ax1, ax2, ax3], 'x');
    isok = input('Is this threshold okay? (y/n) ','s'); disp(' ')
end
close(fig)
clc
end

