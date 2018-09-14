function [ElectricityAll,GBCFPower,GBCFPowerPump,EcoCost,CapCostAll,C]=GUIHVACOptimizationCode(x)


load input.mat
input=OptInput;
GStartDate = input.Time.StartDate;

GEndDate = input.Time.EndDate;

GDesignRH = input.Design.IndoorRH;

GDesignTdry = input.Design.IndoorTDry;

GFloor_equip = str2num(char(regexp(input.Floor_equip,',','split')))';


GFloor_high = input.Floor_high;

GFloor_num = input.Floor_num;

GCity = input.City;

GTypicalFloor1=[];
GTypicalFloor2=[];
GTypicalFloor3=[];
GTypicalFloor4=[];

if input.TypicalFloorNum>=1    
    GTypicalFloor1.index = cell2mat(input.TypicalFloor1_index);
    GTypicalFloor1.loadfile = input.TypicalFloor1_loadfile;
end


if input.TypicalFloorNum>=2
    GTypicalFloor2.index = cell2mat(input.TypicalFloor2_index);
    GTypicalFloor2.loadfile = input.TypicalFloor2_loadfile;
end

if input.TypicalFloorNum>=3
    GTypicalFloor3.index = cell2mat(input.TypicalFloor3_index);
    GTypicalFloor3.loadfile = input.TypicalFloor3_loadfile;
end

if input.TypicalFloorNum>=4
    GTypicalFloor4.index = cell2mat(input.TypicalFloor4_index);
    GTypicalFloor4.loadfile = input.TypicalFloor4_loadfile;
end

StartDateNum=datenum(GStartDate);
EndDateNum=datenum(GEndDate);
BaseTimeNum=datenum([GStartDate(1,1),01,01]);

GTimeStep=24*(EndDateNum-StartDateNum);

row=GTimeStep;

ChillerTempSetPoint=x(1);
CTTempSetPoint=x(2);
AHUCCTempSetPoint=x(3);

MinVerticalZoneNum=x(4);
EnergyStationNum=x(5);
TopologyRange=x(6);

if x(7)==1
    %DesignPressureIndex=1
    DesignPressure=1.0*1e6; % Pa
elseif x(7)==2
    DesignPressure=1.6*1e6;
elseif x(7)==3
    DesignPressure=2.0*1e6;
elseif x(7)==4
    DesignPressure=2.5*1e6;
else
    DesignPressure=3.0*1e6;
end

%% HVAC LOAD

% Weather Data

path=pwd;
str=[path,'\','Simulation Source Code','\','Weather','\',GCity,'.xlsx'];
Weather=xlsread (str);
    if size(Weather,1)~=8760
        error ('Please give 8760-hour weather data in Weather file!');
    end    
AirOA.temp=Weather(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),1);
AirOA.RH=Weather(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),3);
[ AirOA] = PsychInfo( AirOA );


WaterTempDifference.CC=7.75;
WaterTempDifference.HC=6.1;
WaterTempDifference.CW=5.5;  % Design Condenser water system temperature difference

% OAFraction=0.3*ones(row,1);
OAFraction=0.3;
% Schedule

DesignTemp = GDesignTdry;
DesignRH = GDesignRH;

% SetPoint
BoilerTempSetPoint=82.2; % supply water temperature for heating

T_supply=AHUCCTempSetPoint.*ones(row,1);    % AHUCCTempSetPoint=14*ones(row,1); % 夏季冷盘管出风温度！

