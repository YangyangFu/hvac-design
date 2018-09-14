function [ElectricityAll,GBCFPower,GBCFPowerPump,EcoCost,CapCostAll,C]=BuildingHVACSimulation(BuildingInfo,AirOA,...
    DesignInfo,OperationInfo,OperationSchedule,EquipmentParameter,ModelSelection)
%% Determine the minimum vertical zone number


MinVerticalZoneNum=BuildingInfo.MinVerticalZoneNum;
EnergyStationNum=BuildingInfo.EnergyStationNum;
TopologyRange=BuildingInfo.TopologyRange;
FloorHeight=BuildingInfo.FloorHeight;

% time step in the simulation
%TimeStep=length(OperationSchedule.Schedule);

% Floor Number in each zone
BuildingFloorNum=BuildingInfo.BuildingFloorNum;
ZoneFloorNum=zeros(MinVerticalZoneNum,1);
a=BuildingFloorNum/MinVerticalZoneNum;

if MinVerticalZoneNum==1
    ZoneFloorNum(1)=a;
else
    for i=1:2:MinVerticalZoneNum
        if i~=MinVerticalZoneNum
            if abs(a-fix(a))==0
                ZoneFloorNum(i)=fix(a);
                ZoneFloorNum(i+1)=fix(a);
            elseif (abs(a-fix(a))>0)&&(abs(a-fix(a))<0.5)
                ZoneFloorNum(i)=fix(a);
                ZoneFloorNum(i+1)=fix(a)+1;
            else
                ZoneFloorNum(i)=fix(a)+1;
                ZoneFloorNum(i+1)=fix(a);
            end
        else
            ZoneFloorNum(end)=BuildingFloorNum-sum(ZoneFloorNum(1:i-1));
        end
    end
end



%% topology and energy stations

if EnergyStationNum==1
    if ((MinVerticalZoneNum==1&&TopologyRange~=1)||(MinVerticalZoneNum...
            ==2&&TopologyRange>=2)||(MinVerticalZoneNum==3&&TopologyRange>=2)...
            ||(MinVerticalZoneNum>=4))
        ElectricityAll=1e10;
        GBCFPower=Inf;
        GBCFPowerPump=Inf;
        C=0;

        CapCostAll=1e7;
        EcoCost.CapCost=CapCostAll;
    else

        BuildingInfo.ZoneFloorNum=ZoneFloorNum;
        
        n=sum(ZoneFloorNum);
        DesignInfoZone.FloorData=DesignInfo.FloorData;
        DesignInfoZone.DesignPressure=DesignInfo.DesignPressure;
        
        %EquipmentParameterZone.DesCoilUA=EquipmentParameter.DesCoilUA...
            %(1:n);
        EquipmentParameterZone.FanDiameter=EquipmentParameter.FanDiameter...
            (1:n);
        EquipmentParameterZone.ParameterAHU=EquipmentParameter.ParameterAHU...
            (1:n);
        EquipmentParameterZone.ParameterVFDFan=EquipmentParameter.ParameterVFDFan...
            (1:n);
        
        EquipmentParameterZone.Pump=EquipmentParameter.Pump;        
        EquipmentParameterZone.HeatExchanger=EquipmentParameter.HeatExchanger;
        EquipmentParameterZone.PrimaryPipe=EquipmentParameter.PrimaryPipe;
        EquipmentParameterZone.CondensePipe=EquipmentParameter.CondensePipe;
        EquipmentParameterZone.CT=EquipmentParameter.CT;
        
        % ChillerSelectionZone=ChillerSelection{1,1};        
        % ChillerSelectionZone=ChillerSelectionFunct(BuildingInfo,1);
        ChillerSelectionZone=EquipmentParameter.S1.Chiller;
        
        
        [ElectricityAll,GBCFPower,GBCFPowerPump,C,EcoCost]=VerticalZoneBasis...
            (BuildingInfo,AirOA,DesignInfoZone,OperationInfo,...
            OperationSchedule,EquipmentParameterZone,ChillerSelectionZone,ModelSelection);
        
        CapCostAll=sum(sum(EcoCost.ChilledWater.All,2),1)+sum(sum(EcoCost.CondenseWater.All,2),1);
    end
    
