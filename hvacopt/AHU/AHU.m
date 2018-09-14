function [OutletAirAHU,OutletWaterCC,OutletWaterHC,PowerAHU,TotHeatTransferRate,EffectivenessFan,EconomicCost]=...
    AHU(InletAir,InletWaterCC,InletWaterHC,AirSetPointTemp,CoilUA,Schedule,FanDiameter,ParameterAHU,ParameterVFDFan,SizingParameter)
%% Describes the AHU with constant outside air fraction
%% Description
% ==============================input============================
% air_in;               a struct, describes outside air conditon, which contains
%                          air_in.temp:       air side inlet temperature;[¡æ]£»
%                          air_in.RH:         air side INLET relative humidity;[--]
%                          air_in.flowrate:   air side inlet pressure;[m3/s]
%
% water_in_CC:          a struct, describes inlet water condition in
%                       cooling coil:
%                           water_in_CC.temp:
%                           water_in_CC.pressure:
% water_in_HC:          a struct, describes inlet water condition in
%                       heating coil:
%                           water_in_HC.temp:
%                           water_in_HC.pressure:
% temp_SP:              a matrix, describes the outlet temperature set
%                                 point
% flowrate_mix:         a matrix, describes air flowrate blowing through the AHU, which can be
%                                 calculated from prychrometric process in a zone;[m3/s]
% frac_OA:              a matrix, describes the outside air fraction; [0~1];
% CoilUA:               a struct,describe the overall UA value of cooling coil and heating coil;
%                          CoilUA.CC: cooling coil overall UA ; [W/K]
%                          CoilUA.HC: heating coil overall UA;  [W/K]
% fan_N:                a matrix, describes the rotate speed of the fan;   [1/s];
% fan_diameter:         a matrix, describes the diameter of the fan;    [m];
% parameter_AHU:        a struct, describes the AHU parameter;
%                         parameter_AHU.density:
%                         parameter_AHU.cp:
%                         parameter_AHU.resistance:
%                         parameter_AHU.barom_pressure:
%                         parameter_AHU.flowtype:
%
% parameter_fan:        a struct, describes the fan parameter;
%                         parameter_fan.coefficient:
%                         parameter_fan.air:
%                         parameter_fan.motor:
%% Model structure
if nargin<7
    FanDiameter=0.6858;
end
if nargin<8
    ParameterAHU(1).HeatExchType=2;% 0---Ideal flow;1---Counter flow;2----Cross flow
    ParameterAHU(2).HeatExchType=2;
    ParameterAHU(1).DesCoolingCoil.DesInletAirCC.temp=25;      % Dry bulb temperature;
    ParameterAHU(1).DesCoolingCoil.DesInletAirCC.Twb=18.8;     % Wet bulb temperature;
    ParameterAHU(1).DesCoolingCoil.DesInletAirCC.W=0.0022;      % Humidity ratio;[kg/kg(air)];
    ParameterAHU(1).DesCoolingCoil.DesInletAirCC.flowrate=2.764;  % Volume flowrate; [m3/s]
    ParameterAHU(2).DesCoolingCoil.DesInletWaterCC.temp=7;     
    ParameterAHU(2).DesCoolingCoil.DesInletWaterCC.flowrate=0.0022;
    ParameterAHU(3).DesCoolingCoil.ParameterCC.AirResis=5;
    ParameterAHU(3).DesCoolingCoil.ParameterCC.WaterResis=5;
    
    ParameterAHU(1).DesHeatingCoil.DesInletAirHC.temp=25;
    ParameterAHU(1).DesHeatingCoil.DesInletAirHC.Twb=18.8;
    ParameterAHU(1).DesHeatingCoil.DesInletAirHC.W=0.012;
    ParameterAHU(1).DesHeatingCoil.DesInletAirHC.flowrate=12;
    ParameterAHU(2).DesHeatingCoil.DesInletWaterHC.temp=7;
    ParameterAHU(2).DesHeatingCoil.DesInletWaterHC.flowrate=0.1;
    ParameterAHU(3).DesHeatingCoil.ParameterHC.AirResis=5;
    ParameterAHU(3).DesHeatingCoil.ParameterHC.WaterResis=5;
    
    ParameterAHU(1).AnalysisMode='SimpleAnalysis';% SimpleAnalysis and DetailedAnalysis
