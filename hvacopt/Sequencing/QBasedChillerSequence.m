function [ SmallON,MiddleON,LargeON] = QBasedChillerSequence( RealLoad,DesignLoad,MaxNum)
%QBasedChillerSequence aims to determine how and when to bring chillers
%online/offline based on cooling load measurement.
%

SmallDesignFlow=DesignLoad.Small;
MiddleDesignFlow=DesignLoad.Middle;
LargeDesignFlow=DesignLoad.Large;

SmallMaxNum=MaxNum.Small;
MiddleMaxNum=MaxNum.Middle;
LargeMaxNum=MaxNum.Large;

x1=SmallDesignFlow*[0:1:SmallMaxNum];
x2=MiddleDesignFlow*[0:1:MiddleMaxNum];
x3=LargeDesignFlow*[0:1:LargeMaxNum];

Data=zeros(SmallMaxNum+1,MiddleMaxNum+1,LargeMaxNum+1);
[row,col,height]=size(Data);

for i=1:SmallMaxNum+1
    for j=1:MiddleMaxNum+1
        for k=1:LargeMaxNum+1
            Data(i,j,k)=x1(i)+x2(j)+x3(k);
        end
    end
end

DataForSort=[];
for k=1:height
    for i=1:row
        DataForSort= horzcat(DataForSort,Data(i,:,k));
    end
end

SortedData=sort(DataForSort);

SortedDataMinus=SortedData-RealLoad;

PositiveInd=find(SortedDataMinus>=0,1,'first');

UpperValue=SortedData(PositiveInd);

[IndRow,IndCol1]=find(Data==UpperValue);


IndCol=mod(IndCol1,col);
IndHeight=fix(IndCol1/col)+1;

row1=size(IndCol,1);

i=1;
while i<=row1
    if IndCol(i)==0
        IndCol(i)=col;
        IndHeight(i)=fix(IndCol1(i)/col);
    end
    i=i+1;
end


if length(IndRow)~=1
    
    Sum=IndRow+IndCol+IndHeight;
    MinSum=min(Sum);
    
    IndRow1=find(Sum==MinSum);
    
    if length(IndRow1)>1
        
        SmallON=IndRow(IndRow1(1))-1;
        MiddleON=IndCol(IndRow1(1))-1;
        LargeON=IndHeight(IndRow1(1))-1;
    else
        
        SmallON=IndRow(1)-1;
        MiddleON=IndCol(1)-1;
        LargeON=IndHeight(1)-1;
    end
else
    SmallON=IndRow-1;
    MiddleON=IndCol-1;
    LargeON=IndHeight-1;
    
end


end

