function [ElectricityAll,GBCFPower,GBCFPowerPump,EcoCost,CapCostAll,C]=GUIHVACSimulation(InputFileName)
global TimeStep
% read input from GUI inputfiles
InputInfo=ReadInputFile(InputFileName);

% Data from GUI
StartDateNum=datenum(InputInfo.SimulationControl.StartDate);
EndDateNum=datenum(InputInfo.SimulationControl.EndDate);

TimeStep=24*(EndDateNum-StartDateNum);
ChillerTempSetPoint=InputInfo.HVACSetting.SupplyChilledWaterTemp;
CTTempSetPoint=InputInfo.HVACSetting.ReturnCondWaterTemp;
AHUCCTempSetPoint=InputInfo.HVACSetting.AHUOutletTempSetPoint;

MinVerticalZoneNum=InputInfo.BuildingInfo.ZoneNum;
EnergyStationNum=InputInfo.BuildingInfo.EnergyStation;
TopologyRange=InputInfo.BuildingInfo.TopologyRange;

DesignPressure=1e6*InputInfo.HVACSetting.DesignPressureIndex;%Pa


%% HVAC LOAD
BaseTimeNum=datenum([InputInfo.SimulationControl.StartDate(1,1),01,01]);

% Weather Data
CityName=InputInfo.HVACSetting.City;
path=pwd;
str=[path,'\','Simulation Source Code','\','Weather','\',CityName,'.','xlsx'];
Weather=xlsread (str);
    if size(Weather,1)~=8760
        error ('Please give 8760-hour weather data in Weather file!');
    end    
AirOA.temp=Weather(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),1);
AirOA.RH=Weather(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),3);
[ AirOA] = PsychInfo( AirOA );
row=TimeStep;

% Design Criteria
DesignCriteria=InputInfo.HVACSetting.DesignCri;
%DesignCriteria.RH=0.5*ones(row,1);

WaterTempDifference.CC=InputInfo.HVACSetting.ChilledWaterTempDiff;
WaterTempDifference.HC=InputInfo.HVACSetting.HeatingWaterTempDiff;
WaterTempDifference.CW=InputInfo.HVACSetting.CondWaterTempDiff;  % Design Condenser water system temperature difference

% OAFraction=0.3*ones(row,1);
OAFraction=InputInfo.HVACSetting.OARatio;
% Schedule

DesignTemp=DesignCriteria.temp;
DesignRH=DesignCriteria.RH;

% SetPoint
BoilerTempSetPoint=InputInfo.HVACSetting.SupplyHeatWaterTemp; % supply water temperature for heating

T_supply=AHUCCTempSetPoint.*ones(row,1);    % AHUCCTempSetPoint=14*ones(row,1); % 夏季冷盘管出风温度！

% Floor Data
% R1
if isfield(InputInfo.BuildingInfo.Load.R1,'LoadData')
    
    R1_1(:,1)=InputInfo.BuildingInfo.Load.R1.LoadData.Zone1(:,1);
    R1_1(:,2)=InputInfo.BuildingInfo.Load.R1.LoadData.Zone1(:,2);
    R1_1(:,3)=T_supply;
    R1_1(:,4)=DesignTemp;
    R1_1(:,5)=DesignRH;
    
    R1_2(:,1)=InputInfo.BuildingInfo.Load.R1.LoadData.Zone2(:,1);
    R1_2(:,2)=InputInfo.BuildingInfo.Load.R1.LoadData.Zone2(:,2);
    R1_2(:,3)=T_supply;
    R1_2(:,4)=DesignTemp;
    R1_2(:,5)=DesignRH;
    
    R1_3(:,1)=InputInfo.BuildingInfo.Load.R1.LoadData.Zone3(:,1);
    R1_3(:,2)=InputInfo.BuildingInfo.Load.R1.LoadData.Zone3(:,2);
    R1_3(:,3)=T_supply;
    R1_3(:,4)=DesignTemp;
    R1_3(:,5)=DesignRH;
    
    R1_4(:,1)=InputInfo.BuildingInfo.Load.R1.LoadData.Zone4(:,1);
    R1_4(:,2)=InputInfo.BuildingInfo.Load.R1.LoadData.Zone4(:,2);
    R1_4(:,3)=T_supply;
    R1_4(:,4)=DesignTemp;
    R1_4(:,5)=DesignRH;
    
    R1_5(:,1)=InputInfo.BuildingInfo.Load.R1.LoadData.Zone5(:,1);
    R1_5(:,2)=InputInfo.BuildingInfo.Load.R1.LoadData.Zone5(:,2);
    R1_5(:,3)=zeros(row,1);
    R1_5(:,4)=zeros(row,1);
    R1_5(:,5)=zeros(row,1);
    
    FloorR1={R1_1 R1_2 R1_3 R1_4 R1_5};
