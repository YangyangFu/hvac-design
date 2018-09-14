function [TopologyLowerBound,TopologyUpperBound]=TopologyRange(MinVerticalZoneNum,EnergyStationNum)

if EnergyStationNum==1
    
    if MinVerticalZoneNum<4
        Topology=1:1:MinVerticalZoneNum;
    else
        Topology=1;
    end
    
elseif EnergyStationNum==2
    if MinVerticalZoneNum==1
        Topology=1; % Under this circumstance, the total power comsumed by this system is infinite.
    elseif MinVerticalZoneNum==2
        Topology=1:1:1;
    elseif MinVerticalZoneNum==3
        Topology=1:1:4;
    elseif MinVerticalZoneNum==4
        Topology=1:1:10;
    elseif MinVerticalZoneNum==5
        Topology=1:1:12;
    elseif MinVerticalZoneNum==6
        Topology=1:1:9;
    else
        Topology=1:1:1;
    end
end

TopologyLowerBound=min(Topology);
TopologyUpperBound=max(Topology);

end