end

if nargin<9
    ParameterVFDFan.ManuDataMaxEff=[1499 12 0.919]; % [Pressure FlowRate Effectiveness]
    ParameterVFDFan.FanMaxDimFlow =0.16;     %! Maximum dimensionless flow from maufacturer's table.
    ParameterVFDFan.PulleyDiaRatio=1;        %! The ratio between pulley motor diameter and pulley fan diameter;
    ParameterVFDFan.MaxAirMassFlowRate=100;  %! Maximum massflow rate;[kg/s]
    ParameterVFDFan.MotInAirFrac=1;          %! Motor in Air Fraction, used in temperature rise model.
    ParameterVFDFan.MotorRatedOutPwr=30000;  %! Motor rated power;[w]
    ParameterVFDFan.SizeFactor=1.1;          %! Motor power size factor ;
    ParameterVFDFan.RhoAir=1.29;             %! Air density;[kg/m3]
    ParameterVFDFan.CurveIndex=[1 1 1 1 1 1 1 1 1 1 1]'; %! Curve index for calling fitted curve.
    ParameterVFDFan.BeltType=2;              %! Medium loss belt is used by default;
    ParameterVFDFan.MotorType=2;             %! Medium efficienct motor is used by default;
end
if nargin<10
   SizingParameter.DesignPressure=1.0*1e6;% 1.0 MPa 
end

%%%%%% INITIALIZATION FOR THE INPUT
% flow type
HeatExchTypeCC=ParameterAHU(1).HeatExchType;
HeatExchTypeHC=ParameterAHU(2).HeatExchType;

% Calculation Mode
AnalysisMode=ParameterAHU(1).AnalysisMode;   % String

% Design Information
DesInletAirCC=ParameterAHU(1).DesCoolingCoil.DesInletAirCC;
DesInletWaterCC=ParameterAHU(2).DesCoolingCoil.DesInletWaterCC;
ParameterCC=ParameterAHU(3).DesCoolingCoil.ParameterCC;
DesAirFlowrateCC=DesInletAirCC.flowrate;

DesInletAirHC=ParameterAHU(1).DesHeatingCoil.DesInletAirHC;
DesInletWaterHC=ParameterAHU(2).DesHeatingCoil.DesInletWaterHC;
ParameterHC=ParameterAHU(3).DesHeatingCoil.ParameterHC;

% air side input
InletAirTemp=InletAir.temp;
AirFlowRate=InletAir.flowrate;
InletAirRH=InletAir.RH;
InletAirDewPointTemp=InletAir.DewPTemp;
InletAirHumRat=InletAir.W;

% Water side input
InletWaterTempCC=InletWaterCC.temp;
InletWaterTempHC=InletWaterHC.temp;

% UA for coils
UADesignCC=CoilUA.CC;
UADesignHC=CoilUA.HC;

% sizing parameter
DesignPressure=SizingParameter.DesignPressure;

%%%%%% INITIALIZATION FOR THE OUTPUT
row=size(AirSetPointTemp,1);

OutletAirTemp=zeros(row,1);
OutletAirRH=zeros(row,1);
OutletAirHumRat=zeros(row,1);
OutletAirEnthalpy=zeros(row,1);
OutletAirWetBulbTemp=zeros(row,1);
OutletAirFlowRate=zeros(row,1);
AirDeltaP=zeros(row,1);

OutletWaterTempCC=zeros(row,1);
OutletWaterFlowRateCC=zeros(row,1);
WaterDeltaPCC=zeros(row,1);

OutletWaterTempHC=zeros(row,1);
OutletWaterFlowRateHC=zeros(row,1);
WaterDeltaPHC=zeros(row,1);

TotHeatTransferRate=zeros(row,1);
SenHeatTransferRate=zeros(row,1);

%% cooling coil and heating coil
%%%!!! air conditioning

