function plot_AllPoints(result)
popsize=result.opt.popsize;
gen=result.opt.maxGen;
obj=[];

for i=1:gen
    for j=1:popsize
        indi=[result.pops(i,j).obj result.pops(i,j).violSum];
        obj=[obj;indi];
        
    end
end

neg=find(obj(:,2)<0);

obj(neg,:)=[];

feasible=find(obj(:,3)==0);
feasibleobj=obj(feasible,1:2);
infeasibleobj=obj(:,1:2);
infeasibleobj(feasible,:)=[];

front=vertcat(result.archiveFront.obj);

figure;
hold on
scatter(feasibleobj(:,1),feasibleobj(:,2),10,'fill','d');
scatter(infeasibleobj(:,1),infeasibleobj(:,2),10);
scatter(front(:,1),front(:,2),10,'*','MarkerEdgeColor','flat')

legend ('Feasible Data','Infeasible Data','Pareto Front')
title ('Multiple Objective Landscape')


LastGeneration=result.pops(gen,:);

FrontVar=vertcat(LastGeneration.var);
FrontObj=vertcat(LastGeneration.obj);
LastFront=[FrontVar,FrontObj,zeros(popsize,1)];

% topology
index=1;

  to=FrontVar(:,4:end);
  
   topologySet=to(1,:);

for i=1:popsize
    
   topology=to(i,:);
   [lia,locb]=ismember(topology,topologySet,'rows');
   
   if lia==0;
       topologySet=[topologySet;topology];
       index=index+1;
       
       LastFront(i,end)=index;
   else
        
       index=locb;
       LastFront(i,end)=index;
       index=max(LastFront(:,end));
   end 
    
end

% plot different topology
figure;
hold on
LegendStr=[];
for j=1:index
    [row1,~]=find(LastFront==j );
    
    scatter(FrontObj(row1,1),FrontObj(row1,2),30,'fill');
%     if LastFront(i,end)==1       
%         scatter(FrontObj(i,1),FrontObj(i,2),30,'b','fill','d');
%     else
%         scatter(FrontObj(i,1),FrontObj(i,2),30,'r','*'); 
%         
%     end
LegendStr=[LegendStr;num2str(topologySet(j,:))];
end

legend (LegendStr)
title ('Different Topology in Pareto Front');

sortedLastFront=sortrows(LastFront,8);
sortedLastFront2=[sortedLastFront(:,1:3)./10,sortedLastFront(:,4:end)];
end