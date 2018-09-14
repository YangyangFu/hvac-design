function [TotalConsumption,PowerAll,PowerPump,PenaltyC,EcoCost]=VerticalZoneBasis...
    (BuildingInfo,AirOA,...
        DesignInfo,OperationInfo,OperationSchedule,EquipmentParameter,ChillerSelection,ModelSelection)
% This subordinate is designed to calculate the GBCF HVAC power consumption
% under given vertical zone number and other water system topology range
% value.The main purpose is to simulate the hourly design energy
% consumption in a energy station.
% 
%==================== INPUT ====================
% X:                 matrix [1x6]          capacity indexes and number of three types of chiller
% BuildingInfo:      struct                building information
%                                          ZoneFloorNum: floor number in each zone
% AirOA:             struct                outdoor air psychrometical information
%
%=====================OUTPUT======================
%
%


%% Initialize 
global TimeStep

% Building Information
ZoneFloorNum=BuildingInfo.ZoneFloorNum;
MinVerticalZoneNum=size(ZoneFloorNum,1);


row=TimeStep;

SmallChillerNumMax=ChillerSelection.Small.ChillerNum;
MiddleChillerNumMax=ChillerSelection.Middle.ChillerNum;
LargeChillerNumMax=ChillerSelection.Large.ChillerNum;

% Chiller Resistance

TempDifferenceChilledWater=OperationInfo.WaterTempDifference.CC;% temperature difference of chilled water is 6 degree;
TempDifferenceCondenserWater=OperationInfo.WaterTempDifference.CW;% temperature difference of condenser water is 5 degree;

% parameter for chillers
CapacityChillerSmall=3517*ChillerSelection.Small.DesignCapacity;%Ton to W factor:3517; 100 means 100 Ton
%CapacityChillerSmall=ChillerSelection.CapacityChillerSmall
NominalCOPChillerSmall=ChillerSelection.Small.DesignCOP;
EvaFlowChillerSmall=CapacityChillerSmall./(4200*1000*TempDifferenceChilledWater);
ConFlowChillerSmall=(CapacityChillerSmall+CapacityChillerSmall/NominalCOPChillerSmall)...
    ./(4200*1000*TempDifferenceCondenserWater);


CapacityChillerMiddle=3517*ChillerSelection.Middle.DesignCapacity;
NominalCOPChillerMiddle=ChillerSelection.Middle.DesignCOP;%5.9;
EvaFlowChillerMiddle=CapacityChillerMiddle./(4200*1000*TempDifferenceChilledWater);
ConFlowChillerMiddle=(CapacityChillerMiddle+CapacityChillerMiddle/NominalCOPChillerMiddle)...
    ./(4200*1000*TempDifferenceCondenserWater);

CapacityChillerLarge=3517*ChillerSelection.Middle.DesignCapacity;
NominalCOPChillerLarge=ChillerSelection.Large.DesignCOP;
EvaFlowChillerLarge=CapacityChillerLarge./(4200*1000*TempDifferenceChilledWater);
ConFlowChillerLarge=(CapacityChillerLarge+CapacityChillerLarge/NominalCOPChillerLarge)...
    ./(4200*1000*TempDifferenceCondenserWater);

ParameterChillerSmall(1).coefficient=ChillerSelection.Small.CAPFTCoeff;
ParameterChillerSmall(2).coefficient=ChillerSelection.Small.EIRFTCoeff;
ParameterChillerSmall(3).coefficient=ChillerSelection.Small.EIRPLRCoeff;
ParameterChillerSmall(1).nominal=CapacityChillerSmall;
ParameterChillerSmall(2).nominal=NominalCOPChillerSmall;
ParameterChillerSmall(3).nominal=ChillerSelection.Small.ChillerMotorEff;
ParameterChillerSmall(1).flowrate=EvaFlowChillerSmall;
ParameterChillerSmall(2).flowrate=ConFlowChillerSmall;
ParameterChillerSmall(1).PLR=0.15;
ParameterChillerSmall(2).PLR=1.2;
ParameterChillerSmall(3).PLR=0.25;
if CapacityChillerSmall==0
    ParameterChillerSmall(1).resistance=65*1e3;
    ParameterChillerSmall(2).resistance=65*1e3;
else
   ParameterChillerSmall(1).resistance=65*1e3./(1000*EvaFlowChillerSmall).^2;
   ParameterChillerSmall(2).resistance=80*1e3./(1000*ConFlowChillerSmall).^2;
end


