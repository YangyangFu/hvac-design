function [AirSide,ChillerOutput,PrimaryPumpOutput,SecondaryPumpOutput,PenaltyC,EcoCostChilledWater]...
    =ChilledWaterVerticalZoneBasis(BuildingInfo,AirOA,DesignInfo,OperationInfo,...
    OperationSchedule,EquipmentParameter,ModelSelection)
%% Step 1. Air Loop.
% Calculate air loop for outlet conditions of AHUs, then use this secondary
% system to calculate the primary system.

%                  &&&
%               &&&&&&&&
%             &&&& 1.1 &&&
%               &&&&&&&&
%                  &&&
% Give load data,design cretiea, building information such as floor number
% in zone,floor-to-floor height,inlet water temperature etc.

ZoneFloorNum=BuildingInfo.ZoneFloorNum;% matrix storing the number of vertical zones.
FloorHeight=BuildingInfo.FloorHeight;
MinVerticalZoneNum=size(ZoneFloorNum,1);

DesignPressure=DesignInfo.DesignPressure;
FloorData=DesignInfo.FloorData;

AirSide=cell(MinVerticalZoneNum,1);
WaterSide=cell(MinVerticalZoneNum,1);
MixWaterFlowAHU=cell(MinVerticalZoneNum,1);
MixWaterTempAHU=cell(MinVerticalZoneNum,1);
EconomicCostAirLoop=cell(MinVerticalZoneNum,1);

RealLoad=zeros(size(AirOA.temp));


%                  &&&
%               &&&&&&&&
%             &&&& 1.2 &&&
%               &&&&&&&&
%                  &&&
%  Calculate the air loop from zone 1 to zone n by AirLoopBasis.
for i=1:MinVerticalZoneNum
    %INPUT: BuildingInfo
    BuildingInfoVertical.ZoneFloorNum=ZoneFloorNum(i);
    
    if i==1
        %INPUT: AirOA
        %------------------------
        %INPUT: DesignInfo
        DesignInfoVertical.FloorData=FloorData(1:ZoneFloorNum(i),:);
        DesignInfoVertical.DesignPressure=DesignPressure;
        %INPUT: OperationInfo
        %------------------------
        %INPUT: OperationSchedule
        OperationScheduleVertical=OperationSchedule;
        %INPUT: EquipmentParameter
        %EquipmentParameterVertical.DesCoilUA=EquipmentParameter.DesCoilUA...
        %(1:ZoneFloorNum(i),:);
        EquipmentParameterVertical.FanDiameter=EquipmentParameter.FanDiameter...
            (1:ZoneFloorNum(i),:);
        EquipmentParameterVertical.ParameterAHU=EquipmentParameter.ParameterAHU...
            (1:ZoneFloorNum(i),:);
        EquipmentParameterVertical.ParameterVFDFan=EquipmentParameter.ParameterVFDFan...
            (1:ZoneFloorNum(i),:);
        
    else % AHU 进水温度+1℃
        a=sum(ZoneFloorNum(1:i-1),1);
        b=sum(ZoneFloorNum(1:i),1);
        %INPUT: AirOA
        %------------------------
        %INPUT: DesignInfo
        DesignInfoVertical.FloorData=FloorData(a+1:b,:);
        DesignInfoVertical.DesignPressure=DesignPressure;
        %INPUT: OperationInfo
        %------------------------
        %INPUT: OperationSchedule
        OperationScheduleVertical.AHUCCTempSetPoint=OperationSchedule.AHUCCTempSetPoint;
        OperationScheduleVertical.ChillerTempSetPoint=OperationSchedule.ChillerTempSetPoint+(i-1)*1;
        OperationScheduleVertical.BoilerTempSetPoint=OperationSchedule.BoilerTempSetPoint;
        OperationScheduleVertical.CTTempSetPoint=OperationSchedule.CTTempSetPoint;
        %INPUT: EquipmentParameter
        %EquipmentParameterVertical.DesCoilUA=EquipmentParameter.DesCoilUA...
        %(a+1:b,:);
        EquipmentParameterVertical.FanDiameter=EquipmentParameter.FanDiameter...
            (a+1:b,:);
        EquipmentParameterVertical.ParameterAHU=EquipmentParameter.ParameterAHU...
            (a+1:b,:);
        EquipmentParameterVertical.ParameterVFDFan=EquipmentParameter.ParameterVFDFan...
            (a+1:b,:);
        
        
    end
   
    [AirSideVertical,WaterSideVertical,MixWaterFlowAHUVertical,MixWaterTempAHUVertical,EconomicCostAirLoopBasis]=...
        AirLoopBasis(BuildingInfoVertical,AirOA,...
        DesignInfoVertical,OperationInfo,OperationScheduleVertical,EquipmentParameterVertical,ModelSelection);
    
    AirSide{i,1}=AirSideVertical;
    WaterSide{i,1}=WaterSideVertical;
    MixWaterFlowAHU{i,1}=MixWaterFlowAHUVertical;
    MixWaterTempAHU{i,1}=MixWaterTempAHUVertical;
    EconomicCostAirLoop{i,1}=EconomicCostAirLoopBasis; 
    for j=1:ZoneFloorNum(i)
    RealLoad=RealLoad+AirSideVertical.TotalHeatTransfer{j,1};
    end
end


%% Step 2. Chilled Water Loop
% Calculate the chilled water loop based on topology basis 2--TWO ZONES.

%                  &&&
%               &&&&&&&&
%             &&&& 2.1 &&&
%               &&&&&&&&
%                  &&&
%**** Since water flowrate and outlet water temperature is calculated from step
%**** 1,here just give inlet condenser water temperature.

PressureFactor=9.8063827784e3; % mh2o to Pa transformer;
BorametricPressure=101325;% Pa


WaterFlowOutletCC=cell(MinVerticalZoneNum,1);
WaterDeltaPOutletCC=cell(MinVerticalZoneNum,1);
SecondaryFlowRateAHU=cell(MinVerticalZoneNum,1);
SecondaryReturnTempAHU=cell(MinVerticalZoneNum,1);


for i=1:MinVerticalZoneNum
    WaterFlowOutletCC{i,1}=WaterSide{i,1}.WaterFlowOutletCC;
    WaterDeltaPOutletCC{i,1}=WaterSide{i,1}.WaterDeltaPOutletCC;
    SecondaryFlowRateAHU{i,1}=MixWaterFlowAHU{i,1};
    SecondaryReturnTempAHU{i,1}=MixWaterTempAHU{i,1};
