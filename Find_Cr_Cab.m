function Cr_Cab_new=Find_Cr_Cab(In,L,N_WT,N_Subs,s,t,Coord_WT,Coord_OS)
%% This function produce the crossing cables in an OWF,
% Cr_Cab: the set of crossing cables , a n×2 matrix, where [Cr_Cab(i,1),Cr_Cab(i,2)] denotes the i_th pair crossing cables.
Coord=[Coord_WT;Coord_OS];
V_l=zeros(L,2); % the vectors of all candidate cables
for l=1:L
    V_l(l,:)=Coord(s(l),:)-Coord(t(l),:); % the lth row of V_l is the vector from node s to node t.
end
Cr_Cab=[];
for i=[N_WT,N_Subs]
    for l=1:L-1
        for k=(l+1):L
            if s(l)==i || t(l)==i || s(k)==i || t(k)==i % if cable l/k is connecting OS with other WT, assuming s(l)=(node)A,t(l)=B,s(k)=C,t(k)=D
                AC=[Coord(s(k),:)-Coord(s(l),:)];
                AB=[Coord(t(l),:)-Coord(s(l),:)];
                AD=[Coord(t(k),:)-Coord(s(l),:)];
                CB=[Coord(t(l),:)-Coord(s(k),:)];
                CD=[Coord(t(k),:)-Coord(s(k),:)];
                if det([AC;AB])*det([AD;AB])<-1e-6 &&...% cross(AC,AB)*cross(AD,AB)<=0, use cross-product to judge whether C & D is on two sides of segment AB
                        det([-AC;CD])*det([CB;CD])<-1e-6 % cross(CA,CD)*cross(CB,CD)<=0, use cross-product to judge whether A & B is on two sides of segment CD
%                     for c=1:size(Cr_Cab,1)
%                         if ~(Cr_Cab(c,1)==l && Cr_Cab(c,2)==k)
                            Cr_Cab=[Cr_Cab;l,k];
%                         end
%                     end
                end
            end
        end
    end
end
Cr_Cab_new=unique(Cr_Cab,'rows');
% for c=1:size(Cr_Cab,1)
%     for c_new=1:size(Cr_Cab_new,1)
%         if ~(Cr_Cab(c,1)==Cr_Cab_new(c_new,1) && Cr_Cab(c,2)==Cr_Cab_new(c_new,2))
%             Cr_Cab_new=[Cr_Cab_new;Cr_Cab(c,:)];
%         end
%     end
% end