else
    FloorR1=[];
end
if isfield(InputInfo.BuildingInfo.Load.R2,'LoadData')
    
    R2_1(:,1)=InputInfo.BuildingInfo.Load.R2.LoadData.Zone1(:,1);
    R2_1(:,2)=InputInfo.BuildingInfo.Load.R2.LoadData.Zone1(:,2);
    R2_1(:,3)=T_supply;
    R2_1(:,4)=DesignTemp;
    R2_1(:,5)=DesignRH;
    
    R2_2(:,1)=InputInfo.BuildingInfo.Load.R2.LoadData.Zone2(:,1);
    R2_2(:,2)=InputInfo.BuildingInfo.Load.R2.LoadData.Zone2(:,2);
    R2_2(:,3)=T_supply;
    R2_2(:,4)=DesignTemp;
    R2_2(:,5)=DesignRH;
    
    R2_3(:,1)=InputInfo.BuildingInfo.Load.R2.LoadData.Zone3(:,1);
    R2_3(:,2)=InputInfo.BuildingInfo.Load.R2.LoadData.Zone3(:,2);
    R2_3(:,3)=T_supply;
    R2_3(:,4)=DesignTemp;
    R2_3(:,5)=DesignRH;
    
    R2_4(:,1)=InputInfo.BuildingInfo.Load.R2.LoadData.Zone4(:,1);
    R2_4(:,2)=InputInfo.BuildingInfo.Load.R2.LoadData.Zone4(:,2);
    R2_4(:,3)=T_supply;
    R2_4(:,4)=DesignTemp;
    R2_4(:,5)=DesignRH;
    
    R2_5(:,1)=InputInfo.BuildingInfo.Load.R2.LoadData.Zone5(:,1);
    R2_5(:,2)=InputInfo.BuildingInfo.Load.R2.LoadData.Zone5(:,2);
    R2_5(:,3)=zeros(row,1);
    R2_5(:,4)=zeros(row,1);
    R2_5(:,5)=zeros(row,1);
    
    FloorR2={R2_1 R2_2 R2_3 R2_4 R2_5};
else
    FloorR2=[];
end

if isfield(InputInfo.BuildingInfo.Load.R3,'LoadData')
    
    R3_1(:,1)=InputInfo.BuildingInfo.Load.R3.LoadData.Zone1(:,1);
    R3_1(:,2)=InputInfo.BuildingInfo.Load.R3.LoadData.Zone1(:,2);
    R3_1(:,3)=T_supply;
    R3_1(:,4)=DesignTemp;
    R3_1(:,5)=DesignRH;
    
    R3_2(:,1)=InputInfo.BuildingInfo.Load.R3.LoadData.Zone2(:,1);
    R3_2(:,2)=InputInfo.BuildingInfo.Load.R3.LoadData.Zone2(:,2);
    R3_2(:,3)=T_supply;
    R3_2(:,4)=DesignTemp;
    R3_2(:,5)=DesignRH;
    
    R3_3(:,1)=InputInfo.BuildingInfo.Load.R3.LoadData.Zone3(:,1);
    R3_3(:,2)=InputInfo.BuildingInfo.Load.R3.LoadData.Zone3(:,2);
    R3_3(:,3)=T_supply;
    R3_3(:,4)=DesignTemp;
    R3_3(:,5)=DesignRH;
    
    R3_4(:,1)=InputInfo.BuildingInfo.Load.R3.LoadData.Zone4(:,1);
    R3_4(:,2)=InputInfo.BuildingInfo.Load.R3.LoadData.Zone4(:,2);
    R3_4(:,3)=T_supply;
    R3_4(:,4)=DesignTemp;
    R3_4(:,5)=DesignRH;
    
    R3_5(:,1)=InputInfo.BuildingInfo.Load.R3.LoadData.Zone5(:,1);
    R3_5(:,2)=InputInfo.BuildingInfo.Load.R3.LoadData.Zone5(:,2);
    R3_5(:,3)=zeros(row,1);
    R3_5(:,4)=zeros(row,1);
    R3_5(:,5)=zeros(row,1);
    
    FloorR3={R3_1 R3_2 R3_3 R3_4 R3_5};