% Floor Data
% R1
if isfield(GTypicalFloor1,'index')
    
    R1_1(:,1)=GTypicalFloor1.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),1);
    R1_1(:,2)=GTypicalFloor1.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),2);
    R1_1(:,3)=T_supply;
    R1_1(:,4)=DesignTemp;
    R1_1(:,5)=DesignRH;
    
    R1_2(:,1)=GTypicalFloor1.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),3);
    R1_2(:,2)=GTypicalFloor1.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),4);
    R1_2(:,3)=T_supply;
    R1_2(:,4)=DesignTemp;
    R1_2(:,5)=DesignRH;
    
    R1_3(:,1)=GTypicalFloor1.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),5);
    R1_3(:,2)=GTypicalFloor1.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),6);
    R1_3(:,3)=T_supply;
    R1_3(:,4)=DesignTemp;
    R1_3(:,5)=DesignRH;
    
    R1_4(:,1)=GTypicalFloor1.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),7);
    R1_4(:,2)=GTypicalFloor1.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),8);
    R1_4(:,3)=T_supply;
    R1_4(:,4)=DesignTemp;
    R1_4(:,5)=DesignRH;
    
    R1_5(:,1)=GTypicalFloor1.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),9);
    R1_5(:,2)=GTypicalFloor1.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),10);
    R1_5(:,3)=zeros(row,1);
    R1_5(:,4)=zeros(row,1);
    R1_5(:,5)=zeros(row,1);
    
    FloorR1={R1_1 R1_2 R1_3 R1_4 R1_5};
else
    FloorR1=[];
end
if isfield(GTypicalFloor2,'index')
    
    R2_1(:,1)=GTypicalFloor2.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),1);
    R2_1(:,2)=GTypicalFloor2.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),2);
    R2_1(:,3)=T_supply;
    R2_1(:,4)=DesignTemp;
    R2_1(:,5)=DesignRH;
    
    R2_2(:,1)=GTypicalFloor2.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),3);
    R2_2(:,2)=GTypicalFloor2.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),4);
    R2_2(:,3)=T_supply;
    R2_2(:,4)=DesignTemp;
    R2_2(:,5)=DesignRH;
    
    R2_3(:,1)=GTypicalFloor2.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),5);
    R2_3(:,2)=GTypicalFloor2.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),6);
    R2_3(:,3)=T_supply;
    R2_3(:,4)=DesignTemp;
    R2_3(:,5)=DesignRH;
    
    R2_4(:,1)=GTypicalFloor2.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),7);
    R2_4(:,2)=GTypicalFloor2.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),8);
    R2_4(:,3)=T_supply;
    R2_4(:,4)=DesignTemp;
    R2_4(:,5)=DesignRH;
    
    R2_5(:,1)=GTypicalFloor2.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),9);
    R2_5(:,2)=GTypicalFloor2.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),10);
    R2_5(:,3)=zeros(row,1);
    R2_5(:,4)=zeros(row,1);
    R2_5(:,5)=zeros(row,1);
    
    FloorR2={R2_1 R2_2 R2_3 R2_4 R2_5};
else
    FloorR2=[];
end

if isfield(GTypicalFloor3,'index')
    
    R3_1(:,1)=GTypicalFloor3.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),1);
    R3_1(:,2)=GTypicalFloor3.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),2);
    R3_1(:,3)=T_supply;
    R3_1(:,4)=DesignTemp;
    R3_1(:,5)=DesignRH;
    
    R3_2(:,1)=GTypicalFloor3.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),3);
    R3_2(:,2)=GTypicalFloor3.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),4);
    R3_2(:,3)=T_supply;
    R3_2(:,4)=DesignTemp;
    R3_2(:,5)=DesignRH;
    
    R3_3(:,1)=GTypicalFloor3.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),5);
    R3_3(:,2)=GTypicalFloor3.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),6);
    R3_3(:,3)=T_supply;
    R3_3(:,4)=DesignTemp;
    R3_3(:,5)=DesignRH;
    
    R3_4(:,1)=GTypicalFloor3.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),7);
    R3_4(:,2)=GTypicalFloor3.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),8);
    R3_4(:,3)=T_supply;
    R3_4(:,4)=DesignTemp;
    R3_4(:,5)=DesignRH;
    
    R3_5(:,1)=GTypicalFloor3.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),9);
    R3_5(:,2)=GTypicalFloor3.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),10);
    R3_5(:,3)=zeros(row,1);
    R3_5(:,4)=zeros(row,1);
    R3_5(:,5)=zeros(row,1);
    
    FloorR3={R3_1 R3_2 R3_3 R3_4 R3_5};
else
    FloorR3=[];
end

