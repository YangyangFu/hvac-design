function [MinVerticalZoneNumSplit]=MinVertZoneNumEnergyStation(MinVerticalZoneNum)
% This function is used to split the vertical zone number based on
% two energy stations.


Station1=1:1:MinVerticalZoneNum-1;
Station2=MinVerticalZoneNum-Station1;

MinVerticalZoneNumSplit=[Station1;Station2];

% delete the columns with values greater than 3.

[~,c]=find(MinVerticalZoneNumSplit>3);
MinVerticalZoneNumSplit(:,c)=[];

end

