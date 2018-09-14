function [CondenserPumpOutput,CTOutput,EcoCostCondenseWater]=CondenserWaterLoopBasis...
    (BuildingInfo,AirOA,DesignInfo,OperationInfo,...
    OperationSchedule,EquipmentParameter,ChillerOutput)

%% CONDENSER WATER LOOP
%% STEP 1：Give outdoor wet-bulb temperature , entering condenser water temperature , leaving condenser water temperature , condenser water massflow

PressureFactor=9.8063827784e3; % mh2o to Pa transformer;

% Building information
CTLocation=BuildingInfo.CTLocation;

% Outside Air

% Design Information
DesignPressure=DesignInfo.DesignPressure;

% Operation Information
DesCondWaterTempDiff=OperationInfo.WaterTempDifference.CW;% design temperature difference

% Operation Schedule
CTOutTempSetPoint=OperationSchedule.CTTempSetPoint;


% Equipment Parameter
CT=EquipmentParameter.CT;
Chiller=EquipmentParameter.Chiller;
ParameterCondensePipe=EquipmentParameter.CondensePipe;

% Chiller Output
ChillerSmallConOutlet=ChillerOutput(1).Condenser;
ChillerMiddleConOutlet=ChillerOutput(2).Condenser;
ChillerLargeConOutlet=ChillerOutput(3).Condenser;

NumONSmall=ChillerOutput(1).NumON;
NumONMiddle=ChillerOutput(2).NumON;
NumONLarge=ChillerOutput(3).NumON;

SmallChillerNumMax=Chiller(1).ChillerNumMax;
MiddleChillerNumMax=Chiller(2).ChillerNumMax;
LargeChillerNumMax=Chiller(3).ChillerNumMax;

row=size(ChillerOutput(1).Power,1);

CondWaterFlowRate=ChillerSmallConOutlet.flowrate+...
    ChillerMiddleConOutlet.flowrate+ChillerLargeConOutlet.flowrate;

ConLeaveTemp=zeros(row,1);
k=1;
while k<=row
    if CondWaterFlowRate(k)~=0
        ConLeaveTemp(k)=(ChillerLargeConOutlet.temp(k).*ChillerLargeConOutlet.flowrate(k)+...
            ChillerMiddleConOutlet.temp(k).*ChillerMiddleConOutlet.flowrate(k)...
            + ChillerSmallConOutlet.temp(k).*ChillerSmallConOutlet.flowrate(k))./CondWaterFlowRate(k);
    else
        ConLeaveTemp(k)=0;
    end
    k=k+1;
end

%% STEP 2; Calculate pressure rise of condenser water pumps

% --------------Chiller_COndenser------------------pipe-CwR_1--------------------

[PipeCwR_1FlowRate,PipeCwR_1Temp,PipeCwR_1DeltaP]=SimplifiedPipeValve...
        (CondWaterFlowRate,ConLeaveTemp,ParameterCondensePipe);

%--------------pipe_CwR_1----------CoolingTower----------------------------------
% *******************************************************************************
% ***********  Size the Cooling Tower by determining its cell number*************
% *******************************************************************************
ParameterCT=CT.Parameter;

NomCTSmallWaterFlow=Chiller(1).Parameter(2).flowrate;% size the cooling tower with chiller condenser flow rate
NumCellSmall=fix(NomCTSmallWaterFlow./(1.2*ParameterCT.NomFlow(1,2))+0.9999);
NomCTSmallWaterFlow=NumCellSmall*ParameterCT.NomFlow(1,2);

NomCTMiddleWaterFlow=Chiller(2).Parameter(2).flowrate;
NumCellMiddle=fix(NomCTMiddleWaterFlow./(1.2*ParameterCT.NomFlow(1,2))+0.9999);
NomCTMiddleWaterFlow=NumCellMiddle*ParameterCT.NomFlow(1,2);

NomCTLargeWaterFlow=Chiller(3).Parameter(2).flowrate;
NumCellLarge=fix(NomCTLargeWaterFlow./(1.2*ParameterCT.NomFlow(1,2))+0.9999);
NomCTLargeWaterFlow=NumCellLarge*ParameterCT.NomFlow(1,2);

CTAirInlet=AirOA;

% 冷却塔组流量分配原则---等比例分配
%NomCTSmallWaterFlow=ParameterCT.NomFlow(1,2);% [water flowrate(m3/s)]
%NomCTMiddleWaterFlow=ParameterCT.NomFlow(1,2);
%NomCTLargeWaterFlow=ParameterCT.NomFlow(1,2);
CTSmallFlowRate=zeros(row,1);
CTMiddleFlowRate=zeros(row,1);
CTLargeFlowRate=zeros(row,1);


