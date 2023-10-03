function pi=plot_ECSP_DCPF2(i,L,N_WT,N_Subs,I,J,s_x,s_y,s_Pij,s_Theta,Coord_WT,Coord_OS,CCS,Bij,n_cab)
%% This function plot the graph of a OWT ECSP result, and return the Handle of the picture
figure;
All_Inv_Cables=find(round(sum(s_x,2))==1);  % use round() because not all s_x would be exactly equal to 1
I_temp=I(All_Inv_Cables)';
J_temp=J(All_Inv_Cables)';
Gi=graph(I_temp,J_temp);
pi=plot(Gi,'Layout','force');
pi.XData=[Coord_WT(:,1)',Coord_OS(:,1)'];
pi.YData=[Coord_WT(:,2)',Coord_OS(:,2)'];
labelnode(pi,N_Subs,{'Sub'});
highlight(pi,N_WT,'NodeColor','y','Markersize',20);
highlight(pi,N_Subs,'Marker','s','NodeColor','c','Markersize',30);
color=['r','g','b','k','y'];
for i=1:size(s_x,1)
    for j=1:size(s_x,2)
        if s_x(i,j)==1
            highlight(pi,I(i),J(i),'EdgeColor',color(j),'LineWidth',6);
        end
    end
end
% highlight(pi,I_temp,J_temp,'EdgeColor','r','LineWidth',6); % bold line denotes the newly-built line
text(pi.XData, pi.YData, pi.NodeLabel,'HorizontalAlignment', 'center','FontSize', 15); % put nodes' label in right position.
pi.NodeLabel={};

% for l=1:length(All_Inv_Cables)
%     if round(s_x_ij(All_Inv_Cables(l),2))==1
%         I_temp(l)=J(All_Inv_Cables(l));
%         J_temp(l)=I(All_Inv_Cables(l));
%     end
% end
G_di=digraph(I_temp',J_temp');
figure;
p_di=plot(G_di,'Layout','force');
p_di.XData=[Coord_WT(:,1)',Coord_OS(:,1)'];
p_di.YData=[Coord_WT(:,2)',Coord_OS(:,2)'];
labelnode(p_di,N_Subs,{'Sub'});
highlight(p_di,N_WT,'NodeColor','y','Markersize',20);
highlight(p_di,N_Subs,'Marker','s','NodeColor','c','Markersize',30);
text(p_di.XData, p_di.YData, p_di.NodeLabel,'HorizontalAlignment', 'center','FontSize', 15); % put nodes' label in right position.
p_di.NodeLabel={};
lw=abs(s_Pij(All_Inv_Cables));
lw=lw/max(lw)*10;
for l=1:length(All_Inv_Cables)
    highlight(p_di,I_temp(l),J_temp(l),'LineWidth',lw(l)+0.01);
    text(0.5*(p_di.XData(I_temp(l))+p_di.XData(J_temp(l))), 0.5*(p_di.YData(I_temp(l))+p_di.YData(J_temp(l))), num2str(abs(s_Pij(All_Inv_Cables(l)))),'HorizontalAlignment', 'center','FontSize', 10,'Color','k'); % label newly-built and opened lines with 'o' in the middle
end

%% if i==2, complex plot begins, Show power flow values in each line
if i==2
    %% if Contigency infor is included, plot them too
    if ~isempty(s_y)
        k=2;
        Bij_temp=Bij(All_Inv_Cables');
        for l=1:length(CCS)  % CCS: Critical Cable Set
            l_Open=CCS(l);
            if s_x(l_Open)==1 % if this line is a line has been invested
                %             Gi=graph(s_temp,t_temp);
                figure;
                pi(k)=plot(Gi,'Layout','force');
                pi(k).XData=[Coord_WT(:,1)',Coord_OS(:,1)'];
                pi(k).YData=[Coord_WT(:,2)',Coord_OS(:,2)'];
                labelnode(pi(k),N_Subs,{'Sub'});
                highlight(pi(k),N_WT,'NodeColor','y','Markersize',20);
                highlight(pi(k),N_Subs,'Marker','s','NodeColor','c','Markersize',30);
                highlight(pi(k),I(find(round(s_y(:,l))==1)),J(find(round(s_y(:,l))==1)),'EdgeColor','b','LineWidth',6,'LineStyle','-');  % blue lines are lines in operation
                %                 l_Open=find(round((1-s_y(:,l)).*s_x)==1);
                highlight(pi(k),I(l_Open),J(l_Open),'EdgeColor','r','LineWidth',10,'LineStyle','-'); % green line denotes the newly-built line NOT in operation
                text(pi(k).XData, pi(k).YData, pi(k).NodeLabel,'HorizontalAlignment', 'center','FontSize', 15); % put nodes' label in right position.
                text(pi(k).XData, pi(k).YData-0.2, num2str(round(s_Theta(:,l)*100,3)),'HorizontalAlignment', 'center','FontSize', 10); % put nodes' angle in right position.
                pi(k).NodeLabel={};
                fij=abs(s_Pij(All_Inv_Cables,l));
                lw=fij/max(fij)*10;
                for j=1:length(All_Inv_Cables)
                    highlight(pi(k),I_temp(j),J_temp(j),'LineWidth',lw(j)+0.01);
                    text(0.5*(pi(k).XData(I_temp(j))+pi(k).XData(J_temp(j))), 0.5*(pi(k).YData(I_temp(j))+pi(k).YData(J_temp(j))), num2str(fij(j)),'HorizontalAlignment', 'center','FontSize', 10,'Color','k'); % put power flow values in the middle of each line
                    %                     text(0.5*(pi(k).XData(I_temp(j))+pi(k).XData(J_temp(j))), 0.5*(pi(k).YData(I_temp(j))+pi(k).YData(J_temp(j)))-0.2, ['B_{',num2str(I_temp(j)),',',num2str(J_temp(j)),'}=',num2str(round(Bij_temp(j)/1e4,3))],'HorizontalAlignment', 'center','FontSize', 10,'Color','k'); % put line susceptance values in the middle of each line
                end
                k=k+1;
            end
        end
        % l_newOpen=setdiff(l_Open,i);
        % text(0.5*(pi(i).XData(s_temp(l_newOpen))+pi(i).XData(t_temp(l_newOpen))), 0.5*(pi(i).YData(s_temp(l_newOpen))+pi(i).YData(t_temp(l_newOpen))), 'O','HorizontalAlignment', 'center','FontSize', 15,'Color','g'); % label newly-built and opened lines with 'o' in the middle
    end
end