end

ChillerTempSetPoint=OperationSchedule.ChillerTempSetPoint;
BoilerTempSetPoint=OperationSchedule.BoilerTempSetPoint;
CTOutTempSetPoint=OperationSchedule.CTTempSetPoint;

row=length(AirOA.temp);
% row=size(WaterSide{1,1}.WaterFlowOutletCC,1);
ChillerCwEnterTemp=CTOutTempSetPoint*ones(row,1);
ChillerTempSetPoint=ChillerTempSetPoint*ones(row,1);

Chiller=EquipmentParameter.Chiller;

ParameterPrimaryPipe=EquipmentParameter.PrimaryPipe;
ParameterSecondaryPipe=EquipmentParameter.SecondaryPipe;

HeatExchanger=EquipmentParameter.HeatExchanger;

% LOCAL PARAMETERS
SecondaryReturnTempZone=cell(MinVerticalZoneNum,1);
SecondaryFlowRateZone=cell(MinVerticalZoneNum,1);
SecondaryPumpFlowRate=cell(MinVerticalZoneNum,2);


%                  &&&
%               &&&&&&&&
%             &&&& 2.2 &&&
%               &&&&&&&&
%                  &&&
%**** Calculate flowrate in heat exchangers on both sides.
%**** In exchangers, information on secondary side are used to determine
%**** that on primary side.
%%%%%%% HOW TO SET THE EXCHANGERS' PARAMETERS %%%%%%%%
HeatExEcoCostAll=0;

if MinVerticalZoneNum==1
    SecondaryFlowRateZone{1,1}=SecondaryFlowRateAHU{1,1};
    SecondaryReturnTempZone{1,1}=SecondaryReturnTempAHU{1,1};
    SecondaryPumpFlowRate{1,1}=SecondaryFlowRateAHU{1,1};
    SecondaryPumpFlowRate{1,2}=zeros(row,1);
    EconomicCostHXVertical.CapCost=0;
    HeatExEcoCost{1,1}=EconomicCostHXVertical;
    HeatExEcoCostAll=HeatExEcoCostAll+EconomicCostHXVertical.CapCost;
