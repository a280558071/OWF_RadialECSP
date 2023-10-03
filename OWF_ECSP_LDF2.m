%% Offshore wind farm collector system planning with radial topology/without "N-1" criterion based on LDF
% This function solve an OWF-ECS planning problem, with wind turbines (WTs)
% turbines (WTs) location fixed and 1 substation located in their centre
% Radial topology of OWF farm is considered.
% Power flow model is based on Linear DistFlow
%  For basic notations, see more at:
%  Shen, Xinwei, S. Li, and H. Li. "Large-scale Offshore Wind Farm Electrical Collector System Planning: A Mixed-Integer Linear Programming Approach." arXiv preprint arXiv:2108.08569 (2021).

%% Variable statement
L_c=1;


% Ubase=35e3;  % unit:V
% Ibase=Sbase/Ubase/1.732;  %unit: A
% Zbase=Ubase/Ibase/1.732;  %unit: Ω
% % LineCap=37.15; % Line Capacity: 37.15 MVA for 3×630 26/35 XLPE cable
% % C_lines=367.4;  % Cost of 35kV line for 3×630 26/35 XLPE cable, unit: 1e4 ￥/km
% LineCap=53.35; % Line Capacity: 53.35 MVA for 2*3×240 26/35 XLPE cable
% C_lines=415.8;  % Cost of 35kV line for 2*3×240 26/35 XLPE cable, unit: 1e4 ￥/km
% z=ConsInf(:,4)*(0.042+0.348i)/Zbase; % line impedance unit:p.u., (0.039+0.101i) is the impedance of 3×630 mm2 submarine cables (ohm/km), According to ABB's Cable Catalogue-2016
% LineCap=[37.15,53.35];
% Cost=[367.4,415.8];

n_cab=size(LineCap,2);
x=binvar(L,n_cab,'full');     %Vars for line construction, x(i,1)==1 dentoes that line i is constructed.
y=binvar(L,n_cab,'full');   %Vars for line operation flag in different contigencies, y(line operation,Cont_l)==0
y_ij=binvar(L,n_cab,2,'full');  %Vars for parent-child relationship of line l (i→j)
Pij=sdpvar(L,1,'full');    %Vars for active power flow in each line in Contigency L_c+Normal Condition, unit: p.u. 
Pw_shed=sdpvar(WTs,1, 'full'); % shedded active wind power 
g_Sub_P=sdpvar(Ns,1,'full');    %Vars for generated power of Subs
%% ***********Objective Function***********
Obj_inv=sum(sum(Cost.*x))*1e4;
Ur_Hours=2000/8760;  % annual hours of OWFs
Pr_ele=200;  % 0.85 ￥/kWh = 850 ￥/MWh
Obj_loss=Ur_Hours*8760*20*sum(r.*(Pij.^2))*Pr_ele;
Obj_WindCurt=M*sum(sum(Pw_shed));
% Obj=Obj_inv+Obj_WindCurt+Obj_loss;
Obj=Obj_inv+Obj_WindCurt; %HKY
% Obj=sum(Cost.*x);

%% *********** Constraints ***********
Cons=[];

%% Cons1: Operation logic y<=x in any contigency C_l
Cons_Op=[];
Cons_Op=[Cons_Op, y<=x];
Cons_Op=[Cons_Op, sum(sum(y,2),1)==N-length(N_Subs)];
Cons_Op=[Cons_Op, y==sum(y_ij,3)];

% for C_l=1:L_c
%     Cons_Op=[Cons_Op, y(:,C_l)<=x];
%     Cons_Op=[Cons_Op, sum(y(:,C_l))==N-length(N_Subs)];
%     Cons_Op=[Cons_Op, y(:,C_l)==sum(y_ij(:,C_l,:),3)];  % In Cont. C_l, OWF-ECS network is radial, thus parent-child relationship remains equal to the switch status.
% end
Cons=[Cons,Cons_Op];
display('****** Cons. on Construction Logic Completed!******');
size(Cons_Op);
size(Cons);
%% Cons2: Crossing-avoidance constraints (CAC)
Cons_CAC=[];
Cr_Cab=Find_Cr_Cab(In,L,N_WT,N_Subs,I,J,Coord_WT,Coord_OS);
for l=1:length(Cr_Cab)
    Cons_CAC=[Cons_CAC,sum(x(Cr_Cab(l,1),:),2)+sum(x(Cr_Cab(l,2),:))<=1];
end
Cons=[Cons,Cons_CAC];
display('****** Crossing-avoidance Cons.(CAC) Completed!******');


%% Cons2: Spanning Tree Constr.
% J. A. Taylor and F. S. Hover, “Convex models of distribution system reconfiguration,” IEEE Trans. Power Syst., vol. 27, no. 3, pp. 1407?C1413,Aug. 2012.
Cons_ST=[];
Inp=In;
Inn=In;
Inp(Inp<0)=0;
Inn(Inn>0)=0;
% for C_l=1:L_c % For any Cont. C_l, OWF-ECS network is radial, thus generating a spanning tree, with parent-child relationship in each line
%     for i=N_WT
%         Cons_ST=[Cons_ST,Inp(i,:)*y_ij(:,C_l,1)-Inn(i,:)*y_ij(:,C_l,2)==1]; % WT node i can only have one parent node among all nodes connecting with i
%     end
%     for i=N_Subs
%         Cons_ST=[Cons_ST,Inp(i,:)*y_ij(:,C_l,1)-Inn(i,:)*y_ij(:,C_l,2)==0]; % Sub node i have no parent node among all nodes connecting with i 
%     end
% end