else
    FloorR3=[];
end

if isfield(InputInfo.BuildingInfo.Load.R4,'LoadData')
    
    R4_1(:,1)=InputInfo.BuildingInfo.Load.R4.LoadData.Zone1(:,1);
    R4_1(:,2)=InputInfo.BuildingInfo.Load.R4.LoadData.Zone1(:,2);
    R4_1(:,3)=T_supply;
    R4_1(:,4)=DesignTemp;
    R4_1(:,5)=DesignRH;
    
    R4_2(:,1)=InputInfo.BuildingInfo.Load.R4.LoadData.Zone2(:,1);
    R4_2(:,2)=InputInfo.BuildingInfo.Load.R4.LoadData.Zone2(:,2);
    R4_2(:,3)=T_supply;
    R4_2(:,4)=DesignTemp;
    R4_2(:,5)=DesignRH;
    
    R4_3(:,1)=InputInfo.BuildingInfo.Load.R4.LoadData.Zone3(:,1);
    R4_3(:,2)=InputInfo.BuildingInfo.Load.R4.LoadData.Zone3(:,2);
    R4_3(:,3)=T_supply;
    R4_3(:,4)=DesignTemp;
    R4_3(:,5)=DesignRH;
    
    R4_4(:,1)=InputInfo.BuildingInfo.Load.R4.LoadData.Zone4(:,1);
    R4_4(:,2)=InputInfo.BuildingInfo.Load.R4.LoadData.Zone4(:,2);
    R4_4(:,3)=T_supply;
    R4_4(:,4)=DesignTemp;
    R4_4(:,5)=DesignRH;
    
    R4_5(:,1)=InputInfo.BuildingInfo.Load.R4.LoadData.Zone5(:,1);
    R4_5(:,2)=InputInfo.BuildingInfo.Load.R4.LoadData.Zone5(:,2);
    R4_5(:,3)=zeros(row,1);
    R4_5(:,4)=zeros(row,1);
    R4_5(:,5)=zeros(row,1);
    
    FloorR4={R4_1 R4_2 R4_3 R4_4 R4_5};
else
    FloorR4=[];
end


Floor_Equip_1=zeros(size(R1_1));
Floor_Equip_2=Floor_Equip_1;
Floor_Equip_3=Floor_Equip_1;
Floor_Equip_4=Floor_Equip_1;
Floor_Equip_5=Floor_Equip_1;

Floor_Equip={Floor_Equip_1 Floor_Equip_2 Floor_Equip_3 Floor_Equip_4 Floor_Equip_5};

% Design Load in building


% total floor number
BuildingFloorNum=InputInfo.BuildingInfo.FloorNumber;
% Equipment floor number;
FloorNumEquip=InputInfo.BuildingInfo.EquipFloorNum;
% building floor height
FloorHeight=InputInfo.BuildingInfo.FloorHeight;

% Store Load and Design Crietia required for this system.
FloorData=cell(BuildingFloorNum,1);

%% AHU INFORMATION

%***********************************************
%********  AHU Parameters   ********************
%**********************************************