else
    ColdSideOutlet=cell(MinVerticalZoneNum-1,1);
    HotSideOutlet=cell(MinVerticalZoneNum-1,1);
    HeatExHeatFlow=cell(MinVerticalZoneNum-1,1);
    HeatExEffectiveness=cell(MinVerticalZoneNum-1,1);
    HeatExEcoCost=cell(MinVerticalZoneNum-1,1);
    
    i=2;
    while i<=MinVerticalZoneNum
        % Exchanger INPUT
        
        j=MinVerticalZoneNum+1-i;
        
        if j==MinVerticalZoneNum-1 %最上层板换
            
            ColdSideInlet.temp=ChillerTempSetPoint+(j-1)*1;% 高区冷水供水温度： +1℃
            
            SecondaryFlowRateZone{j+1,1}=SecondaryFlowRateAHU{j+1,1};
            HotSideInlet.flowrate=SecondaryFlowRateZone{j+1,1};
            
            SecondaryReturnTempZone{j+1,1}=SecondaryReturnTempAHU{j+1,1};
            HotSideInlet.temp=SecondaryReturnTempZone{j+1,1}; % 分区内板换与AHU混合后的温度      
            
            HeatEx=HeatExchanger{j,1};        
            HeatExType=HeatEx.Type;
            HeatExParameter=HeatEx.Parameter;
            DesColdSideInlet=HeatEx.DesColdSideInlet;
            DesHotSideInlet=HeatEx.DesHotSideInlet;
            
            SortedFlowRate=sort(HotSideInlet.flowrate,'descend');
            if SortedFlowRate(21)<=0.1
                HeatExParallelNumMax=1;
                HeatExParameter.nominal=[SortedFlowRate(21),SortedFlowRate(21)];
            else
                HeatExParallelNumMax=round(SortedFlowRate(21)/0.1);
                HeatExParameter.nominal=[SortedFlowRate(21)/HeatExParallelNumMax,SortedFlowRate(21)/HeatExParallelNumMax];
            end
            DesignResistance=40*1e3./(RhoWater(DesColdSideInlet.temp)*HeatExParameter.nominal(1,1)).^2;
            HeatExParameter.resistance=[DesignResistance,DesignResistance];
            
            HeatExSizingParameter.DesignPressure=DesignPressure;
            HeatExSizingParameter.NumONMax=HeatExParallelNumMax;
            % Calculate design UA
            
            DesColdSideInlet.flowrate=HeatExParameter.nominal(1,1);
            DesHotSideInlet.flowrate=HeatExParameter.nominal(1,2);
            
            
            HeatExDesignUA=DesUAExch(DesColdSideInlet,DesHotSideInlet,HeatExType,HeatExParameter,HeatExSizingParameter);
            HotSideOutletTemp=ColdSideInlet.temp+1;% 1℃的品质降低
            
            % Heat Exchanger sequence
            Schedule=logical(HotSideInlet.flowrate);
            
           HeatExParallelNumON=QBasedSequence(HotSideInlet.flowrate,HeatExParameter.nominal(1,2),HeatExParallelNumMax);
        
            [ColdSideOutletVertical,HotSideOutletVertical,HeatExHeatFlowVertical,...
                HeatExEffectivenessVertical,EconomicCostHXVertical]=DesHeatExchangerR(ColdSideInlet,HotSideInlet,...
                HotSideOutletTemp,HeatExDesignUA,HeatExParallelNumON,Schedule,HeatExType,HeatExParameter,HeatExSizingParameter);
        
            ColdSideOutlet{j,1}=ColdSideOutletVertical;
            HotSideOutlet{j,1}=HotSideOutletVertical;
            HeatExHeatFlow{j,1}=HeatExHeatFlowVertical;
            HeatExEffectiveness{j,1}=HeatExEffectivenessVertical;
            HeatExEcoCost{j,1}=EconomicCostHXVertical;
            
            SecondaryPumpFlowRate{j+1,1}=SecondaryFlowRateAHU{j+1,1};
            SecondaryPumpFlowRate{j+1,2}=zeros(row,1);
            
        else
            ColdSideInlet.temp=ChillerTempSetPoint+(j-1)*1;% 高区冷水供水温度： +1℃
            
            SecondaryFlowRateZone{j+1,1}=SecondaryFlowRateAHU{j+1,1}+ColdSideOutlet{j+1,1}.flowrate;%上层板换冷水侧与分区内AHU混合后流量
            HotSideInlet.flowrate=SecondaryFlowRateZone{j+1,1};
            
            ind=find(HotSideInlet.flowrate~=0);
            SecondaryReturnTempZone{j+1,1}=zeros(row,1);
            SecondaryReturnTempZone{j+1,1}(ind)=(SecondaryFlowRateAHU{j+1,1}(ind,1).*SecondaryReturnTempAHU{j+1,1}(ind,1)+...
                ColdSideOutlet{j+1,1}.flowrate(ind,1).*ColdSideOutlet{j+1,1}.temp(ind,1))./HotSideInlet.flowrate(ind,1);
            
            HotSideInlet.temp=SecondaryReturnTempZone{j+1,1}; % 分区内板换与AHU混合后的温度
             
            HeatExType=HeatEx.Type;
            HeatExParameter=HeatEx.Parameter;
            
            SortedFlowRate=sort(HotSideInlet.flowrate,'descend');
            if SortedFlowRate(21)<=0.1
                HeatExParallelNumMax=1;
                HeatExParameter.nominal=[SortedFlowRate(21),SortedFlowRate(21)];
            else
                HeatExParallelNumMax=round(SortedFlowRate(21)/0.1);
                HeatExParameter.nominal=[SortedFlowRate(21)/HeatExParallelNumMax,SortedFlowRate(21)/HeatExParallelNumMax];
            end
            DesignResistance=40*1e3./(RhoWater(DesColdSideInlet.temp)*HeatExParameter.nominal(1,1)).^2;
            HeatExParameter.resistance=[DesignResistance,DesignResistance];
            
            HeatExSizingParameter.DesignPressure=DesignPressure;
            HeatExSizingParameter.NumONMax=HeatExParallelNumMax;
            
            % Calculate design UA
            DesColdSideInlet=HeatEx.DesColdSideInlet;
            DesColdSideInlet.flowrate=HeatExParameter.nominal(1,1);
            DesHotSideInlet=HeatEx.DesHotSideInlet;
            DesHotSideInlet.flowrate=HeatExParameter.nominal(1,2);
            
            HeatExDesignUA=DesUAExch(DesColdSideInlet,DesHotSideInlet,HeatExType,HeatExParameter,HeatExSizingParameter);
            
            HotSideOutletTemp=ColdSideInlet.temp+1;% 1℃的品质降低;
             % Heat Exchanger sequence
             Schedule=logical(HotSideInlet.flowrate);
            
           HeatExParallelNumON=QBasedSequence(HotSideInlet.flowrate,HeatExParameter.nominal(1,2),HeatExParallelNumMax);
          
            [ColdSideOutletVertical,HotSideOutletVertical,HeatExHeatFlowVertical,...
                HeatExEffectivenessVertical,EconomicCostHXVertical]=DesHeatExchangerR(ColdSideInlet,HotSideInlet,...
                HotSideOutletTemp,HeatExDesignUA,HeatExParallelNumON,Schedule,HeatExType,HeatExParameter,HeatExSizingParameter);
            
            ColdSideOutlet{j,1}=ColdSideOutletVertical;
            HotSideOutlet{j,1}=HotSideOutletVertical;
            HeatExHeatFlow{j,1}=HeatExHeatFlowVertical;
            HeatExEffectiveness{j,1}=HeatExEffectivenessVertical;
            HeatExEcoCost{j,1}=EconomicCostHXVertical;
            
            SecondaryPumpFlowRate{j+1,1}=SecondaryFlowRateAHU{j+1,1};
            SecondaryPumpFlowRate{j+1,2}=ColdSideOutlet{j+1,1}.flowrate;
        end
        
           HeatExEcoCostAll=HeatExEcoCostAll+EconomicCostHXVertical.CapCost;
        
        i=i+1;
    end
    % secondary return temperature in the lowest zone with chillers
    SecondaryFlowRateZone{1,1}=ColdSideOutlet{1,1}.flowrate+SecondaryFlowRateAHU{1,1};
    
    SecondaryReturnTempZone{1,1}=zeros(row,1);
    ind=find(SecondaryFlowRateZone{1,1}~=0);
    SecondaryReturnTempZone{1,1}(ind)=(SecondaryFlowRateAHU{1,1}(ind,1).*...
        SecondaryReturnTempAHU{1,1}(ind,1)+ColdSideOutlet{1,1}.flowrate(ind,1)...
        .*ColdSideOutlet{1,1}.temp(ind,1))./SecondaryFlowRateZone{1,1}(ind,1);
    
    SecondaryPumpFlowRate{1,1}=SecondaryFlowRateAHU{1,1};
    SecondaryPumpFlowRate{1,2}=ColdSideOutlet{1,1}.flowrate;
end




%%                  &&&
%               &&&&&&&&
%             &&&& 2.3 &&&
%               &&&&&&&&
%                  &&&
%**** Calculate flowrate in primary pumping system, by determining the
%**** online number of operating chillers.

% Three types of chillers are used in design process.
NumONSmallMax=Chiller(1).ChillerNumMax;
NumONMiddleMax=Chiller(2).ChillerNumMax;
NumONLargeMax=Chiller(3).ChillerNumMax;

ParameterChillerSmall=Chiller(1).Parameter;
ParameterChillerMiddle=Chiller(2).Parameter;
ParameterChillerLarge=Chiller(3).Parameter;

EvaNomFlowSmall=ParameterChillerSmall(1).flowrate;
EvaNomFlowMiddle=ParameterChillerMiddle(1).flowrate;
EvaNomFlowLarge=ParameterChillerLarge(1).flowrate;

NumONSmall=zeros(row,1);
NumONMiddle=zeros(row,1);
NumONLarge=zeros(row,1);

% 冷机垂直区域二次水流量：假设冷机位于最下层分区V1
SecondaryFlowRateV1=SecondaryFlowRateZone{1,1};    %冷水机组所在区二次水回水流量
SecondaryReturnTempV1=SecondaryReturnTempZone{1,1};%冷水机组所在区二次水回水温度


% 建立根据流量开启冷机的最优策略---线性一次规划--a MILP problem[******]This part has been
% discard because of huge calculation.

MaxNum.Small=NumONSmallMax;
MaxNum.Middle=NumONMiddleMax;
MaxNum.Large=NumONLargeMax;