ParameterChillerSmall(1).density=999.4;   % water density at 10 ¡æ in evaporator;
ParameterChillerSmall(2).density=995.5;   % water density at 30 ¡æ in condenser;
ParameterChillerSmall(1).cp=4191.4;       % water specific heat at 10 ¡æ£»
ParameterChillerSmall(2).cp=4178.4;       % water specific heat at 30 ¡æ£»

ParameterChillerMiddle(1).coefficient=ChillerSelection.Middle.CAPFTCoeff;
ParameterChillerMiddle(2).coefficient=ChillerSelection.Middle.EIRFTCoeff;
ParameterChillerMiddle(3).coefficient=ChillerSelection.Middle.EIRPLRCoeff;
ParameterChillerMiddle(1).nominal=CapacityChillerMiddle;
ParameterChillerMiddle(2).nominal=NominalCOPChillerMiddle;
ParameterChillerMiddle(3).nominal=ChillerSelection.Middle.ChillerMotorEff;
ParameterChillerMiddle(1).flowrate=EvaFlowChillerMiddle;
ParameterChillerMiddle(2).flowrate=ConFlowChillerMiddle;
ParameterChillerMiddle(1).PLR=0.15;
ParameterChillerMiddle(2).PLR=1.2;
ParameterChillerMiddle(3).PLR=0.25;
if CapacityChillerMiddle==0
    ParameterChillerMiddle(1).resistance=65e3;
    ParameterChillerMiddle(2).resistance=80e3;
else
    
    ParameterChillerMiddle(1).resistance=65*1e3./(1000*EvaFlowChillerMiddle).^2;
    ParameterChillerMiddle(2).resistance=80*1e3./(1000*ConFlowChillerMiddle).^2;
end

ParameterChillerMiddle(1).density=999.4;   % water density at 10 ¡æ in evaporator;
ParameterChillerMiddle(2).density=995.5;   % water density at 30 ¡æ in condenser;
ParameterChillerMiddle(1).cp=4191.4;       % water specific heat at 10 ¡æ£»
ParameterChillerMiddle(2).cp=4178.4;       % water specific heat at 30 ¡æ£»

ParameterChillerLarge(1).coefficient=ChillerSelection.Large.CAPFTCoeff;
ParameterChillerLarge(2).coefficient=ChillerSelection.Large.EIRFTCoeff;
ParameterChillerLarge(3).coefficient=ChillerSelection.Large.EIRPLRCoeff;
ParameterChillerLarge(1).nominal=CapacityChillerLarge;
ParameterChillerLarge(2).nominal=NominalCOPChillerLarge;
ParameterChillerLarge(3).nominal=ChillerSelection.Large.ChillerMotorEff;
ParameterChillerLarge(1).flowrate=EvaFlowChillerLarge;
ParameterChillerLarge(2).flowrate=ConFlowChillerLarge;
ParameterChillerLarge(1).PLR=0.15;
ParameterChillerLarge(2).PLR=1.2;
ParameterChillerLarge(3).PLR=0.25;

if CapacityChillerLarge==0
    ParameterChillerLarge(1).resistance=65e3;
    ParameterChillerLarge(2).resistance=80e3;
else
    ParameterChillerLarge(1).resistance=65*1e3./(1000*EvaFlowChillerLarge).^2;
    ParameterChillerLarge(2).resistance=80*1e3./(1000*ConFlowChillerLarge).^2;
end

ParameterChillerLarge(1).density=999.4;   % water density at 10 ¡æ in evaporator;
ParameterChillerLarge(2).density=995.5;   % water density at 30 ¡æ in condenser;
ParameterChillerLarge(1).cp=4191.4;       % water specific heat at 10 ¡æ£»
ParameterChillerLarge(2).cp=4178.4;       % water specific heat at 30 ¡æ£»

Chiller(1).Parameter=ParameterChillerSmall;
Chiller(2).Parameter=ParameterChillerMiddle;
Chiller(3).Parameter=ParameterChillerLarge;

if CapacityChillerSmall==0
    SmallChillerNumMax=0;
end
if CapacityChillerMiddle==0
    MiddleChillerNumMax=0;
end
if CapacityChillerLarge==0
    LargeChillerNumMax=0;
end

Chiller(1).ChillerNumMax=SmallChillerNumMax;
Chiller(2).ChillerNumMax=MiddleChillerNumMax;
Chiller(3).ChillerNumMax=LargeChillerNumMax;

% Primary Pump
%load PrimaryPumpSizingDat

%Secondary Pump
% vertical zone 1 secondary pump


% vertical zone 2 primary pump


% vertical zone 2 sencondary pump

%  Heat Exchangers