% representive floor 7
ParameterAHU(1).HeatExchType=2;% 0---Ideal flow;1---Counter flow;2----Cross flow
ParameterAHU(2).HeatExchType=2;
ParameterAHU(1).DesCoolingCoil.DesInletAirCC.temp=25.2;      % Dry bulb temperature;
ParameterAHU(1).DesCoolingCoil.DesInletAirCC.Twb=18.8;     % Wet bulb temperature;
ParameterAHU(1).DesCoolingCoil.DesInletAirCC.W=0.0110;      % Humidity ratio;[kg/kg(air)];
ParameterAHU(1).DesCoolingCoil.DesInletAirCC.flowrate=11.913;  % Volume flowrate; [m3/s]
ParameterAHU(2).DesCoolingCoil.DesInletWaterCC.temp=6;
ParameterAHU(2).DesCoolingCoil.DesInletWaterCC.flowrate=0.0112;
ParameterAHU(3).DesCoolingCoil.ParameterCC.A=27.3;
ParameterAHU(3).DesCoolingCoil.ParameterCC.B=353.6;
ParameterAHU(3).DesCoolingCoil.ParameterCC.m=0.58;
ParameterAHU(3).DesCoolingCoil.ParameterCC.n=0.075;
ParameterAHU(3).DesCoolingCoil.ParameterCC.p=1.02;
ParameterAHU(3).DesCoolingCoil.ParameterCC.AirResis=16;
ParameterAHU(3).DesCoolingCoil.ParameterCC.WaterResis=5;
ParameterAHU(4).DesCoolingCoil.DesOutletAirCC.temp=13.2;
ParameterAHU(4).DesCoolingCoil.DesOutletAirCC.Twb=12.8;
ParameterAHU(5).DesCoolingCoil.DesInformationCC.AirVelocity=2.5;      % air side velocity;
ParameterAHU(5).DesCoolingCoil.DesInformationCC.AirFlowrate=...
    ParameterAHU(1).DesCoolingCoil.DesInletAirCC.flowrate;     % Volume flowrate; [m3/s]
ParameterAHU(5).DesCoolingCoil.DesInformationCC.WaterVelocity=1.5;

ParameterAHU(1).DesHeatingCoil.DesInletAirHC.temp=15;
ParameterAHU(1).DesHeatingCoil.DesInletAirHC.Twb=12;
ParameterAHU(1).DesHeatingCoil.DesInletAirHC.W=0.012;
ParameterAHU(1).DesHeatingCoil.DesInletAirHC.flowrate=12;
ParameterAHU(2).DesHeatingCoil.DesInletWaterHC.temp=7;
ParameterAHU(2).DesHeatingCoil.DesInletWaterHC.flowrate=0.1;
ParameterAHU(3).DesHeatingCoil.ParameterHC.AirResis=5;
ParameterAHU(4).DesHeatingCoil.DesOutletAirHC.temp=13.2;
ParameterAHU(4).DesHeatingCoil.DesOutletAirHC.W=0.0128;

ParameterAHU(1).AnalysisMode='SimpleAnalysis';% SimpleAnalysis and DetailedAnalysis


% Design coil UA value


%***********************************************
%********  FAN Parameters   ********************
%**********************************************
% VFDFans in 3~7th  floor
ParameterVFDFan.ManuDataMaxEff=[1691 11.913 0.915];
ParameterVFDFan.FanMaxDimFlow =0.150616; %! Maximum dimensionless flow from maufacturer's table.
ParameterVFDFan.PulleyDiaRatio=1.08;     %! The ratio between pulley motor diameter and pulley fan diameter;
ParameterVFDFan.MaxAirMassFlowRate=100;  %! Maximum massflow rate;[kg/s]
ParameterVFDFan.MotInAirFrac=1;          %! Motor in Air Fraction, used in temperature rise model.
ParameterVFDFan.MotorRatedOutPwr=200000;  %! Motor rated power;[w]
ParameterVFDFan.SizeFactor=1.1;          %! Motor power size factor ;
ParameterVFDFan.RhoAir=1.29;             %! Air density;[kg/m3]
ParameterVFDFan.CurveIndex=[1 1 1 1 1 1 1 1 1 1 1]'; %! Curve index for calling fitted curve.
ParameterVFDFan.BeltType=3;              %! Medium loss belt is used by default;
ParameterVFDFan.MotorType=3;             %! Medium efficienct motor is used by default;

% Parameters are required for each AHU. each AHU may not be identical.
ParameterAHUCell=cell(BuildingFloorNum,1);
ParameterVFDFanCell=cell(BuildingFloorNum,1);
FanDiameterCell=cell(BuildingFloorNum,1);


%***********************************************
%********   Fan Diameter   ********************
%**********************************************
FanDia=1.2;