% %QBased
% DesignLoadChiller.Small=ParameterChillerSmall(1).nominal;
% DesignLoadChiller.Middle=ParameterChillerMiddle(1).nominal;
% DesignLoadChiller.Large=ParameterChillerLarge(1).nominal;
% 
% 
% [NumONSmall,NumONMiddle,NumONLarge]=ChillerSequence(...
%             RealLoad,DesignLoadChiller,MaxNum);

%FBased
DesignFlowChiller.Small=EvaNomFlowSmall;
DesignFlowChiller.Middle=EvaNomFlowMiddle;
DesignFlowChiller.Large=EvaNomFlowLarge;

[NumONSmall,NumONMiddle,NumONLarge]=ChillerSequence(...
            SecondaryFlowRateV1,DesignFlowChiller,MaxNum);       
% 
%         
PrimaryFlowRate=NumONSmall.*EvaNomFlowSmall+NumONMiddle.*...
    EvaNomFlowMiddle+NumONLarge.*EvaNomFlowLarge;

%                  &&&
%               &&&&&&&&
%             &&&& 2.4 &&&
%               &&&&&&&&
%                  &&&
%**** Calculate the flowrate and direction in common pipe.

BypassFlowRate=PrimaryFlowRate-SecondaryFlowRateV1;
% 
% index=find(BypassFlowRate<0);
% if ~isempty(index)
%     NumONSmall(index)=NumONSmallF(index);
%     NumONMiddle(index)=NumONMiddleF(index);
%     NumONLarge(index)=NumONLargeF(index);
% end
% %
% PrimaryFlowRate=NumONSmall.*EvaNomFlowSmall+NumONMiddle.*...
%     EvaNomFlowMiddle+NumONLarge.*EvaNomFlowLarge;
% BypassFlowRate=PrimaryFlowRate-SecondaryFlowRateV1;

%                  &&&
%               &&&&&&&&
%             &&&& 2.5 &&&
%               &&&&&&&&
%                  &&&
%**** If reverse flow occurs in common pipe,the inlet temperature of
%**** AHUs will not be the setpoint temperature of chillers and should be
%**** recalculated. But we try to avoid such situation.

%                  &&&
%               &&&&&&&&
%             &&&& 2.6 &&&
%               &&&&&&&&
%                  &&&
%**** Calculate the return temperature in primary pumping system.

% Temperature rise in pipes and pumps is not considered.
BypassWaterTemp=zeros(row,1);
PrimaryReturnTemp=zeros(row,1);

k=1;
while k<=row
    if BypassFlowRate(k)>=0
        BypassWaterTemp(k)=ChillerTempSetPoint(k);
        if PrimaryFlowRate(k)~=0
            PrimaryReturnTemp(k)=(BypassFlowRate(k).*BypassWaterTemp(k)+...
                SecondaryFlowRateV1(k).*SecondaryReturnTempV1(k))./PrimaryFlowRate(k);
        else
            PrimaryReturnTemp(k)=0;
        end
    else
        BypassWaterTemp(k)=SecondaryReturnTempV1(k);
        PrimaryReturnTemp(k)=SecondaryReturnTempV1(k);
    end
    k=k+1;
end

%%                  &&&
%               &&&&&&&&
%             &&&& 2.7 &&&
%               &&&&&&&&
%                  &&&
%**** Pressure Drop through pipes,valves and equipment.

% start from the return water in primary system

[~,PipeChwR0_2TempOut,PipeChwR0_2DeltaP]=SimplifiedPipeValve...
    (PrimaryFlowRate,PrimaryReturnTemp,ParameterPrimaryPipe);

%---------------PRImary Pump------pipe_ChwR_0_1---------------------
% Since temperature rise in pipe and pump is not considered in this
% system,pump outlet temperature is equal to primary return temperature.

PrimaryPumpOutletTemp=PrimaryReturnTemp;

[PipeChwR0_1FlowRate,PipeChwR0_1TempOut,PipeChwR0_1DeltaP]=SimplifiedPipeValve...
    (PrimaryFlowRate,PrimaryPumpOutletTemp,ParameterPrimaryPipe);

%--------------------pipe_pipe_ChwR_0_1-------chiller------------------------
Schedule=logical(PrimaryFlowRate);

% Samll chiller parallel
SizingParameterChillerSmall.DesignPressure=DesignPressure;
SizingParameterChillerSmall.NumONMax=NumONSmallMax;
[ChillerSmallEvaOutlet,ChillerSmallConOutlet,ChillerSmallPower,ChillerSmallHeatEva,...
    ChillerSmallCOP,ChillerSmallPLR,ChillerSmallEcoCost]=DesEleChillerEIR(PipeChwR0_1TempOut,...
    ChillerCwEnterTemp,ChillerTempSetPoint,NumONSmall,Schedule,ParameterChillerSmall,SizingParameterChillerSmall);

%Middle chiller parallel
SizingParameterChillerMiddle.DesignPressure=DesignPressure;
SizingParameterChillerMiddle.NumONMax=NumONMiddleMax;
[ChillerMiddleEvaOutlet,ChillerMiddleConOutlet,ChillerMiddlePower,ChillerMiddleHeatEva,...
    ChillerMiddleCOP,ChillerMiddlePLR,ChillerMiddleEcoCost]=DesEleChillerEIR(PipeChwR0_1TempOut,...
    ChillerCwEnterTemp,ChillerTempSetPoint,NumONMiddle,Schedule,ParameterChillerMiddle,SizingParameterChillerMiddle);

% Large chiller parallel
SizingParameterChillerLarge.DesignPressure=DesignPressure;
SizingParameterChillerLarge.NumONMax=NumONLargeMax;
[ChillerLargeEvaOutlet,ChillerLargeConOutlet,ChillerLargePower,ChillerLargeHeatEva,...
    ChillerLargeCOP,ChillerLargePLR,ChillerLargeEcoCost]=DesEleChillerEIR(PipeChwR0_1TempOut,...
    ChillerCwEnterTemp,ChillerTempSetPoint,NumONLarge,Schedule,ParameterChillerLarge,SizingParameterChillerLarge);

ChillerEcoCost.Small=ChillerSmallEcoCost;
ChillerEcoCost.Middle=ChillerMiddleEcoCost;
ChillerEcoCost.Large=ChillerLargeEcoCost;

ChillerHeatEVA=ChillerSmallHeatEva+ChillerMiddleHeatEva+ChillerLargeHeatEva;
% 冷机组出水混合后温度
% Since ideal control is used in chillers, which means the chiller
% evaporator outlet temperature is always equal to its setpoint, the mixed
% temperature in chiller parallels is still equal to that setpoint.