k=1;
while k<=row
    if (Schedule(k)~=0)&&(AirFlowRate(k)>0)
        if (InletAirTemp(k)-AirSetPointTemp(k)>=0.5)                        % START cooling coil;
            % Cooling coil inlet
            InletAirCC.temp=InletAirTemp(k);
            InletAirCC.flowrate=AirFlowRate(k);
            InletAirCC.W=InletAirHumRat(k);
            InletAirCC.DewPTemp=InletAirDewPointTemp(k);
            InletWaterCC.temp=InletWaterTempCC(k);
            
            OutletAirTempSetPoint=AirSetPointTemp(k);     
            
            %%%!!! COOLING COIL           
            
            [OutletAirCC,OutletWaterCC,TotWaterCoolingCoilRateCC,SenWaterCoolingCoilRateCC]...
                =DesCoolingCoil(InletAirCC,InletWaterCC,OutletAirTempSetPoint,UADesignCC,...
                Schedule(k),HeatExchTypeCC,AnalysisMode,DesInletAirCC,DesInletWaterCC,ParameterCC);
            
            OutletAirTemp(k)=OutletAirCC.temp;
            OutletAirRH(k)=OutletAirCC.RH;
            OutletAirHumRat(k)=OutletAirCC.W;
            OutletAirEnthalpy(k)=OutletAirCC.H;
            OutletAirWetBulbTemp(k)=OutletAirCC.Twb;
            OutletAirFlowRate(k)=OutletAirCC.flowrate;
            AirDeltaP(k)=OutletAirCC.pressure_loss;
            
            OutletWaterTempCC(k)=OutletWaterCC.temp;
            OutletWaterFlowRateCC(k)=OutletWaterCC.flowrate;
            WaterDeltaPCC(k)=OutletWaterCC.pressure_loss;
            
            
            
            OutletWaterTempHC(k)=InletWaterHC.temp(k);
            OutletWaterFlowRateHC(k)=0;
            WaterDeltaPHC(k)=0;
            
            TotHeatTransferRate(k)=TotWaterCoolingCoilRateCC;
            SenHeatTransferRate(k)=SenWaterCoolingCoilRateCC;
            
        elseif (InletAirTemp(k)-AirSetPointTemp(k)<=-0.5)                          % Start heating coil
            
            % heating coil inlet condition
            InletAirHC.temp=InletAirTemp(k);
            InletAirHC.flowrate=AirFlowRate(k);
            InletAirHC.DewPTemp=InletAirDewPointTemp(k);
            InletAirHC.W=InletAirHumRat(k);
            
            InletWaterHC.temp=InletWaterTempHC(k);
            
            OutletAirTempSetPoint=AirSetPointTemp(k);
            
            
            %%%!!! HEATING COIL
            [OutletAirHC,OutletWaterHC,TotHeatingCoilRate]...
                =DesHeatingCoil(InletAirHC,InletWaterHC,OutletAirTempSetPoint,UADesignHC,...
                Schedule(k),HeatExchTypeHC,DesInletAirHC,DesInletWaterHC,ParameterHC);
            
            OutletAirTemp(k)=OutletAirHC.temp;
            OutletAirRH(k)=OutletAirHC.RH;
            OutletAirHumRat(k)=OutletAirHC.W;
            OutletAirEnthalpy(k)=OutletAirHC.H;
            OutletAirWetBulbTemp(k)=OutletAirHC.Twb;
            OutletAirFlowRate(k)=OutletAirHC.flowrate;
            AirDeltaP(k)=OutletAirHC.pressure_loss;
            
            OutletWaterTempHC(k)=OutletWaterHC.temp;
            OutletWaterFlowRateHC(k)=OutletWaterHC.flowrate;
            WaterDeltaPHC(k)=OutletWaterHC.pressure_loss;
            
            OutletWaterTempCC(k)=InletWaterCC.temp(k);
            OutletWaterFlowRateCC(k)=0;
            WaterDeltaPCC(k)=0;
            
            TotHeatTransferRate(k)=TotHeatingCoilRate;
            SenHeatTransferRate(k)=TotHeatingCoilRate;
            
        else    % Close Cooling Coil and Heating Coil But With Fan ON
            
            OutletAirTemp(k)=InletAir.temp;
            OutletAirRH(k)=InletAir.RH;
            OutletAirHumRat(k)=InletAir.W;
            OutletAirEnthalpy(k)=InletAir.H;
            OutletAirWetBulbTemp(k)=InletAir.Twb;
            OutletAirFlowRate(k)=InletAir.flowrate;
            AirDeltaP(k)=(ParameterCC.AirResis+ParameterHC.AirResis)*InletAirMassFlowRate(k).^2;
            
            OutletWaterTempHC(k)=InletWaterHC.temp;
            OutletWaterFlowRateHC(k)=0;
            WaterDeltaPHC(k)=0;
        
            OutletWaterTempCC(k)=InletWaterCC.temp(k);
            OutletWaterFlowRateCC(k)=0;
            WaterDeltaPCC(k)=0;
            
            TotHeatTransferRate(k)=0;
            SenHeatTransferRate(k)=0;
        end
        
    else
        % Schedule is off which means Fan is OFF£¡
        
        OutletAirTemp(k)=InletAir.temp(k);
        OutletAirRH(k)=InletAir.RH(k);
        OutletAirHumRat(k)=InletAir.W(k);
        OutletAirEnthalpy(k)=InletAir.H(k);
        OutletAirWetBulbTemp(k)=InletAir.Twb(k);
        OutletAirFlowRate(k)=0;
        AirDeltaP(k)=0;
        
        OutletWaterTempHC(k)=InletWaterHC.temp(k);
        OutletWaterFlowRateHC(k)=0;
        WaterDeltaPHC(k)=0;
     
        OutletWaterTempCC(k)=InletWaterTempCC(k);
        OutletWaterFlowRateCC(k)=0;
        WaterDeltaPCC(k)=0;
        
        TotHeatTransferRate(k)=0;
        SenHeatTransferRate(k)=0;
    end
    k=k+1;