DesignLoadFloor=[];

for fl=1:BuildingFloorNum
    if fl<= InputInfo.BuildingInfo.Load.R1.FloorRange(1,2)                   % Standard Floor Office
        if sum(fl==FloorNumEquip)
            FloorData{fl,1}=Floor_Equip;
            FloorData{fl,2}=0;
            ParameterAHUCell{fl,1}=ParameterAHU;
            ParameterVFDFanCell{fl,1}=ParameterVFDFan;
            FanDiameterCell{fl,1}=FanDia;
        else
            FloorData{fl,1}=FloorR1;
            FloorData{fl,2}=1;
            ParameterAHUCell{fl,1}=ParameterAHU;
            ParameterVFDFanCell{fl,1}=ParameterVFDFan;
            FanDiameterCell{fl,1}=FanDia;
        end
    elseif (fl<=InputInfo.BuildingInfo.Load.R2.FloorRange(1,2))&&...
            (InputInfo.BuildingInfo.Load.R2.FloorRange(1,2)>=InputInfo.BuildingInfo.Load.R1.FloorRange(1,2))
        if sum(fl==FloorNumEquip)
            FloorData{fl,1}=Floor_Equip;
            FloorData{fl,2}=0;
            ParameterAHUCell{fl,1}=ParameterAHU;
            ParameterVFDFanCell{fl,1}=ParameterVFDFan;
            FanDiameterCell{fl,1}=FanDia;
        else
            FloorData{fl,1}=FloorR2;
            FloorData{fl,2}=2;
            ParameterAHUCell{fl,1}=ParameterAHU;
            ParameterVFDFanCell{fl,1}=ParameterVFDFan;
            FanDiameterCell{fl,1}=FanDia;
        end
    elseif (fl<=InputInfo.BuildingInfo.Load.R3.FloorRange(1,2))&&...
            (InputInfo.BuildingInfo.Load.R3.FloorRange(1,2)>=InputInfo.BuildingInfo.Load.R2.FloorRange(1,2))
        if sum(fl==FloorNumEquip)
            FloorData{fl,1}=Floor_Equip;
            FloorData{fl,2}=0;
            ParameterAHUCell{fl,1}=ParameterAHU;
            ParameterVFDFanCell{fl,1}=ParameterVFDFan;
            FanDiameterCell{fl,1}=FanDia;
        else
            FloorData{fl,1}=FloorR3;
            FloorData{fl,2}=3;
            ParameterAHUCell{fl,1}=ParameterAHU;
            ParameterVFDFanCell{fl,1}=ParameterVFDFan;
            FanDiameterCell{fl,1}=FanDia;
        end
    elseif (fl<=InputInfo.BuildingInfo.Load.R4.FloorRange(1,2))&&...
            (InputInfo.BuildingInfo.Load.R4.FloorRange(1,2)>=InputInfo.BuildingInfo.Load.R3.FloorRange(1,2))
        if sum(fl==FloorNumEquip)
            FloorData{fl,1}=Floor_Equip;
            FloorData{fl,2}=0;
            ParameterAHUCell{fl,1}=ParameterAHU;
            ParameterVFDFanCell{fl,1}=ParameterVFDFan;
            FanDiameterCell{fl,1}=FanDia;
        else
            FloorData{fl,1}=FloorR4;
            FloorData{fl,2}=4;
            ParameterAHUCell{fl,1}=ParameterAHU;
            ParameterVFDFanCell{fl,1}=ParameterVFDFan;
            FanDiameterCell{fl,1}=FanDia;
        end
    end
    SortedLoad=sort(sum(FloorData{fl,1}{1,1}(:,1:2),2)+sum(FloorData{fl,1}{1,2}(:,1:2),2)+sum(FloorData{fl,1}{1,3}(:,1:2),2)...
        +sum(FloorData{fl,1}{1,4}(:,1:2),2)+sum(FloorData{fl,1}{1,5}(:,1:2),2),'descend');
    DesignLoadFloor(fl,1)=SortedLoad(21,1);
end

%% Water Side Components
% Chiller Resistance