%--------------chiller------pipe_ChwS_0_1---------------
%[PipeChwS0_1FlowRate,PipeChwS0_1Temp,PipeChwS0_1DeltaP]=DetailedPipe...
%    (PrimaryFlowRate,ChillerTempSetPoint,30,DiameterPipe,ParameterPrimaryPipe);
[PipeChwS0_1FlowRate,PipeChwS0_1Temp,PipeChwS0_1DeltaP]=SimplifiedPipeValve...
    (PrimaryFlowRate,ChillerTempSetPoint,ParameterPrimaryPipe);

%--------------pipe_ChwS_0_1---------pipe_bypass---------
% [BypassFlowRate,BypassOutletTemp,BypassDeltaP]=DetailedPipe(BypassFlowRate,PipeChwS0_1Temp,20,diameter,parameter_pipe);

%--------------pressure drop through components in primary system------------------------
PrimaryComponentDeltaP=PipeChwR0_1DeltaP+PipeChwR0_2DeltaP+max...
    ([ChillerSmallEvaOutlet.pressure_loss,ChillerMiddleEvaOutlet.pressure_loss,...
    ChillerLargeEvaOutlet.pressure_loss],[],2)+PipeChwS0_1DeltaP;


%********  Primary Pump Power(定流量)   **********
%*************************************************
%***************** SIZE PRIMARY PUMP**************
%*************************************************

ParameterPrimLargePump=EquipmentParameter.Pump;
ParameterPrimMiddlePump=EquipmentParameter.Pump;
ParameterPrimSmallPump=EquipmentParameter.Pump;

ParameterPrimLargePump(1).IsVFD=0;%FlowRate [m3/s]
ParameterPrimMiddlePump(1).IsVFD=0;
ParameterPrimSmallPump(1).IsVFD=0;

ParameterPrimLargePump(1).nominal(1,1)=EvaNomFlowLarge;%FlowRate [m3/s]
ParameterPrimMiddlePump(1).nominal(1,1)=EvaNomFlowMiddle;
ParameterPrimSmallPump(1).nominal(1,1)=EvaNomFlowSmall;

ParameterPrimLargePump(1).nominal(1,2)=max(PrimaryComponentDeltaP)./PressureFactor;% Head[m]
ParameterPrimMiddlePump(1).nominal(1,2)=ParameterPrimLargePump(1).nominal(1,2);
ParameterPrimSmallPump(1).nominal(1,2)=ParameterPrimLargePump(1).nominal(1,2);

ParameterPrimSmallPump(1).nominal(1,3:4)=[1450 0.85];
ParameterPrimMiddlePump(1).nominal(1,3:4)=[1450 0.85];
ParameterPrimLargePump(1).nominal(1,3:4)=[1450 0.85];

% 泵组流量分配原则---等比例分配
NomPrimPumpSmall=ParameterPrimSmallPump(1).nominal;   % [flowrate(m3/s) head(m)  speed(rpm) power(w)]
NomPrimPumpMiddle=ParameterPrimMiddlePump(1).nominal;
NomPrimPumpLarge=ParameterPrimLargePump(1).nominal;
PrimPumpSmallSpd=NomPrimPumpSmall(1,3)*ones(row,1);
PrimPumpMiddleSpd=NomPrimPumpMiddle(1,3)*ones(row,1);
PrimPumpLargeSpd=NomPrimPumpLarge(1,3)*ones(row,1);
PrimPumpSmallFlowRate=zeros(row,1);
PrimPumpMiddleFlowRate=zeros(row,1);
PrimPumpLargeFlowRate=zeros(row,1);

k=1;
while k<=row
    if (NumONSmall(k)==0)&&(NumONMiddle(k)==0)&&(NumONLarge(k)==0)
        PrimPumpSmallFlowRate(k)=0;
        PrimPumpMiddleFlowRate(k)=0;
        PrimPumpLargeFlowRate(k)=0;
    else
        PrimPumpSmallFlowRate(k)=PrimaryFlowRate(k).*NumONSmall(k).*...
            NomPrimPumpSmall(1,1)./(NumONSmall(k).*NomPrimPumpSmall(1,1)+...
            NumONMiddle(k)*NomPrimPumpMiddle(1,1)+NumONLarge(k).*NomPrimPumpLarge(1,1));
        PrimPumpMiddleFlowRate(k)=PrimaryFlowRate(k).*NumONMiddle(k).*...
            NomPrimPumpMiddle(1,1)./(NumONSmall(k).*NomPrimPumpSmall(1,1)+...
            NumONMiddle(k)*NomPrimPumpMiddle(1,1)+NumONLarge(k).*NomPrimPumpLarge(1,1));
        PrimPumpLargeFlowRate(k)=PrimaryFlowRate(k).*NumONLarge(k).*...
            NomPrimPumpLarge(1,1)./(NumONSmall(k).*NomPrimPumpSmall(1,1)+...
            NumONMiddle(k)*NomPrimPumpMiddle(1,1)+NumONLarge(k).*NomPrimPumpLarge(1,1));
    end
    k=k+1;
end


PrimaryPumpInlet.temp=PipeChwR0_2TempOut;
SizingParameterPumpSmall.DesignPressure=DesignPressure;
SizingParameterPumpSmall.NumONMax=NumONSmallMax;
[~, PrimaryPumpSmallPower,PrimaryPumpSmallHead,PrimaryPumpSmallEff,PrimaryPumpSmallEcoCost]=DesignPumpVFD...
    ( PrimaryPumpInlet,PrimPumpSmallSpd, PrimPumpSmallFlowRate,NumONSmall,Schedule,0,ParameterPrimSmallPump,SizingParameterPumpSmall);

SizingParameterPumpMiddle.DesignPressure=DesignPressure;
SizingParameterPumpMiddle.NumONMax=NumONMiddleMax;
[~, PrimaryPumpMiddlePower,PrimaryPumpMiddleHead,PrimaryPumpMiddleEff,PrimaryPumpMiddleEcoCost]=DesignPumpVFD...
    ( PrimaryPumpInlet,PrimPumpMiddleSpd, PrimPumpMiddleFlowRate,NumONMiddle,Schedule,0,ParameterPrimMiddlePump,SizingParameterPumpMiddle);