% for i=1:N_WT
%     Cons_ST=[Cons_ST,Inp(i,:)*sum(y_ij(:,:,1),2)-Inn(i,:)*sum(y_ij(:,:,2),2)==1]; % WT node i can only have one parent node among all nodes connecting with i
% end
% for i=1:N_Subs
%     Cons_ST=[Cons_ST,Inp(i,:)*sum(y_ij(:,:,1),2)-Inn(i,:)*sum(y_ij(:,:,2),2)==0]; % Sub node i have no parent node among all nodes connecting with i
% end

Cons=[Cons,Cons_ST];
display('******Cons. on Spanning Tree Completed!******');
size(Cons_ST);
size(Cons);

%% Cons3: Power balance
Cons_S=[];
% for C_l=1:L_c % for Contigency C_l
%     Cons_S=[Cons_S,In*Pij(:,C_l)==[-(Pw-Pw_shed(:,C_l));g_Sub_P(:,C_l)]];
%     Cons_S=[Cons_S,Pw>=Pw_shed(:,C_l)>=0];
% end
Cons_S=[Cons_S,In*Pij(:,1)==[-(Pw-Pw_shed(:,1));g_Sub_P(:,1)]];
Cons_S=[Cons_S,Pw>=Pw_shed(:,1)>=0];
Cons=[Cons,Cons_S];
display('******Cons. on Power Balance Completed!******')
size(Cons_S);
size(Cons);
%% Cons4: Power flow limitation in each line
Cons_Line=[];
% for C_l=1:L_c % for Contigency C_l and Normal condition, the power limits must maintain
%     Cons_Line=[Cons_Line,-y(:,C_l).*LineCap<=Pij(:,C_l)<=y(:,C_l).*LineCap];
% end

for i=1:L
    Cons_Line=[Cons_Line,-y(i,:)*LineCap'<=Pij(i)<=y(i,:)*LineCap'];
end
Cons=[Cons,Cons_Line];
display('******Cons. on Power Limits of Lines Completed!******')
size(Cons_Line);
size(Cons);

%% Cons5: Power limits of Subs
Cons_Sub=[0<=g_Sub_P<=g_Sub_Max];
Cab_Sub=find(ConsInf(:,3)==N_Subs);
Cons_Sub=[Cons_Sub,sum(sum(x(Cab_Sub,:),2),1)==n_feeders];
Cons=[Cons,Cons_Sub];
display('******Cons. on Power Limits of Subs Completed!******')
size(Cons_Sub);
size(Cons);

%% Solving Options: B&B or B&C, Heuristics percentage
% load 42WT_1Sub_LDF_35kV_4_real.mat
% x0=s_x;
% assign(x,s_x)
ops=sdpsettings('solver','cplex','verbose',2,'usex0',0,'Cplex.Benders.Strategy',0,'cplex.timelimit',30000); %,'gurobi.MIPGap',5e-2,,'Gurobi.MIPFocus',3,'gurobi.MIPGap',1e-3,'gurobi.TimeLimit',30000,
% ops=sdpsettings('solver','gurobi','usex0',1, 'gurobi.MIPGap',1e-4,'verbose',2,'gurobi.LogFile',['Case_',num2str(WTs),'_LDF.log'],'Gurobi.TimeLimit',15000);%,'gurobi.Cuts',0,'usex0',1,
% [model,recoverymodel] = export(Cons,Obj,ops);
ops.cplex.exportmodel='abc.lp';
%% solve the problem
sol1=optimize(Cons,Obj,ops);
%% Save the solution with "s_" as start
s_x=round(value(x));
s_y=round(value(y));
s_y_ij=round(value(y_ij));
s_Pij=value(Pij);
s_Pw_shed=value(Pw_shed);
s_g_Sub=value(g_Sub_P);
s_Obj=value(Obj);
s_Obj_inv=value(Obj_inv);
s_Obj_WindCurt=value(Obj_WindCurt);
s_Obj_loss=value(Obj_loss);

%% display the results' infor
display(['********* 风电场集电系统规划结束！']);
display(['********* 最优拓扑结构如图所示！']);
display(['********* 1 线路规划建设成本：￥ ',num2str(s_Obj_inv)]);
display(['********* 2 弃风成本：￥ ',num2str(s_Obj_WindCurt)]);
display(['********* 3 集电系统网损成本：￥ ',num2str(s_Obj_loss)]);
Ploss=sum(r.*(s_Pij.^2));
Ploss_rate=Ploss/sum(Pw);
C_EENG=abs(Pr_ele*2000*20*0.0045*(len_l*(sum(s_x,2).*s_Pij)));
display(['********* 4 集电系统可靠性成本：￥ ',num2str(C_EENG)]);
display(['********* （集电系统网损率为： ',num2str(Ploss_rate*100), ' %']);
display(['********* 总成本：￥ ',num2str(s_Obj+C_EENG)]);



% C_EENG=Pr_ele*4000*20*0.0045*(len_l*(s_x.*abs(s_Pij)));
% display(['********* 4 集电系统可靠性成本：￥ ',num2str(C_EENG)]);