end

OutletAirCCHC.temp=OutletAirTemp;
OutletAirCCHC.RH=OutletAirRH;
OutletAirCCHC.W=OutletAirHumRat;
OutletAirCCHC.H=OutletAirEnthalpy;
OutletAirCCHC.Twb=OutletAirWetBulbTemp;
OutletAirCCHC.flowrate=OutletAirFlowRate;
OutletAirCCHC.pressure_loss=AirDeltaP;
%% FAN
% Blow Fan;

[OutletAir,OutletFan]=FanVFD(OutletAirCCHC,OutletAirFlowRate,AirDeltaP,FanDiameter,Schedule,0,ParameterVFDFan);


%% Economic Cost
% Capitial Cost model
% Data from the RMeans Construction Data indicate that the capitial cost of
% AHU is function of its rated air flowrate
if DesAirFlowrateCC<=1e-8
    CapitalCostUSDBaseline=0;
else
    CapitalCostUSDBaseline=4150*(0.7154*DesAirFlowrateCC+0.7569);% x[2~70.8]
end
if DesignPressure==1.0*1e6
    CapitalCostUSD=CapitalCostUSDBaseline;
elseif DesignPressure==1.6*1e6
    CapitalCostUSD=CapitalCostUSDBaseline*(1+0.05);
elseif DesignPressure==2.0*1e6
    CapitalCostUSD=CapitalCostUSDBaseline*(1+0.11);
elseif DesignPressure==2.5*1e6
    CapitalCostUSD=CapitalCostUSDBaseline*(1+0.18);
elseif DesignPressure>2.5*1e6
    CapitalCostUSD=CapitalCostUSDBaseline*(1+0.26);
end


%% Update the output
%%%%%% OUTPUT OF THE COILS
OutletWaterCC.temp=OutletWaterTempCC;
OutletWaterCC.flowrate=OutletWaterFlowRateCC;
OutletWaterCC.pressure_loss=WaterDeltaPCC;

OutletWaterHC.temp=OutletWaterTempHC;
OutletWaterHC.flowrate=OutletWaterFlowRateHC;
OutletWaterHC.pressure_loss=WaterDeltaPHC;

% outlet condition;
OutletAirAHU=OutletAir;
PowerAHU=OutletFan.FanPower;
EffectivenessFan=OutletFan.efficiency;

% Economic cost
EconomicCost.CapCost=CapitalCostUSD;

end