SizingParameterPumpLarge.DesignPressure=DesignPressure;
SizingParameterPumpLarge.NumONMax=NumONLargeMax;
[~, PrimaryPumpLargePower,PrimaryPumpLargeHead,PrimaryPumpLargeEff,PrimaryPumpLargeEcoCost]=DesignPumpVFD...
    ( PrimaryPumpInlet,PrimPumpLargeSpd, PrimPumpLargeFlowRate,NumONLarge,Schedule,0,ParameterPrimLargePump,SizingParameterPumpLarge);

PrimaryPumpPower=PrimaryPumpLargePower+PrimaryPumpMiddlePower+PrimaryPumpSmallPower;

PrimaryPumpEcoCost.Small=PrimaryPumpSmallEcoCost;
PrimaryPumpEcoCost.Middle=PrimaryPumpMiddleEcoCost;
PrimaryPumpEcoCost.Large=PrimaryPumpLargeEcoCost;

PrimaryPumpHead=max([PrimaryPumpLargeHead,PrimaryPumpMiddleHead,PrimaryPumpSmallHead],[],2);

BypassDeltaP=abs(PrimaryPumpHead-PrimaryComponentDeltaP);

%***************** Pressure Drop in Secondary System ***************
PipeChwSDeltaP=cell(MinVerticalZoneNum,1);
AHUInletPipeDeltaP=cell(MinVerticalZoneNum,1);
LoopDeltaP=cell(MinVerticalZoneNum,1);
SecondaryPumpHead=cell(MinVerticalZoneNum,1);


i=1;
while i<=MinVerticalZoneNum
    % Pressure Drop through pipes
    % 供水干管
    PipeInletTemp=ChillerTempSetPoint+(i-1)*1;
    %-----------------pipe_2-1-----------------------
    %[PipeChwS0_2FlowRate,PipeChwS0_2Temp,PipeChwS0_2DeltaP]=DetailedPipe...
    %    (SecondaryFlowRateZone{i,1},PipeInletTemp,30,DiameterPipe,...
    %    ParameterV1SecondaryPipe);
    [PipeChwS0_2FlowRate,PipeChwS0_2Temp,PipeChwS0_2DeltaP]=SimplifiedPipeValve...
        (SecondaryFlowRateZone{i,1},PipeInletTemp,ParameterSecondaryPipe{i,1});
    
    %-----------------pipe_ChwS_2_2-----------------------
    [PipeChwS0_3FlowRate,PipeChwS0_3Temp,PipeChwS0_3DeltaP]=SimplifiedPipeValve...
        (SecondaryFlowRateAHU{i,1},PipeChwS0_2Temp,ParameterSecondaryPipe{i,1});
    % 回水干管
    %----------------pipe_ChwR_2_1'-----------------------
    [PipeChwR0_3FlowRate,PipeChwR0_3Temp,PipeChwR0_3DeltaP]=SimplifiedPipeValve...
        (SecondaryFlowRateZone{i,1},SecondaryReturnTempZone{i,1},ParameterSecondaryPipe{i,1});
    
    %----------------pipe_ChwR_2_2'----------------------
    [PipeChwR0_4FlowRate,PipeChwR0_4Temp,PipeChwR0_4DeltaP]=SimplifiedPipeValve...
        (SecondaryFlowRateAHU{i,1},SecondaryReturnTempAHU{i,1},ParameterSecondaryPipe{i,1});
    
    if i~=MinVerticalZoneNum
        %----------------Pipe_ChwS_2_3--------HX--------------------
        [PipeChwS0_4FlowRate,PipeChwS0_4Temp,PipeChwS0_4DeltaP]=SimplifiedPipeValve...
            (ColdSideOutlet{i,1}.flowrate,PipeChwS0_2Temp,ParameterSecondaryPipe{i,2});
        %----------------Pipe_ChwR_2_3'--------HX--------------------
        [PipeChwR0_5FlowRate,PipeChwR0_5Temp,PipeChwR0_5DeltaP]=SimplifiedPipeValve...
            (ColdSideOutlet{i,1}.flowrate,ColdSideOutlet{i,1}.temp,ParameterSecondaryPipe{i,2});
    else
        PipeChwS0_4DeltaP=zeros(row,1);
        PipeChwR0_5DeltaP=zeros(row,1);
    end
    % 供水立管
    % Initialization
    LocalAHUFlowRate=zeros(row,1);
    
    PipeChwSInletTemp=PipeChwS0_3Temp;
    
    k=1;
    while k<=ZoneFloorNum(i)  %1-n层立管
        if k==1
            PipeChwSDeltaP{i,1}{k,1}=zeros(row,1);
        else
            LocalAHUFlowRate=LocalAHUFlowRate+WaterFlowOutletCC{i,1}{k,1};
            
            % 供水立管压降
            [PipeChwSFlowRate,PipeChwSOutletTemp,PipeDeltaP]=SimplifiedPipeValve...
                (SecondaryFlowRateAHU{i,1}-LocalAHUFlowRate,PipeChwSInletTemp,...
                ParameterSecondaryPipe{i,1});
            
            % 新的管道进水温度
            PipeChwSInletTemp=PipeChwSOutletTemp;
            % 存储经过立管产生的压降；
            PipeChwSDeltaP{i,1}{k,1}=PipeDeltaP;
        end
        k=k+1;
    end
    % 水系统为异程式，假设冷冻水回水与冷冻水供水是对称的
    % 立管回水压降等于供水压降；
    PipeChwRDeltaP=PipeChwSDeltaP;
    
    %%% AHU 进出口水平管压降
    
    k=1;
    while k<=ZoneFloorNum(i)
        
        %低区AHU进口冷水管道压降
        [V1PipeChwSFlowRate,V1PipeChwSOutletTemp,V1PipeDeltaP]=SimplifiedPipeValve...
            (WaterFlowOutletCC{i,1}{k,1},PipeChwS0_3Temp,ParameterSecondaryPipe{i,1});
        
        AHUInletPipeDeltaP{i,1}{k,1}=V1PipeDeltaP;
        
        k=k+1;
    end
    % 水系统为异程式，假设冷冻水回水与冷冻水供水是对称的
    % AHU冷水回水管道压降等于供水压降；
    AHUOutletPipeDeltaP=AHUInletPipeDeltaP;
    
    %**********************
    %****  二次水泵压头 ****
    %**********************
    
    k=1;
    while k<=ZoneFloorNum(i)
        % 供水立管+AHU进水水平管+AHU+AHU出水水平管+回水立管
        LoopDeltaP{i,1}(:,k)=PipeChwSDeltaP{i,1}{k,1}+  AHUInletPipeDeltaP{i,1}{k,1}+ ...
            WaterDeltaPOutletCC{i,1}{k,1}+AHUOutletPipeDeltaP{i,1}{k,1}+PipeChwRDeltaP{i,1}{k,1};
        
        k=k+1;
    end
    
    
    if i==1
        
        if MinVerticalZoneNum==1
            %@@@@@@ 1区二次水AHU环路最不利环路压降
            SecondaryPumpHead{i,1}=abs(PipeChwS0_2DeltaP+PipeChwS0_3DeltaP+max...
                (LoopDeltaP{i,1},[],2)+PipeChwR0_4DeltaP+PipeChwR0_3DeltaP-BypassDeltaP);
            
            %@@@@@@ 1区二次水板换环路压降；
            SecondaryPumpHead{i,2}=zeros(row,1);
        else
            %@@@@@@ 1区二次水AHU环路最不利环路压降
            SecondaryPumpHead{i,1}=abs(PipeChwS0_2DeltaP+PipeChwS0_3DeltaP+max...
                (LoopDeltaP{i,1},[],2)+PipeChwR0_4DeltaP+PipeChwR0_3DeltaP-BypassDeltaP);
            
            %@@@@@@ 1区二次水板换环路压降；
            SecondaryPumpHead{i,2}=abs(PipeChwS0_2DeltaP+PipeChwS0_4DeltaP+...
                ColdSideOutlet{i,1}.pressure_loss+PipeChwR0_5DeltaP-BypassDeltaP);
        end
        
    elseif i<MinVerticalZoneNum
        %@@@@@@ 2~N-1区二次水AHU环路最不利环路压降
        SecondaryPumpHead{i,1}=PipeChwS0_2DeltaP+PipeChwS0_3DeltaP+max...
            (LoopDeltaP{i,1},[],2)+PipeChwR0_4DeltaP+PipeChwR0_3DeltaP + ...
            HotSideOutlet{i-1,1}.pressure_loss;
        
        %@@@@@@ 2~N-1区二次水板换环路压降
        SecondaryPumpHead{i,2}=abs(PipeChwS0_2DeltaP+PipeChwS0_4DeltaP+...
            ColdSideOutlet{i,1}.pressure_loss+PipeChwR0_5DeltaP+...
            HotSideOutlet{i-1,1}.pressure_loss);
        
    elseif i==MinVerticalZoneNum
        %@@@@@@ N区二次水AHU环路最不利环路压降
        SecondaryPumpHead{i,1}=PipeChwS0_2DeltaP+PipeChwS0_3DeltaP+max...
            (LoopDeltaP{i,1},[],2)+PipeChwR0_4DeltaP+PipeChwR0_3DeltaP + ...
            HotSideOutlet{i-1,1}.pressure_loss;
        
        %@@@@@@ N区二次水板换环路压降
        SecondaryPumpHead{i,2}=zeros(row,1);
    end
    i=i+1;