if isfield(GTypicalFloor4,'index')
    
    R4_1(:,1)=GTypicalFloor4.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),1);
    R4_1(:,2)=GTypicalFloor4.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),2);
    R4_1(:,3)=T_supply;
    R4_1(:,4)=DesignTemp;
    R4_1(:,5)=DesignRH;
    
    R4_2(:,1)=GTypicalFloor4.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),3);
    R4_2(:,2)=GTypicalFloor4.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),4);
    R4_2(:,3)=T_supply;
    R4_2(:,4)=DesignTemp;
    R4_2(:,5)=DesignRH;
    
    R4_3(:,1)=GTypicalFloor4.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),5);
    R4_3(:,2)=GTypicalFloor4.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),6);
    R4_3(:,3)=T_supply;
    R4_3(:,4)=DesignTemp;
    R4_3(:,5)=DesignRH;
    
    R4_4(:,1)=GTypicalFloor4.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),7);
    R4_4(:,2)=GTypicalFloor4.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),8);
    R4_4(:,3)=T_supply;
    R4_4(:,4)=DesignTemp;
    R4_4(:,5)=DesignRH;
    
    R4_5(:,1)=GTypicalFloor4.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),9);
    R4_5(:,2)=GTypicalFloor4.loadfile(24*(StartDateNum-BaseTimeNum)+1:24*(EndDateNum-BaseTimeNum),10);
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

% total floor number
BuildingFloorNum = GFloor_num;
% Equipment floor number;
FloorNumEquip = GFloor_equip;
% building floor height
FloorHeight = GFloor_high;

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

%***********************************************
%********   Floor data   ********************
%**********************************************

for fl=1:BuildingFloorNum
    if (fl<= GTypicalFloor1.index(1,2)&&fl>= GTypicalFloor1.index(1,1))                % Standard Floor Office
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
    elseif (fl<= GTypicalFloor2.index(1,2)&&fl>= GTypicalFloor2.index(1,1))  
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
    elseif (fl<= GTypicalFloor3.index(1,2)&&fl>= GTypicalFloor3.index(1,1))  
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
    elseif (fl<= GTypicalFloor4.index(1,2)&&fl>= GTypicalFloor4.index(1,1)) 
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

    Pump(1).coefficient=[-0.5121 0.3998 -0.1779 1.2704];     
    Pump(2).coefficient=[-0.6061 0.0388 1.5378 0.0102];
    Pump(3).coefficient=[0.96950 -9.4625];
    Pump(4).coefficient=[0.50870 1.28300 -1.42000 0.58340];
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
HeatEx.Parameter.UAParameter=[0.5 0.5];%[0.2675 0.2675]; % m,n
HeatEx.Parameter.DesignTempDiff=WaterTempDifference.CC;

% PARAMETERS FOR PIPES
% Primary pipe
ParameterPrimaryPipe.k=0.4;
ParameterPrimaryPipe.MassFlowRateCritic=0.03;




%% Condenser Loop

% Parameter for each cell in cooling towers
    ParameterCT.NomHeatFlow=4.3272e5; %W
    ParameterCT.NomFlow=[50000/3600 75/3600];
    ParameterCT.FreeConv=[0.1 0.1*2.1517e4];
    ParameterCT.FracWaterFlow=[0.4 1.2];
    ParameterCT.FanON=[60000 2.1517e4];
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

EquipmentParameter.FanDiameter=FanDiameterCell;
EquipmentParameter.ParameterAHU=ParameterAHUCell;
EquipmentParameter.ParameterVFDFan=ParameterVFDFanCell;


EquipmentParameter.HeatExchanger=HeatEx;
EquipmentParameter.Pump=Pump;
EquipmentParameter.PrimaryPipe=ParameterPrimaryPipe;
EquipmentParameter.CondensePipe=ParameterCondensePipe;
EquipmentParameter.CT=CT;

ModelSelection.AHU='lmtdahu';%'standardahu';

[ElectricityAll,GBCFPower,GBCFPowerPump,EcoCost,CapCostAll,C]=BuildingHVACSimulationOpt(BuildingInfo,AirOA,...
    DesignInfo,OperationInfo,OperationSchedule,EquipmentParameter,ModelSelection);