elseif EnergyStationNum==2
    if MinVerticalZoneNum==1
        ElectricityAll=1e10;
        GBCFPower=Inf;
        GBCFPowerPump=Inf;
        C=0;
        CapCostAll=1e7;
        EcoCost.CapCost=CapCostAll;
        
    elseif MinVerticalZoneNum<=6
        
        [MinVerticalZoneNumSplit]=MinVertZoneNumEnergyStation(MinVerticalZoneNum);
        
        Topology=size(MinVerticalZoneNumSplit,2);
        
        if TopologyRange<=Topology
            % Station 1
            
            m=MinVerticalZoneNumSplit(1,TopologyRange);
            
            BuildingInfo1=BuildingInfo;
            BuildingInfo1.ZoneFloorNum=ZoneFloorNum(1:m,1);
            
            n=sum(ZoneFloorNum(1:m,1),1);
            %DesignInfoZone1=DesignInfo(1:n,1);
            DesignInfoZone1.FloorData=DesignInfo.FloorData(1:n,:);
            DesignInfoZone1.DesignPressure=DesignInfo.DesignPressure;
            
            
            %EquipmentParameterZone1.DesCoilUA=EquipmentParameter.DesCoilUA...
                %(1:n);
            EquipmentParameterZone1.FanDiameter=EquipmentParameter.FanDiameter...
                (1:n);
            EquipmentParameterZone1.ParameterAHU=EquipmentParameter.ParameterAHU...
                (1:n);
            EquipmentParameterZone1.ParameterVFDFan=EquipmentParameter.ParameterVFDFan...
                (1:n);
            
            EquipmentParameterZone1.Pump=EquipmentParameter.Pump; 
            EquipmentParameterZone1.HeatExchanger=EquipmentParameter.HeatExchanger;
            
            EquipmentParameterZone1.PrimaryPipe=EquipmentParameter.PrimaryPipe;
            EquipmentParameterZone1.CondensePipe=EquipmentParameter.CondensePipe;
            EquipmentParameterZone1.CT=EquipmentParameter.CT;
            
%             ChillerSelectionZone1=ChillerSelection{1,1}; % Station 1
             %ChillerSelectionZone1 = ChillerSelectionFunct(BuildingInfo1,1);
             ChillerSelectionZone1=EquipmentParameter.S1.Chiller;
             
            [y1,GBCFPower1,GBCFPowerPump1,CStation1,EcoCost1]=VerticalZoneBasis...
                (BuildingInfo1,AirOA,DesignInfoZone1,OperationInfo,...
                OperationSchedule,EquipmentParameterZone1,ChillerSelectionZone1,ModelSelection);
            
            % Station 2
            BuildingInfo2=BuildingInfo;
            BuildingInfo2.ZoneFloorNum=ZoneFloorNum(m+1:end,:);
            
            %DesignInfoZone2=DesignInfo(n+1:end,1);
            DesignInfoZone2.FloorData=DesignInfo.FloorData(n+1:end,:);
            DesignInfoZone2.DesignPressure=DesignInfo.DesignPressure;
            
            %EquipmentParameterZone2.DesCoilUA=EquipmentParameter.DesCoilUA...
                %(n+1:end,1);
            EquipmentParameterZone2.FanDiameter=EquipmentParameter.FanDiameter...
                (n+1:end,1);
            EquipmentParameterZone2.ParameterAHU=EquipmentParameter.ParameterAHU...
                (n+1:end,1);
            EquipmentParameterZone2.ParameterVFDFan=EquipmentParameter.ParameterVFDFan...
                (n+1:end,1);
            
            EquipmentParameterZone2.Pump=EquipmentParameter.Pump; 
            EquipmentParameterZone2.HeatExchanger=EquipmentParameter.HeatExchanger;
            
            EquipmentParameterZone2.PrimaryPipe=EquipmentParameter.PrimaryPipe;
            EquipmentParameterZone2.CondensePipe=EquipmentParameter.CondensePipe;
            EquipmentParameterZone2.CT=EquipmentParameter.CT;
            
           % ChillerSelectionZone2=ChillerSelection{2,1};
           % ChillerSelectionZone2=ChillerSelectionFunct(BuildingInfo2,2);
            ChillerSelectionZone2=EquipmentParameter.S2.Chiller;
            
            [y2,GBCFPower2,GBCFPowerPump2,CStation2,EcoCost2]=VerticalZoneBasis...
                (BuildingInfo2,AirOA,DesignInfoZone2,OperationInfo,...
                OperationSchedule,EquipmentParameterZone2,ChillerSelectionZone2,ModelSelection);
            
            EcoCost={EcoCost1,EcoCost2};
            GBCFPower={GBCFPower1;GBCFPower2};
            GBCFPowerPump={GBCFPowerPump1;GBCFPowerPump2};
            C=max(CStation1,CStation2);
            ElectricityAll=(y1+y2);
            CapCostAll1=sum(sum(EcoCost1.ChilledWater.All,2),1)+sum(sum(EcoCost1.CondenseWater.All,2),1);
            CapCostAll2=sum(sum(EcoCost2.ChilledWater.All,2),1)+sum(sum(EcoCost2.CondenseWater.All,2),1);
            CapCostAll=CapCostAll1+CapCostAll2;
        else
            ElectricityAll=1e10;
            GBCFPower=Inf;
            GBCFPowerPump=Inf;
            C=0;
            CapCostAll=1e7;
            EcoCost.CapCost=CapCostAll;
        end
    else
        ElectricityAll=1e10;
        GBCFPower=Inf;
        GBCFPowerPump=Inf;
        C=0;
        CapCostAll=1e7;
        EcoCost.CapCost=CapCostAll;
    end
    
    % Minimum vertical zone number is greater than 3
else
    ElectricityAll=1e10;
    GBCFPower=Inf;
    GBCFPowerPump=Inf;
    C=0;
    CapCostAll=1e7;
    EcoCost.CapCost=CapCostAll;
end

end