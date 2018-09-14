function X=realrange(X,SampleOpt)

lb=SampleOpt.lb;
ub=SampleOpt.ub;

vartype=SampleOpt.type;

lb=repmat(lb,size(X,1),1);
ub=repmat(ub,size(X,1),1);

X=lb+(ub-lb).*X;

% Integer variable check
integIndex=find(vartype==2);
X(:,integIndex)=round(X(:,integIndex));

% variable limit check
X=VarLimitCheck(X,SampleOpt);

end

function X=VarLimitCheck(X,SampleOpt)
% check the limit of variables
lb=SampleOpt.lb;
ub=SampleOpt.ub;

lb=repmat(lb,size(X,1),1);
ub=repmat(ub,size(X,1),1);

lbcheck=(X<=lb);
ubcheck=(X>=ub);

indlb=find(lbcheck==1);
indub=find(ubcheck==1);

X(indlb)=lb(indlb);
X(indub)=ub(indub);


end