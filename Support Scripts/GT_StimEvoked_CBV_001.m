function GT_StimEvoked_CBV_001(sleepScoringDataFiles,guiParams)
%Function to determine time frame around whiskerpuff for CBV change
%Solenoid identification changed for use w/Neotate Whisker Trial v5+
%Written by Kyle Gheres, Oct 2014

% Control for single file instead of a list
if iscell(filename) == 0
    filename = {filename};
end
GT_ProcessedData.Contra_Puff.Refl_barrels=[];
for fil = 1:length(filename)
    close all;
    indfile = filename{fil};
    animal=indfile(1:9);
    date=indfile(14:19);
    hem=indfile(11:12);
    filenm= indfile(14:30);
    load(indfile);
    %% Constants
    ROI_name=fieldnames(RawData.IOS);
    Run_State={'Still','Run'};
    T_seg=0.5;
    T_beg=5.0;
    Acc_Thresh=1e-4;
    Lead_Time=5;%Time to preceed whisker puff
    Follow_Time=20;% Time to follow Whisker Puff
    Norm_Time=2;%Time after Lead Time to use as normalization window
    order=6;
    Wn= 1/(RawData.dal_fr*0.5); %Bandpass filter properties [low freq, high freq]/nyquist freq
    ftype='low';
    [zeroa,poleb,gain]=butter(order,Wn,ftype);
    [sos,g]=zp2sos(zeroa,poleb,gain);
    [ball_b,ball_a]=butter(3,30/(RawData.an_fs*0.5));
    params.Fs=RawData.dal_fr;
    params.tapers=[3 5];
    params.trialave= 1;
    params.fpass=[3 15];
    movingwin=[1 0.05];
    if gt(max(RawData.LED),0)%gt(max(RawData.Sol),0)
        %% Binarize locomotion events
        if exist('T_run','var')==1
            clear T_run;
        end
        [imp_bin,velocity]=velocity_binarize(RawData.vBall,RawData.an_fs,RawData.dal_fr,Acc_Thresh);
        [T_run,~,new_T_run,run_frac]=motion_cont_Puff(imp_bin,RawData.dal_fr,T_beg,T_seg);
        GT_ProcessedData.Ball.RunEvents(fil,(1:size(imp_bin,1)))=0;
        if isempty(T_run)==0
            for k=1:size(T_run,2)
                Run_Length=T_run(2,k)-T_run(1,k);
                if gt(Run_Length,(0.5*RawData.dal_fr))
                    GT_ProcessedData.Ball.RunEvents(fil,T_run(1,k):T_run(2,k))=1;
                end
            end
        else
            fprintf(1,'Animal did not run during trial\n')
        end
        velocity=filtfilt(ball_b,ball_a,velocity);
        RunInds=find(GT_ProcessedData.Ball.RunEvents(fil,:)==1);
        GT_ProcessedData.Ball.Velociy(fil,:)=velocity(1:(5*60*RawData.an_fs));
        GT_ProcessedData.Ball.Run_Frac(fil)=run_frac;
        GT_ProcessedData.dal_fr=RawData.dal_fr;
        %% Find when animal was puffed
        if isempty(RawData.Sol)==0
            Sol_sample=downsample(RawData.Sol,floor(RawData.an_fs/RawData.dal_fr));
            Round_Sample=round(RawData.LED,0);% rounding to nearest integer to eliminate any bounce in the signal for binarizing of behavior
            TTL_Change=diff(Round_Sample);%Find where TTL trigger changes state
            if max(TTL_Change)==0
                Laser_State_Change=[];
                Stim_Count=0;
                fprintf('No Optostimuli this trial\n')
            else
            Laser_State_Change=find(TTL_Change==max(TTL_Change));
            Laser_Win=RawData.AcquistionParams.Laser_Duration*RawData.an_fs; %time laser pulses after on set
            Stim_On=Laser_State_Change(1);
            Stim_Off=Stim_On+Laser_Win;
            Stim_Count=numel(Laser_State_Change);
            end
            Counter=1;
            
            while Counter<=Stim_Count % for the purpose of windowing IOS data only keep the first on signal of each stimulus train
                Low_Bound=find(Laser_State_Change>Stim_On);
                Upper_Bound=find(Laser_State_Change<Stim_Off);
                The_Stim_Win=intersect(Low_Bound,Upper_Bound);
                Laser_State_Change(The_Stim_Win)=[];
                if (Counter+1)<=numel(Laser_State_Change)
                    Stim_On=Laser_State_Change(Counter+1);
                    Stim_Off=Stim_On+Laser_Win;
                end
                Stim_Count=numel(Laser_State_Change);
                Counter=Counter+1;
            end
            Laser_State_Change=round(((Laser_State_Change/RawData.an_fs)*RawData.dal_fr),0);
            Puff.Laser_Stim(1:size(RawData.IOS.(ROI_name{1}).CBVrefl,2))=0;
            Puff.Laser_Stim(Laser_State_Change)=1;
            Puff_Event=Sol_sample(1:size(RawData.IOS.(ROI_name{1}).CBVrefl,2));
            Puff.Contra_Puff=(Puff_Event==1);%Left Whisker Pad when window is on right
            Puff.Ipsi_Puff=(Puff_Event==3);
            Puff.Control_Puff=(Puff_Event==2);
            
        else
            fprintf('animal did not get puffed during trial\n')
        end
        %% Acquire reflectance data for specific timeframe
        %Plot_ROI_CBV_Trial_Optogenetics_004(filenm,RawData,imp_bin,T_run,new_T_run,velocity)
        %% Identify Stimulus time point(s) and set observation time frame
        Stim_Type=fieldnames(Puff);
        for n=1:size(Stim_Type,1)
            
            if fil==1
                for k=1:size(ROI_name,1)
                    GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Refl=[];
                    GT_ProcessedData.(Stim_Type{n}).IOS.swipe_trial=[];
                    GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Run.Refl=[];
                    GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Still.Refl=[];
                    GT_ProcessedData.ChunkStimulusData.(Stim_Type{n}).StimWin=[]; 
                end
            end
            Stim=find(diff(Puff.(Stim_Type{n}))==1);
            for U=1:size(Stim,2)
                Follow_Ind=(Stim(U)+(Follow_Time*RawData.dal_fr));
                Lead_Ind=(Stim(U)-(Lead_Time*RawData.dal_fr));
                Norm_Ind=(Stim(U)-(Norm_Time*RawData.dal_fr));
                Laser_Ind=(Lead_Time*RawData.dal_fr):((Lead_Time*RawData.dal_fr)+(RawData.AcquistionParams.Laser_Duration*RawData.dal_fr));
                Stim_Ind=Lead_Ind:Follow_Ind;
                stimCount=size(GT_ProcessedData.ChunkStimulusData.(Stim_Type{n}).StimWin,1)+1;
                GT_ProcessedData.ChunkStimulusData.(Stim_Type{n}).StimWin(stimCount,:)=Stim_Ind;
                GT_ProcessedData.ChunkStimulusData.(Stim_Type{n}).StimFile{stimCount}=indfile;
                if gt(Lead_Ind,0)
                    if lt(Follow_Ind,size(RawData.IOS.(ROI_name{1}).CBVrefl,2))
                        Isrunning=ismember(Stim_Ind,RunInds);
                        if max(Isrunning)==1 %If locomotion takes place during whisker stim window
                            j=2;
                        else
                            j=1;
                        end
                        for k=1:size(ROI_name,1)
                            next =size(GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Refl,1)+1;
                            Normalizationconstant=mean(RawData.IOS.(ROI_name{k}).CBVrefl(Lead_Ind:Norm_Ind),2);
                            %% Acquire reflectance data for stimulus timeframe
                            GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Refl(next,:)=RawData.IOS.(ROI_name{k}).CBVrefl(Stim_Ind);%Possibility of intensity dift during whole sessions, Normalized each trial individually prior to averaging 2-28-15 KG
                            GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Normalizedrefl(next,:)=(((GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Refl (next,:)-Normalizationconstant)/Normalizationconstant))*100; %Matrix where each row is a trial normalized to its pre stim (first 30 frames) intensity values are percentage of baseline 2-28-15KG
                            
                            %% Correct for Optostim artifacts
                            if strcmpi(Stim_Type{n},'Laser_Stim')==1
                                FlashCatch=diff(GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Refl(next,:));
                                if max(FlashCatch)>=200
                                    HoldRefl=GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Refl(next,:)-Normalizationconstant;
                                    Flash_Points=HoldRefl(Laser_Ind)>=(2*std(RawData.IOS.(ROI_name{k}).CBVrefl(Lead_Ind:Norm_Ind)));
                                    Flash_Vals=Laser_Ind(Flash_Points);
                                    HoldRefl(Flash_Vals)=NaN;
                                    %HoldTimes=1:length(HoldRefl);
                                    %Trial_Length=1:length(GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Refl(next,:));
                                    %Interp_Data=interp1(Trial_Length,HoldRefl,Flash_Points,'spline');
                                    [Interp_Data,Interp_Points]=fillmissing(HoldRefl,'spline');
                                    GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Corrected_Refl(next,:)=Interp_Data;%HoldRefl;
