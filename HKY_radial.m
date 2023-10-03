% HKY_radial
%% Offshore wind farm collector system planning with radial topology/without "N-1" criterion based on LDF
% This function solve aN OWF-ECS planning problem, with 30 wind turbines (WTs)
% turbines (WTs) location fixed and 1 substation located in their centre
% Radial topology of OWF farm is considered.
% Power flow model is based on Linear DistFlow
%  For basic notations, see more at:
%  Shen, Xinwei, S. Li, and H. Li. "Large-scale Offshore Wind Farm Electrical Collector System Planning: A Mixed-Integer Linear Programming Approach." arXiv preprint arXiv:2108.08569 (2021).
clear all
close all

%% Conditions initialization for 30 WTs cases
HKY30_conditions;

%% Model formulation and solve the problem
OWF_ECSP_LDF2;

%% save the data
% save([num2str(WTs),'WT_',num2str(Ns),'Sub_LDF_35kV']);
% save([num2str(WTs),'WT_',num2str(Ns),'Sub_LDF_66kV']);

% save([num2str(WTs),'WT_',num2str(Ns),'Sub_LDF_35kV_3_real_New_24']);
save([num2str(WTs),'WT_',num2str(Ns),'Sub_LDF_66kV_5_real_New_8']);
%% Highlight the lines to be bulit and plot all the operation conditions
% pi_final=plot_ECSP_Colored(2,L,N_WT,N_Subs,I,J,s_x,s_y,s_y_ij,s_Pij,Coord_WT,Coord_OS,[],Inp,Inn,[]);
pi_final=plot_ECSP_DCPF2(1,L,N_WT,N_Subs,I,J,s_x,s_y,s_Pij,[],Coord_WT,Coord_OS,[],n_cab);
% print(3,'-dpng',[num2str(WTs),'WT_',num2str(Ns),'Sub_LDF_35kV_3_real_New_24']);
print(1,'-dpng',[num2str(WTs),'WT_',num2str(Ns),'Sub_LDF_66kV_5_real_New_8']);

cab_len=len_l*s_x; 
%% 3. ÐÞ¸Äopsµ÷ÓÃBD
