popsize=options.popsize;
gen=60;
obj=[];

for i=1:gen
    for j=1:popsize
        indi=[result.pops(i,j).obj result.pops(i,j).violSum];
        obj=[obj;indi];
        
    end
end

a=isnan(obj(:,1:2));
[m,n]=find(a==1);
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



LastGeneration=result.pops(gen,:);

LastVar=vertcat(LastGeneration.var);
LastObj=vertcat(LastGeneration.obj);
LastFront=[LastVar,LastObj,zeros(popsize,1)];

% topology
index=1;

  to=LastVar(:,4:end);
  
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
       
   end 
    
end

% plot different topology
figure;
hold on
for i=1:popsize
if LastFront(i,end)==1
    
    scatter(LastObj(i,1),LastObj(i,2),30,'b','fill','d');
else
    scatter(LastObj(i,1),LastObj(i,2),30,'r','*');

end
end


sortedLastFront=sortrows(LastFront,8);
sortedLastFront2=[sortedLastFront(:,1:3)./10,sortedLastFront(:,4:end)];