for k=1:row
    if (NumONLarge(k)==0)&&(NumONMiddle(k)==0)&&(NumONSmall(k)==0)
        CTSmallFlowRate(k)=0;
        CTMiddleFlowRate(k)=0;
        CTLargeFlowRate(k)=0;
    else
        CTSmallFlowRate(k)=PipeCwR_1FlowRate(k).*NumONSmall(k).*NomCTSmallWaterFlow./...
            (NumONSmall(k).*NomCTSmallWaterFlow+NumONMiddle(k).*NomCTMiddleWaterFlow+NumONLarge(k).*NomCTLargeWaterFlow);
        
        CTMiddleFlowRate(k)=PipeCwR_1FlowRate(k).*NumONMiddle(k).*NomCTMiddleWaterFlow./...
            (NumONSmall(k).*NomCTSmallWaterFlow+NumONMiddle(k).*NomCTMiddleWaterFlow+NumONLarge(k).*NomCTLargeWaterFlow);
       
        CTLargeFlowRate(k)=PipeCwR_1FlowRate(k).*NumONLarge(k).*NomCTLargeWaterFlow./...
            (NumONSmall(k).*NomCTSmallWaterFlow+NumONMiddle(k).*NomCTMiddleWaterFlow+NumONLarge(k).*NomCTLargeWaterFlow);
    end
end


% Small cooling tower
CTSmallWaterInlet.temp=PipeCwR_1Temp;
CTSmallWaterInlet.flowrate=CTSmallFlowRate;
SizingParameterSmall.DesignPressure=DesignPressure;
SizingParameterSmall.NumParallelMax=SmallChillerNumMax;
[CTSmallWaterOut, CTSmallPower,CTSmallDeltaP,CTSmallHeatTrans,...
    CTSmallFanCyclingRatio, CTSmallSpeedSelected,CTSmallEff,CTSmallEcoCost]...
    = SingleSpeedCoolTower( CTAirInlet,CTSmallWaterInlet,CTOutTempSetPoint,NumONSmall,NumCellSmall ,ParameterCT,SizingParameterSmall);

% Middle cooling tower
CTMiddleWaterInlet.temp=PipeCwR_1Temp;
CTMiddleWaterInlet.flowrate=CTMiddleFlowRate;
SizingParameterMiddle.DesignPressure=DesignPressure;
SizingParameterMiddle.NumParallelMax=MiddleChillerNumMax;
[CTMiddleWaterOut, CTMiddlePower,CTMiddleDeltaP,CTMiddleHeatTrans,...
    CTMiddleFanCyclingRatio, CTMiddleSpeedSelected,CTMiddleEff,CTMiddleEcoCost]...
    = SingleSpeedCoolTower( CTAirInlet,CTMiddleWaterInlet,CTOutTempSetPoint,NumONMiddle,NumCellMiddle ,ParameterCT,SizingParameterMiddle);

% Large cooling tower
CTLargeWaterInlet.temp=PipeCwR_1Temp;
CTLargeWaterInlet.flowrate=CTLargeFlowRate;
SizingParameterLarge.DesignPressure=DesignPressure;
SizingParameterLarge.NumParallelMax=LargeChillerNumMax;
[CTLargeWaterOut, CTLargePower,CTLargeDeltaP,CTLargeHeatTrans,...
    CTLargeFanCyclingRatio, CTLargeSpeedSelected,CTLargeEff,CTLargeEcoCost]...
    = SingleSpeedCoolTower( CTAirInlet,CTLargeWaterInlet,CTOutTempSetPoint,NumONLarge,NumCellLarge ,ParameterCT,SizingParameterLarge);

CTEcoCost.Small=CTSmallEcoCost;
CTEcoCost.Middle=CTMiddleEcoCost;
CTEcoCost.Large=CTLargeEcoCost;

% 冷去塔组出水混合后温度
CTWaterOutTemp=zeros(row,1);
CTLargeFlowRate=CTLargeWaterOut.flowrate;
CTMiddleFlowRate=CTMiddleWaterOut.flowrate;
CTSmallFlowRate=CTSmallWaterOut.flowrate;
CTLargeWaterOutTemp=CTLargeWaterOut.temp;
CTMiddleWaterOutTemp=CTLargeWaterOut.temp;
CTSmallWaterOutTemp=CTLargeWaterOut.temp;
parfor k=1:row  
    if (CTLargeFlowRate(k)+CTMiddleFlowRate(k)+CTSmallFlowRate(k)~=0)
        CTWaterOutTemp(k)=(CTLargeFlowRate(k).*CTLargeWaterOutTemp(k)+CTSmallFlowRate(k).*CTSmallWaterOutTemp(k)...
            +CTMiddleFlowRate(k).*CTMiddleWaterOutTemp(k))./...
            (CTLargeFlowRate(k)+CTMiddleFlowRate(k)+CTSmallFlowRate(k));
    else
        CTWaterOutTemp(k)=0 ;
    end