HeatEx=EquipmentParameter.HeatExchanger;
HeatExchanger=cell(MinVerticalZoneNum-1,1);
for i=1:MinVerticalZoneNum-1
    HeatExchanger{i,1}=HeatEx;
end

% PARAMETERS FOR PIPES

% Sencondary System Pipe
AHUCCTempSetPoint=OperationSchedule.AHUCCTempSetPoint;

if AHUCCTempSetPoint>=13
    ParameterV1SecondaryPipe.k=(-0.125*AHUCCTempSetPoint.^2+4.035*AHUCCTempSetPoint-31.095);%1.5;
    ParameterV1SecondaryPipe.MassFlowRateCritic=0.03;
    
    ParameterV2PrimaryPipe.k=(-0.05*AHUCCTempSetPoint.^2+1.61*AHUCCTempSetPoint-10.97);
    ParameterV2PrimaryPipe.MassFlowRateCritic=0.03;
    
    ParameterV2SecondaryPipe.k=(-0.125*AHUCCTempSetPoint.^2+4.155*AHUCCTempSetPoint-32.685);
    ParameterV2SecondaryPipe.MassFlowRateCritic=0.03;
else
    
    ParameterV1SecondaryPipe.k=0.2;%1.5;
    ParameterV1SecondaryPipe.MassFlowRateCritic=0.03;
    
    ParameterV2PrimaryPipe.k=1.5;
    ParameterV2PrimaryPipe.MassFlowRateCritic=0.03;
    
    ParameterV2SecondaryPipe.k=0.2;
    ParameterV2SecondaryPipe.MassFlowRateCritic=0.03;
    
end

ParameterSecondaryPipe=cell(MinVerticalZoneNum,2);
i=1;
while i<=MinVerticalZoneNum
    if i==1
        ParameterSecondaryPipe{i,1}=ParameterV1SecondaryPipe;
        ParameterSecondaryPipe{i,2}=ParameterV2PrimaryPipe;
        
    else
        ParameterSecondaryPipe{i,1}=ParameterV2SecondaryPipe;
        ParameterSecondaryPipe{i,2}=ParameterV2PrimaryPipe;
    end
    i=i+1;
end

% Parameter for CT

% Parameter for condense pipe

% Parameters for condenser pump


EquipmentParameter.Chiller=Chiller;
EquipmentParameter.SecondaryPipe=ParameterSecondaryPipe;
EquipmentParameter.HeatExchanger=HeatExchanger;

%% Chilled Water Loop

[AirSide,ChillerOutput,PrimaryPumpOutput,SecondaryPumpOutput,PenaltyC,EcoCostChilledWater]=...
    ChilledWaterVerticalZoneBasis(BuildingInfo,AirOA,DesignInfo,OperationInfo,...
    OperationSchedule,EquipmentParameter,ModelSelection);

%% Condenser Loop
[CondenserPumpOutput,CTOutput,EcoCostCondenseWater]=CondenserWaterLoopBasis...
    (BuildingInfo,AirOA,DesignInfo,OperationInfo,...
    OperationSchedule,EquipmentParameter,ChillerOutput);

%% Update the Output
AllAHUPower=zeros(row,1);
i=1;
while i<=MinVerticalZoneNum
    for j=1:ZoneFloorNum(i)
        AllAHUPower=AllAHUPower+AirSide{i,1}.PowerAHU{j,1};
    end
    
    i=i+1;
end

SecondaryPumpPowerIndividual=zeros(row,2*MinVerticalZoneNum);
i=1;
j=1;
while i<=MinVerticalZoneNum
    SecondaryPumpPowerIndividual(:,j:j+1)=[SecondaryPumpOutput.PowerIndividual{i,1} ...
        SecondaryPumpOutput.PowerIndividual{i,2}];
    
    j=j+2;
    i=i+1;
end

AllSecondPumpPower=SecondaryPumpOutput.PowerAll;

AllChillerPower=sum([ChillerOutput(1).Power ChillerOutput(2).Power ChillerOutput(3).Power],2);

AllCondPumpPower=sum(CondenserPumpOutput.Power,2);

AllCTPower=sum([CTOutput(1).Power CTOutput(2).Power CTOutput(3).Power],2);

PowerAll=[AllAHUPower AllChillerPower PrimaryPumpOutput.PowerAll AllSecondPumpPower AllCondPumpPower AllCTPower];

PowerPump=[PrimaryPumpOutput.PowerAll SecondaryPumpPowerIndividual AllCondPumpPower];

TotalConsumption=sum(PowerAll,2);
TotalConsumption=sum(TotalConsumption);

EcoCost.ChilledWater=EcoCostChilledWater;
EcoCost.CondenseWater=EcoCostCondenseWater;

end

