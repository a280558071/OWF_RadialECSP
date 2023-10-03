%% 1 load 
clear all;
close all;
% clc;
load 42WT_1Sub_LDF_35kV_4_real.mat 
s_x(282,1)=1;
s_x(278,1)=0;
s_x(278,2)=1;
s_x(488,3)=1;
s_x(383,1)=1;
s_x(399,2)=0;s_x(399,1)=1; %38-32
s_x(291,1)=0; %30-25
s_x(290,1)=0; %30-24
s_x(287,1)=1; %30-20
s_x(484,1)=0; %20-43
s_x(484,2)=1; %20-43
s_x(488,2)=0; %43-24
s_x(488,3)=1; %43-24
s_x(489,4)=0; %43-25
s_x(489,3)=1;
s_x(493,2)=0; %43-32
s_x(404,1)=0;
s_x(325,1)=0;
s_x(383,1)=1;
s_x(451,1)=0;% 40-41
s_x(430,1)=1; %40-33
s_x(494,4)=0; %43-33
s_x(494,3)=1; %43-33
s_x(445,2)=0; s_x(445,1)=1; %41-34
s_x(495,4)=0; s_x(495,3)=1; %43-34
% s_x=[s_x;0,1,0,0]; %43-31
%% plot figure 
s_y=sum(s_x,2);
% pi_final=plot_ECSP_DCPF2(1,L,N_WT,N_Subs,I,J,s_x,s_y,s_Pij,[],Coord_WT,Coord_OS,[],n_cab);
OWF_ECSP_LDF3;
pi_final=plot_ECSP_DCPF2(1,L,N_WT,N_Subs,I,J,s_x,s_y,s_Pij,[],Coord_WT,Coord_OS,[],n_cab);
save([num2str(WTs),'WT_',num2str(Ns),'Sub_LDF_35kV_3_real']);
print(3,'-dpng',[num2str(WTs),'WT_',num2str(Ns),'Sub_LDF_35kV_3_real']);