end

% -------------------CoolingTower--------------Pipe_CwS_2----------------------
[PipeCwS_2FlowRate,PipeCwS_2Temp,PipeCwS_2DeltaP]=SimplifiedPipeValve...
        (CondWaterFlowRate,CTWaterOutTemp,ParameterCondensePipe);

% ------------------Pipe_CwS_1---------------------------------------------
[PipeCwS_1FlowRate,PipeCwS_1Temp,PipeCwS_1DeltaP]=SimplifiedPipeValve...
        (PipeCwS_2FlowRate,PipeCwS_2Temp,ParameterCondensePipe);

%-----------------Pipe_CwS_1--------------Chiller_Condenser-------------

%*******************************************************************
%***************         冷却水泵压头         ***********************
%*******************************************************************

%-----冷水机组冷凝器+Pipe_CwR_1+Cooling Tower+ Pipe_CwS_2+Pipe_CwS_1---------

CondPumpHeadNeed=max([ChillerSmallConOutlet.pressure_loss,ChillerMiddleConOutlet.pressure_loss,ChillerLargeConOutlet.pressure_loss],[],2)+...
    PipeCwR_1DeltaP+max([CTSmallDeltaP,CTMiddleDeltaP,CTLargeDeltaP],[],2)+PipeCwS_2DeltaP+PipeCwS_1DeltaP;

%% STEP 3: Calculate the power of condenser water pumps

% Size the condense pump
    ParameterCondLargePump=EquipmentParameter.Pump;
    ParameterCondMiddlePump=EquipmentParameter.Pump;
    ParameterCondSmallPump=EquipmentParameter.Pump;
    
    ParameterCondLargePump(1).IsVFD=0;
    ParameterCondMiddlePump(1).IsVFD=0;
    ParameterCondSmallPump(1).IsVFD=0;
    
    ParameterCondLargePump(1).nominal(1,1)=Chiller(3).Parameter(2).flowrate;%FlowRate [m3/s]
    ParameterCondMiddlePump(1).nominal(1,1)=Chiller(2).Parameter(2).flowrate;
    ParameterCondSmallPump(1).nominal(1,1)=Chiller(1).Parameter(2).flowrate;
    
    SortedCondPumpHead=sort(CondPumpHeadNeed,'descend');
    ParameterCondLargePump(1).nominal(1,2)=SortedCondPumpHead(21)./PressureFactor;% Head[m]
    ParameterCondMiddlePump(1).nominal(1,2)=ParameterCondLargePump(1).nominal(1,2);
    ParameterCondSmallPump(1).nominal(1,2)=ParameterCondLargePump(1).nominal(1,2);

    ParameterCondSmallPump(1).nominal(1,3:4)=[1450 0.85];
    ParameterCondMiddlePump(1).nominal(1,3:4)=[1450 0.85];
    ParameterCondLargePump(1).nominal(1,3:4)=[1450 0.85];



% 冷却泵泵组流量分配原则---等比例分配

NomCondPumpSmall=ParameterCondSmallPump(1).nominal;   % [flowrate(m3/s) head(m)  speed(rpm) power(w)]
NomCondPumpMiddle=ParameterCondMiddlePump(1).nominal;
NomCondPumpLarge=ParameterCondLargePump(1).nominal;
CondPumpSmallSpd=NomCondPumpSmall(1,3)*ones(row,1);
CondPumpMiddleSpd=NomCondPumpMiddle(1,3)*ones(row,1);
CondPumpLargeSpd=NomCondPumpLarge(1,3)*ones(row,1);
NomCondPumpSmallFlow=NomCondPumpSmall(1,1);
NomCondPumpMiddleFlow=NomCondPumpMiddle(1,1);
NomCondPumpLargeFlow=NomCondPumpLarge(1,1);


CondPumpSmallFlowRate=zeros(row,1);
CondPumpMiddleFlowRate=zeros(row,1);
CondPumpLargeFlowRate=zeros(row,1);

