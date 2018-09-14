function DesignLoad=DesignFloorLoad(BuildingFloorNum)
%In this Case, the design load is calculated from the heat transfered in
%AHU. For further use, the design load can is an input calculated from
%Energy Plus using design day information.

DesignLoadF7=208387.1976;%W
DesignLoadF8=212461.4864;%W
DesignLoadF30=212461.4864;%W

DesignLoad=zeros(BuildingFloorNum,1);

for i=1:BuildingFloorNum
    if i<=7
        DesignLoad(i,1)=DesignLoadF7;
    elseif i<=BuildingFloorNum-1
        DesignLoad(i,1)=DesignLoadF8;
    else
        DesignLoad(i,1)=DesignLoadF30;
    end
end
end