end



%%                  &&&
%               &&&&&&&&
%             &&&& 2.7 &&&
%               &&&&&&&&
%                  &&&
%****Calculate the power of primary and secondary pumps
SecondaryPumpOutlet=cell(MinVerticalZoneNum,2);
SecondaryPumpSpd=cell(MinVerticalZoneNum,2);
SecondaryPumpPower=cell(MinVerticalZoneNum,2);
SecondaryPumpEff=cell(MinVerticalZoneNum,2);
SecondaryPumpHeadProv=cell(MinVerticalZoneNum,2);
SecondaryPumpEcoCost=cell(MinVerticalZoneNum,2);
%*********************  Secondary Pump Power************

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%*************Size Secondary Pump ******************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


SecondaryPumpPowerAll=zeros(row,1);
ParameterSeconPump=cell(MinVerticalZoneNum,2);
SecondaryPumpEcoCostAll=0;

i=1;
while i<=MinVerticalZoneNum
    j=1;
    
    while j<=2
     
        if (i==MinVerticalZoneNum)&&(j==2) % make sure that the fluence of design calculation in design pumps
            ParameterSeconPump{i,j}=EquipmentParameter.Pump;
            ParameterSeconPump{i,j}(1).nominal=ParameterSeconPump{i,1}(1).nominal;
            ParameterSeconPump{i,j}(1).IsVFD=1;
            
            SizingParameterSeconPump.DesignPressure=DesignPressure;
            SizingParameterSeconPump.NumONMax=0;
        else
            ParameterSeconPump{i,j}=EquipmentParameter.Pump;
            ParameterSeconPump{i,j}(1).IsVFD=1;
            
            SortedSecondaryPumpFlowRate=sort(SecondaryPumpFlowRate{i,j},'descend');
            if SortedSecondaryPumpFlowRate(21)<=0.1
                DesignFlowRate=SortedSecondaryPumpFlowRate(21);
                NumONSeconPumpMax=1;
            else
                NumONSeconPumpMax=round(SortedSecondaryPumpFlowRate(21)/0.1);
                NumONSeconPumpMax=min(NumONSeconPumpMax,4);
                    
                DesignFlowRate=SortedSecondaryPumpFlowRate(21)./NumONSeconPumpMax;
            end
            
            SortedSecondaryPumpHead=sort(SecondaryPumpHead{i,j},'descend');
            ParameterSeconPump{i,j}(1).nominal(1,1)=DesignFlowRate;
            ParameterSeconPump{i,j}(1).nominal(1,2)=SortedSecondaryPumpHead(21)./PressureFactor;
            ParameterSeconPump{i,j}(1).nominal(1,3:4)=[1450 0.85];
            
            SizingParameterSeconPump.DesignPressure=DesignPressure;
            SizingParameterSeconPump.NumONMax=NumONSeconPumpMax;
        end
        
        
        
        % 二次泵开启策略
        
        NomSeconPumpFlow=ParameterSeconPump{i,j}(1).nominal(1,1);
        
        NumONSeconPump=QBasedSequence(SecondaryPumpFlowRate{i,j},NomSeconPumpFlow,NumONSeconPumpMax);
       