parfor k=1:row
    if (NumONLarge(k)==0)&&(NumONMiddle(k)==0)&&(NumONSmall(k)==0)
        CondPumpSmallFlowRate(k)=0;
        CondPumpMiddleFlowRate(k)=0;
        CondPumpLargeFlowRate(k)=0;
    else
        CondPumpSmallFlowRate(k)=CondWaterFlowRate(k).*NumONSmall(k).*NomCondPumpSmallFlow...
            ./(NumONSmall(k).*NomCondPumpSmallFlow+NumONMiddle(k).*NomCondPumpMiddleFlow+...
            NumONLarge(k).*NomCondPumpLargeFlow);
        CondPumpMiddleFlowRate(k)=CondWaterFlowRate(k).*NumONMiddle(k).*NomCondPumpMiddleFlow...
            ./(NumONSmall(k).*NomCondPumpSmallFlow+NumONMiddle(k).*NomCondPumpMiddleFlow+...
            NumONLarge(k).*NomCondPumpLargeFlow);
        CondPumpLargeFlowRate(k)=CondWaterFlowRate(k).*NumONLarge(k).*NomCondPumpLargeFlow...
            ./(NumONSmall(k).*NomCondPumpSmallFlow+NumONMiddle(k).*NomCondPumpMiddleFlow+...
            NumONLarge(k).*NomCondPumpLargeFlow);
    end

end

Schedule=logical(CondWaterFlowRate);
CondPumpInlet.temp=PipeCwS_2Temp;
SizingParameterCondSmallPump.DesignPressure=DesignPressure;
SizingParameterCondSmallPump.NumONMax=SmallChillerNumMax;
[~, CondPumpSmallPower,CondPumpSmallHead,CondPumpSmallEff,CondPumpSmallEcoCost]=DesignPumpVFD...
   ( CondPumpInlet,CondPumpSmallSpd, CondPumpSmallFlowRate,NumONSmall,Schedule,0,ParameterCondSmallPump,SizingParameterCondSmallPump);

SizingParameterCondMiddlePump.DesignPressure=DesignPressure;
SizingParameterCondMiddlePump.NumONMax=MiddleChillerNumMax;
[~, CondPumpMiddlePower,CondPumpMiddleHead,CondPumpMiddleEff,CondPumpMiddleEcoCost]=DesignPumpVFD...
   ( CondPumpInlet,CondPumpMiddleSpd, CondPumpMiddleFlowRate,NumONMiddle,Schedule,0,ParameterCondMiddlePump,SizingParameterCondMiddlePump );

SizingParameterCondLargePump.DesignPressure=DesignPressure;
SizingParameterCondLargePump.NumONMax=LargeChillerNumMax;
[~,CondPumpLargePower,CondPumpLargeHead,CondPumpLargeEff,CondPumpLargeEcoCost]=DesignPumpVFD...
    (CondPumpInlet,CondPumpLargeSpd, CondPumpLargeFlowRate,NumONLarge,Schedule,0,ParameterCondLargePump,SizingParameterCondLargePump);

CondPumpEcoCost.Small=CondPumpSmallEcoCost;
CondPumpEcoCost.Middle=CondPumpMiddleEcoCost;
CondPumpEcoCost.Large=CondPumpLargeEcoCost;

%% STEP 4: Calculate the fan power in cooling tower

%CTPower=CTSmallPower+CTMiddlePower+CTLargePower;



%% OUTPUT 
CondPumpPower=CondPumpLargePower+CondPumpMiddlePower+CondPumpSmallPower;

CondenserPumpOutput.Power=[CondPumpSmallPower CondPumpMiddlePower CondPumpLargePower];
CondenserPumpOutput.PressureDifference=[CondPumpSmallHead CondPumpMiddleHead CondPumpLargeHead];
CondenserPumpOutput.Efficiency=[CondPumpSmallEff CondPumpMiddleEff CondPumpLargeEff];
CondenserPumpOutput.AllPower=CondPumpPower;

CTOutput(1).WaterOut=CTSmallWaterOut;
CTOutput(2).WaterOut=CTMiddleWaterOut;
CTOutput(3).WaterOut=CTLargeWaterOut;
CTOutput(1).Power=CTSmallPower;
CTOutput(2).Power=CTMiddlePower;
CTOutput(3).Power=CTLargePower;
CTOutput(1).PressureDrop=CTSmallDeltaP;
CTOutput(2).PressureDrop=CTMiddleDeltaP;
CTOutput(3).PressureDrop=CTLargeDeltaP;
CTOutput(1).HeatFlow=CTSmallHeatTrans;
CTOutput(2).HeatFlow=CTMiddleHeatTrans;
CTOutput(3).HeatFlow=CTLargeHeatTrans;
CTOutput(1).Effectiveness=CTSmallEff;
CTOutput(2).Effectiveness=CTMiddleEff;
CTOutput(3).Effectiveness=CTLargeEff;

EcoCostCondenseWater.CondensePump=CondPumpEcoCost;
EcoCostCondenseWater.CT=CTEcoCost; 
EcoCostCondenseWater.All(:,1)=[CondPumpEcoCost.Small.CapCost;CondPumpEcoCost.Middle.CapCost;CondPumpEcoCost.Large.CapCost];
EcoCostCondenseWater.All(:,2)=[CTEcoCost.Small.CapCost;CTEcoCost.Middle.CapCost;CTEcoCost.Large.CapCost];

end