%  Pumps
Pump(1).coefficient=InputInfo.S1.PrimPump.Small.HeadSpdFlowCoeff;
Pump(2).coefficient=InputInfo.S1.PrimPump.Small.EffSpdFlowCoeff;
Pump(3).coefficient=InputInfo.S1.PrimPump.Small.MotorEffCoeff;
Pump(4).coefficient=InputInfo.S1.PrimPump.Small.VFDEffCoeff;
Pump(1).MotInWaterFrac=1;
Pump(1).SizeFactor=0.4;   % Minimum Speed ratio;
Pump(2).SizeFactor=1.2;   % Maximum speed ratio;

%  Heat Exchangers
DesColdSideInlet.temp=ChillerTempSetPoint;
DesHotSideInlet.temp=ChillerTempSetPoint+WaterTempDifference.CC+1;
HeatEx.DesColdSideInlet=DesColdSideInlet;
HeatEx.DesHotSideInlet=DesHotSideInlet;

HeatEx.Type=3;
HeatEx.Parameter.resistance=[4.208 4.208];
HeatEx.Parameter.UAParameter=InputInfo.S1.HX1.UAParameter;%[0.2675 0.2675]; % m,n
HeatEx.Parameter.DesignTempDiff=WaterTempDifference.CC;

% PARAMETERS FOR PIPES
% Primary pipe
ParameterPrimaryPipe.k=0.4;
ParameterPrimaryPipe.MassFlowRateCritic=0.03;



%% Condenser Loop

% Parameter for each cell in cooling towers
ParameterCT.NomHeatFlow=InputInfo.CT.CTCellNominalHeatFlow; %W
ParameterCT.NomFlow=[InputInfo.CT.CTCellNominalAirFlow InputInfo.CT.CTCellNominalWaterFlow];
ParameterCT.FreeConv=[0.1 0.1*2.1517e4];
ParameterCT.FracWaterFlow=[0.4 1.2];
ParameterCT.FanON=[InputInfo.CT.CTCellNominalPower 2.1517e4];
ParameterCT.Resis=1;

CT.Parameter=ParameterCT;

CTLocation=7; % the floor where Cooling towers are installed

% Parameters for condenser pump

% Condense Water Pipe
ParameterCondensePipe.k=4;
ParameterCondensePipe.MassFlowRateCritic=0.03;

%% Update

BuildingInfo.BuildingFloorNum=BuildingFloorNum;
BuildingInfo.MinVerticalZoneNum=MinVerticalZoneNum;
BuildingInfo.EnergyStationNum=EnergyStationNum;
BuildingInfo.TopologyRange=TopologyRange;
BuildingInfo.FloorHeight=FloorHeight;
BuildingInfo.CTLocation=CTLocation;
BuildingInfo.DesignLoadFloor=DesignLoadFloor;

DesignInfo.FloorData=FloorData;
DesignInfo.DesignPressure=DesignPressure;

OperationInfo.WaterTempDifference=WaterTempDifference;
OperationInfo.OAFraction=OAFraction;

OperationSchedule.AHUCCTempSetPoint=AHUCCTempSetPoint;
OperationSchedule.ChillerTempSetPoint=ChillerTempSetPoint;
OperationSchedule.BoilerTempSetPoint=BoilerTempSetPoint;
OperationSchedule.CTTempSetPoint=CTTempSetPoint;

EquipmentParameter.S1.Chiller=InputInfo.S1.Chiller;
EquipmentParameter.S2.Chiller=InputInfo.S2.Chiller;

EquipmentParameter.FanDiameter=FanDiameterCell;
EquipmentParameter.ParameterAHU=ParameterAHUCell;
EquipmentParameter.ParameterVFDFan=ParameterVFDFanCell;

EquipmentParameter.HeatExchanger=HeatEx;
EquipmentParameter.Pump=Pump;
EquipmentParameter.PrimaryPipe=ParameterPrimaryPipe;
EquipmentParameter.CondensePipe=ParameterCondensePipe;
EquipmentParameter.CT=CT;

ModelSelection.AHU='lmtdahu';%'standardahu';

[ElectricityAll,GBCFPower,GBCFPowerPump,EcoCost,CapCostAll,C]=BuildingHVACSimulation(BuildingInfo,AirOA,...
    DesignInfo,OperationInfo,OperationSchedule,EquipmentParameter,ModelSelection);