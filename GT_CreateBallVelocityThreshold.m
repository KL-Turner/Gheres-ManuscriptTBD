function [thresh] = GT_CreateBallVelocityThreshold(vel)
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

y = hilbert(diff(vel));
velocity = abs(y);
figure;
isok = 'n';

while strcmp(isok,'y') == 0
    plot(velocity, 'k');
    thresh = input('No Threshold to binarize ball velocity found. Please enter a threshold: '); disp(' ')
    binVel = BinarizeBallVelocity(vel,thresh);
    binInds = find(binVel);
    subplot(211)
    plot(vel, 'k') 
    axis tight
    hold on
    scatter(binInds, max(vel)*ones(size(binInds)),'r');
    subplot(212) 
    plot(velocity, 'k')
    axis tight
    hold on
    scatter(binInds, max(velocity)*ones(size(binInds)),'r');
    isok = input('Is this threshold okay? (y/n) ','s'); disp(' ')
    hold off
end

end
