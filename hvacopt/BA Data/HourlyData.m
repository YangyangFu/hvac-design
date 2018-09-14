% Since the BA Source data is written in each 5 minutes, So it's necessary
% to get them organized in hourly format.

%load AHU_August
a=PowerSplit(:,2);
[row,col]=size(a);

% Month Data

n=row/24;

DataHourly=zeros(n,col);

for i=1:n
   DataHourly(i,:)=sum(a(24*(i-1)+1:24*i,:));   
end