%% ============================= DesignPump ========================    
        Schedule=logical(SecondaryPumpFlowRate{i,j});
        SecondaryPumpInlet.temp=PipeChwS0_2Temp;
        [SecondaryPumpOutletLocal,SecondaryPumpSpdLocal,SecondaryPumpPowerLocal,...
            SecondaryPumpEffLocal,SecondaryPumpHeadProvLocal,SecondaryPumpEcoCostLocal]=...
            DesignPumpVFDForSpd(SecondaryPumpInlet,SecondaryPumpHead{i,j}, ...
            SecondaryPumpFlowRate{i,j},NumONSeconPump,Schedule,0,ParameterSeconPump{i,j},SizingParameterSeconPump);
        
        SecondaryPumpOutlet{i,j}=SecondaryPumpOutletLocal;
        SecondaryPumpSpd{i,j}=SecondaryPumpSpdLocal;
        SecondaryPumpPower{i,j}=SecondaryPumpPowerLocal;
        SecondaryPumpEff{i,j}=SecondaryPumpEffLocal;
        SecondaryPumpHeadProv{i,j}=SecondaryPumpHeadProvLocal;
        SecondaryPumpEcoCost{i,j}=SecondaryPumpEcoCostLocal;
        
        SecondaryPumpPowerAll=SecondaryPumpPowerAll+SecondaryPumpPowerLocal;
        SecondaryPumpEcoCostAll=SecondaryPumpEcoCostAll+SecondaryPumpEcoCostLocal.CapCost;
       
        j=j+1;
        
    end
    
    i=i+1;
end


%%                  &&&
%               &&&&&&&&
%             &&&& 2.8 &&&
%               &&&&&&&&
%                  &&&
%** Calculate the penalty parameter C, for dissatisfing the design pressure.
%** Several pressumptions:
%    (1) expansion chamber is installed near the inlet of pumps, and make
%    sure a postive pressure at the highest point in the system;
%    (2) expansion chamber is as high as the vertical zone with multi-floors.
%

CSecondary=zeros(MinVerticalZoneNum,2);
%************** primary pump ***********
ConstantPressurePrimary=PressureFactor*FloorHeight*ZoneFloorNum(1)+BorametricPressure;

CPrimary=length(find((PrimaryPumpHead+ConstantPressurePrimary)>1.2*DesignPressure));

%*************zone secondary pump********
i=1;
while i<=MinVerticalZoneNum
    ConstantPressure=PressureFactor*FloorHeight*ZoneFloorNum(i)+BorametricPressure;
    
    j=1;
    while j<=2
        if i==1
            
            WorkPressure=ConstantPressure-BypassDeltaP+SecondaryPumpHeadProv{i,j};
            CSecondary(i,j)=length(find(WorkPressure>1.10*DesignPressure));
        else
            
            WorkPressure=ConstantPressure+SecondaryPumpHeadProv{i,j};
            CSecondary(i,j)=length(find(WorkPressure>1.10*DesignPressure));
        end
        j=j+1;
    end
    i=i+1;
end

%************************* Penalty parameter C in final form************
PenaltyC=max(CPrimary,max(max(CSecondary)));

%% Step 3. UPDATE THE OUTPUT
% Output of Primary Pump
PrimaryPumpOutput.Power=[PrimaryPumpLargePower PrimaryPumpMiddlePower PrimaryPumpSmallPower];
PrimaryPumpOutput.PressureDifference=[PrimaryPumpSmallHead PrimaryPumpMiddleHead PrimaryPumpLargeHead];
PrimaryPumpOutput.Efficiency=[PrimaryPumpSmallEff PrimaryPumpMiddleEff PrimaryPumpLargeEff];
PrimaryPumpOutput.PowerAll=PrimaryPumpPower;

% Output of Secondary Pump

SecondaryPumpOutput.PowerAll=SecondaryPumpPowerAll;
SecondaryPumpOutput.Effectiveness=SecondaryPumpEff;
SecondaryPumpOutput.Speed=SecondaryPumpSpd ;
SecondaryPumpOutput.PowerIndividual=SecondaryPumpPower;

% Output of Chiller
ChillerOutput(1).Evaporator=ChillerSmallEvaOutlet;
ChillerOutput(2).Evaporator=ChillerMiddleEvaOutlet;
ChillerOutput(3).Evaporator=ChillerLargeEvaOutlet;
ChillerOutput(1).Condenser=ChillerSmallConOutlet;
ChillerOutput(2).Condenser=ChillerMiddleConOutlet;
ChillerOutput(3).Condenser=ChillerLargeConOutlet;
ChillerOutput(1).HeatFlow=ChillerSmallHeatEva;
ChillerOutput(2).HeatFlow=ChillerMiddleHeatEva;
ChillerOutput(3).HeatFlow=ChillerLargeHeatEva;
ChillerOutput(1).Power=ChillerSmallPower;
ChillerOutput(2).Power=ChillerMiddlePower;
ChillerOutput(3).Power=ChillerLargePower;
ChillerOutput(1).COP=ChillerSmallCOP;
ChillerOutput(2).COP=ChillerMiddleCOP;
ChillerOutput(3).COP=ChillerLargeCOP;
ChillerOutput(1).PLR=ChillerSmallPLR;
ChillerOutput(2).PLR=ChillerMiddlePLR;
ChillerOutput(3).PLR=ChillerLargePLR;
ChillerOutput(1).NumON=NumONSmall;
ChillerOutput(2).NumON=NumONMiddle;
ChillerOutput(3).NumON=NumONLarge;

% Output of the Economic Model
EcoCostChilledWater.AHU=EconomicCostAirLoop;
EcoCostChilledWater.PrimaryPump=PrimaryPumpEcoCost;
EcoCostChilledWater.SecondaryPump=SecondaryPumpEcoCost;
EcoCostChilledWater.Chiller=ChillerEcoCost;
EcoCostChilledWater.HE=HeatExEcoCost;

AHUEcoCostAll=0;

for i=1:MinVerticalZoneNum
    row=size(EconomicCostAirLoop{i,1},1);
    for j=1:row
    AHUEcoCostAll=AHUEcoCostAll+EconomicCostAirLoop{i,1}{j,1}.CapCost;
    end
end

EcoCostChilledWater.All(:,1)=[ChillerEcoCost.Small.CapCost;ChillerEcoCost.Middle.CapCost;ChillerEcoCost.Large.CapCost];
EcoCostChilledWater.All(1,2)=AHUEcoCostAll;
EcoCostChilledWater.All(:,3)=[PrimaryPumpEcoCost.Small.CapCost;PrimaryPumpEcoCost.Middle.CapCost;PrimaryPumpEcoCost.Large.CapCost];
EcoCostChilledWater.All(1,5)=HeatExEcoCostAll;
EcoCostChilledWater.All(1,4)=SecondaryPumpEcoCostAll;

end