%                                     for thepoint=1:length(Flash_Points)
%                                         GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Corrected_Refl(next,Flash_Points(thepoint))=Interp_Data(thepoint);
%                                     end
                                    GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Corrected_Refl(next,:)=(GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Corrected_Refl(next,:)/Normalizationconstant)*100;
                                else
                                    GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Corrected_Refl(next,:)= GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Normalizedrefl(next,:);
                                end
                            end
                            
                            %% Resume chunking data
                            GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Filtered_Normalizedrefl(next,:)=filtfilt(sos,g, GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Normalizedrefl(next,:));
                            
                            if strcmpi(Stim_Type{n},'Laser_Stim')==1
                                GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Filtered_Interp_Refl(next,:)=filtfilt(sos,g,GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Corrected_Refl(next,:));
                            end
                            %% Separate Puff response based on behavior
                            move=size(GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).(Run_State{j}).Refl,1)+1;
                            GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).(Run_State{j}).Refl(move,:)=GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Filtered_Normalizedrefl(next,:);
                            
                            if strcmpi(Stim_Type{n},'Laser_Stim')==1
                                GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).(Run_State{j}).Interp_Refl(move,:)=GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Filtered_Interp_Refl(next,:);
                            end
                        end
                    end
                end
            end
        end
    end
end
save([animal '_' date '_GT_ProcessedData'],'GT_ProcessedData','-v7.3');
if isempty(GT_ProcessedData.Laser_Stim.IOS.(ROI_name{1}).Refl)==0%isempty(GT_ProcessedData.Contra_Puff.Refl_barrels)==0
    %%  Perform Data Averaging
    for k=1:size(ROI_name,1)
        for n=1:size(Stim_Type,1)
            for m=1:size(Run_State,2)
                if isempty(GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).(Run_State{m}).Refl)==0 %isempty(GT_ProcessedData.(Stim_Type{n}).(Run_State{m}).Image)==0
                    GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).(Run_State{m}).Avg_Filt_Refl=mean(GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).(Run_State{m}).Refl,1);
                    GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).(Run_State{m}).Std_Filt_Refl=std(GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).(Run_State{m}).Refl,0,1);
                    if strcmpi(Stim_Type{n},'Laser_Stim')==1
                        GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).(Run_State{m}).Avg_Interp_Refl=mean(GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).(Run_State{m}).Interp_Refl,1);
                        GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).(Run_State{m}).Std_Interp_Refl=std(GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).(Run_State{m}).Interp_Refl,0,1);
                    end
                else
                    fprintf(1,['No ' Stim_Type{n} ' ' Run_State{m} ' trial data to average\n']);
                end
            end
        end
    end
    for u=1:size(Stim_Type,1)
        Stim_Title{u}=strrep(Stim_Type{u},'_',' ');
    end
    save([animal '_' date '_GT_ProcessedData'],'GT_ProcessedData','-v7.3');
    %% Power spectral analysis for heartrate/breathing
    for k=1:size(ROI_name{k})
        for n=1:size(Stim_Type,1)
            if isempty(GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{1}).Refl)==0
                [S,f]= mtspectrumc(GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).Normalizedrefl',params);
                figure(95);hold on;
                semilogy(f,S);
                axis tight
                title(['Power Spectrum of Whole Whisker Stimulation Session ' ROI_name{k} ' ' Stim_Type{n}],'FontSize',16,'FontWeight','bold','FontName','Arial');
                xlabel('Frequency (Hz)','FontSize',10,'FontWeight','bold','FontName','Arial');
                ylabel('Power','FontSize',10,'FontWeight','bold','FontName','Arial');
                legend(Stim_Title, 'Location','southeast','Orientation','vertical','FontSize',8,'FontWeight','bold','FontName','Arial');
                savefig([animal '_' date '_' ROI_name{k} '_' Stim_Type{n} '_Power spectrum of Hemodynamics']);
            end
        end
    end
    %% Plot and Save Files
    for m=1:size(Run_State,2)
        lgnd_cnt=1;
        for k=1:size(ROI_name,1)
            for n=1:size(Stim_Type,1)
                if isempty(GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).(Run_State{m}).Refl)==0 %isempty(GT_ProcessedData.(Stim_Type{n}).(Run_State{m}).Image)==0
                    Time=((1:size(GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).(Run_State{m}).Avg_Filt_Refl,2))/RawData.dal_fr)-Lead_Time;
                    figure(33);
                    hold on;
                    if strcmpi(Stim_Type{n},'Laser_Stim')==1
                        plot(Time,GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).(Run_State{m}).Avg_Interp_Refl);
                    else
                        plot(Time,GT_ProcessedData.(Stim_Type{n}).IOS.(ROI_name{k}).(Run_State{m}).Avg_Filt_Refl); %Plot of avg CBV change in trials when animal was still 3-3-15 KG
                    end
                    LgndTxt{lgnd_cnt}=[strrep(Stim_Type{n},'_',' ') ' '  strrep(ROI_name{k},'_',' ')];
                    lgnd_cnt=lgnd_cnt+1;
                end
            end
        end
        Zero_Line(1:(((Lead_Time+Follow_Time)*GT_ProcessedData.dal_fr)+1))=0;
        Time=((1:size(Zero_Line,2))/GT_ProcessedData.dal_fr)-Lead_Time;
        plot(Time,Zero_Line,'k');
        title(['Average stimulus evoked reflectance change ' Run_State{m} ' trials'],'FontSize',14,'FontWeight','bold','FontName','Arial');
        xlabel('Time (s)','FontSize',10,'FontWeight','bold','FontName','Arial');
        ylabel('Percent Change (%)','FontSize',10,'FontWeight','bold','FontName','Arial');
        legend(LgndTxt, 'Location','southeast','Orientation','vertical','FontSize',8,'FontWeight','bold','FontName','Arial');
        savefig([animal '_' date '_' Run_State{m} '_Normalized Average Stimulus Evoked Reflectance Change Per Session']);
        close;
    end
end
save([animal '_' date '_GT_ProcessedData'],'GT_ProcessedData','-v7.3');
close all;
end