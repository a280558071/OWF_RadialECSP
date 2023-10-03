%% 1 load the result of first-step result
load 42WT_1Sub_LDF_66kV_5_real.mat
HKY30_conditions;
%% 2 improve the result 
s_x(278,:)=0; %29-24
s_x(279,2)=1; %29-24
s_x(489,2)=0; s_x(489,3)=1; %43-25
s_x(216,3)=0; s_x(216,2)=1; %24-20
s_x(234,:)=0; %25-24
s_x(484,4)=0;s_x(484,2)=1; %43-20
s_x=[s_x;0,0,0,0,0]; %43-31
% %% (optional)  3 plot the figure before warm-start
% s_y=sum(s_x,2);
% pi_final=plot_ECSP_DCPF2(1,L,N_WT,N_Subs,I,J,s_x,s_y,s_Pij,[],Coord_WT,Coord_OS,[],n_cab);

%% 4 run the multicable radial ECSP program with warm start
load 42WT_1Sub_LDF_66kV_5_real2.mat;
x0=s_x;
OWF_ECSP_LDF3;

%% 5 plot the final result
pi_final=plot_ECSP_DCPF2(1,L,N_WT,N_Subs,I,J,s_x,s_y,s_Pij,[],Coord_WT,Coord_OS,[],n_cab);
save([num2str(WTs),'WT_',num2str(Ns),'Sub_LDF_66kV_5_real2']);
print(3,'-dpng',[num2str(WTs),'WT_',num2str(Ns),'Sub_LDF_66kV_5_real2']);