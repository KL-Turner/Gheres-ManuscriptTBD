function [GT_AnalysisInfo]=GT_FindAtonia(GT_AnalysisInfo)
EventCount=1;
RestCount=1;
[z,p,k]=butter(3,2/(0.5*20000),'low');
[sos,g]=zp2sos(z,p,k);
% KernelWidth=0.5;
% TheKernel=gpuArray(gausswin(KernelWidth*20000)/sum(gausswin(KernelWidth*20000)));
% for event=1:size(GT_AnalysisInfo.thresholds.EMGData,1)
%     EMGEvent=gpuArray(GT_AnalysisInfo.thresholds.EMGData(event,:));
%     GT_AnalysisInfo.thresholds.EMGPwr(event,:)=gather(conv(EMGEvent,TheKernel,'same'));
% end
GT_AnalysisInfo.thresholds.EMGPwr=max(filtfilt(sos,g,GT_AnalysisInfo.thresholds.EMGData')',0);
plot_num=ceil(size(GT_AnalysisInfo.thresholds.EMGPwr,1)/5);
% for fignum=1:plot_num
%     figure(fignum);subplot(5,1,1);
%     subplot(5,1,2);
%     subplot(5,1,3);
%     subplot(5,1,4);
%     subplot(5,1,5);
% end
for event=1:size(GT_AnalysisInfo.thresholds.EMGData,1)
    if EventCount<=20
        LongrestInds=[];
        [imp_bin]=velocity_binarize(GT_AnalysisInfo.thresholds.BallData(event,:),20000,20000,1e-5);
        [T_run,T_Stand]=motion_cont(imp_bin,20000);
        RestDuration=(T_Stand(2,:)-T_Stand(1,:))/20000;
        LongRestInds=find(RestDuration>=10);
        if ~isempty(LongRestInds)
            for j=1:length(LongRestInds)
                GT_AnalysisInfo.thresholds.ThresholdEMGEvents{RestCount}=GT_AnalysisInfo.thresholds.EMGPwr(event,T_Stand(1,LongRestInds(j)):T_Stand(2,LongRestInds(j)));
                PlotTime=(1:length(GT_AnalysisInfo.thresholds.ThresholdEMGEvents{RestCount}))/20000;
                figure(99);plot(PlotTime,GT_AnalysisInfo.thresholds.ThresholdEMGEvents{RestCount});
                xlim([0 PlotTime(end)]);
                ylim([0 0.5]);
                fprintf('Select start and end points for >5s of low EMG power. Otherwise press [ENTER]\n')
                [time,magnitude]=ginput(2);
                if ~isempty(time)
                    if (time(2)-time(1))>=5
                        SampleInds=round(time*20000,0);
                        GT_AnalysisInfo.thresholds.EventTime(EventCount)=time(2)-time(1);
                        GT_AnalysisInfo.thresholds.EventAvg(EventCount)=mean(GT_AnalysisInfo.thresholds.ThresholdEMGEvents{RestCount}(SampleInds(1):SampleInds(2)));
                        GT_AnalysisInfo.thresholds.EventStd(EventCount)=std(GT_AnalysisInfo.thresholds.ThresholdEMGEvents{RestCount}(SampleInds(1):SampleInds(2)));
                        EventCount=EventCount+1;
                        RestCount=RestCount+1;
                    else
                        fprintf('Event not long enough duration,skipping\n');
                    end
                else
                    fprintf('Skipping trial\n')
                end
                
            end
        else
            fprintf('No rest events in this trial\n')
        end
    else
        fprintf('Rest value criteria already met\n')
    end
end
close all;
totaltime=num2str(sum(GT_AnalysisInfo.thresholds.EventTime));
fprintf([ totaltime ' seconds of rest used to calculate atonia baseline\n'])
GT_AnalysisInfo.thresholds.EMG_Avg=mean(GT_AnalysisInfo.thresholds.EventAvg,2);
GT_AnalysisInfo.thresholds.EMG_Std=mean(GT_AnalysisInfo.thresholds.EventStd,2);
GT_AnalysisInfo.thresholds.EMG_Thresh=GT_AnalysisInfo.thresholds.EMG_Avg+(3*GT_AnalysisInfo.thresholds.EMG_Std);
%ThresholdData.EMG_99=ThresholdData.EMG_Avg+3.291*(ThresholdData.EMG_Std/sqrt(size(ThresholdData.EventAvg,2)));
Plot_EMG(1:length(GT_AnalysisInfo.thresholds.EMGPwr))=GT_AnalysisInfo.thresholds.EMG_Thresh;
%Plot_999(1:length(TheEphys.EMG.Pwr(1,:)))=ThresholdData.EMG_99;
Plot_Time=(1:length(GT_AnalysisInfo.thresholds.EMGPwr(1,:)))/20000;
GT_AnalysisInfo.thresholds.EMG_Atonia=GT_AnalysisInfo.thresholds.EMGPwr<GT_AnalysisInfo.thresholds.EMG_Thresh;