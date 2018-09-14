
InletAir.temp=24.4;
row=size(InletAir.temp,1);
%InletAir.RH=0.5398*ones(row,1);
InletAir.Twb=20.0816*ones(row,1);
InletAir.RH=PsychRHFuTdbTwb(InletAir.temp,InletAir.Twb);


InletAir.W=PsychWFuTdbRH(InletAir.temp,InletAir.RH);
InletAir.Twb=PsychTwbFuTdbW(InletAir.temp,InletAir.W);

InletAir.DewPTemp=PsychTdpFuTdbRH(InletAir.temp,InletAir.RH);
InletAir.flowrate=7.65*ones(row,1);

InletWater.temp=6*ones(row,1);
InletWater.flowrate=0.0056;%55638/(4180*6*1000)*ones(row,1);

OutletAirTempSetPoint=16*ones(row,1);

UADesign.UATotal=2.648418192400104e+04;
UADesign.UAExternal=4.753999462824377e+04;
UADesign.UAInternal=1.568819822732045e+05;


DesInletAir.temp=25.4;
DesInletAir.Twb=18.8;
DesInletAir.RH=PsychRHFuTdbTwb(DesInletAir.temp,DesInletAir.Twb);
DesInletAir.W=PsychWFuTdbRH(DesInletAir.temp,DesInletAir.RH);
DesInletAir.DewPTemp=PsychTdpFuTdbRH(DesInletAir.temp,DesInletAir.RH);
DesInletAir.flowrate=7.9224;


DesInletWater.temp=6;
DesInletWater.flowrate=0.0076;
HeatExchType=2;

AnalysisMode='SimpleAnalysis';

Parameter.AirResis=5;
Parameter.WaterResis=5;

Schedule=1*ones(row,1);

%[OutletAir,OutletWater,TotWaterCoolingCoilRate]...
 %   =DesHeatingCoil(InletAir,InletWater,OutletAirTempSetPoint,UADesign,...
  %  Schedule,HeatExchType,DesInletAir,DesInletWater,Parameter);

%[OutletAir,OutletWater,TotWaterCoolingCoilRate,SenWaterCoolingCoilRate]...
%    =DesCoolingCoil(InletAir,InletWater,OutletAirTempSetPoint,UADesign,...
%    Schedule,HeatExchType,AnalysisMode,DesInletAir,DesInletWater,Parameter);
[OutletAir,OutletWater,TotWaterCoolingCoilRate,SenWaterCoolingCoilRate]=...
    CoolingCoil(InletAir,InletWater,UADesign,...
    Schedule,HeatExchType,AnalysisMode,DesInletAir,DesInletWater,Parameter);
