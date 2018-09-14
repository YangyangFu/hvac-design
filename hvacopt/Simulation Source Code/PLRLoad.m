
ind=find(PLR>0);
row=size(ind,1);



LoadPLR=PLR(ind);
row=size(LoadPLR,1);

A=zeros(11,1);


for i=1:row
    if LoadPLR(i)<=0.1
        A(1)=A(1)+1;
    elseif LoadPLR(i)<=0.2
        A(2)=A(2)+1;
    elseif LoadPLR(i)<=0.3
        A(3)=A(3)+1;
    elseif LoadPLR(i)<=0.4
        A(4)=A(4)+1;
    elseif LoadPLR(i)<=0.5
        A(5)=A(5)+1;
    elseif LoadPLR(i)<=0.6
        A(6)=A(6)+1;
    elseif LoadPLR(i)<=0.7
        A(7)=A(7)+1;
    elseif LoadPLR(i)<=0.8
        A(8)=A(8)+1;
    elseif LoadPLR(i)<=0.9
        A(9)=A(9)+1;
    elseif LoadPLR(i)<=1
        A(10)=A(10)+1;
    else
        A(11)=A(11)+1;
    end
end

B=A/row;
C=[A,B];