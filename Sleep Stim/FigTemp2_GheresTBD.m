function [AnalysisResults] = FigTemp2_GheresTBD(rootFolder,saveFigs,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Generate temporary supplemental figure panel for Gheres (TBD)
%________________________________________________________________________________________________________________________

%% set-up and process data
IOSanimalIDs = {'T99','T101','T102','T103','T105','T108','T109','T110','T111','T119','T120','T121','T122','T123'};
zz = 1;
for aa = 1:length(IOSanimalIDs)
    animalID = IOSanimalIDs{1,aa};
    if isempty(AnalysisResults.(animalID).Coherence.Awake.LH.C) == false
        data.LH_C(zz,:) = AnalysisResults.(animalID).Coherence.Awake.LH.C;
        data.RH_C(zz,:) = AnalysisResults.(animalID).Coherence.Awake.RH.C;
        data.LH_f(zz,:) = AnalysisResults.(animalID).Coherence.Awake.LH.f;
        data.RH_f(zz,:) = AnalysisResults.(animalID).Coherence.Awake.RH.f;
        zz = zz + 1;
    end
end

data.C = cat(1,data.LH_C,data.RH_C);
data.f = cat(1,data.LH_f,data.RH_f);
data.meanC = mean(data.C,1);
data.meanf = mean(data.f,1);

%% figure
figure
plot(data.meanf,data.meanC,'k')

end

