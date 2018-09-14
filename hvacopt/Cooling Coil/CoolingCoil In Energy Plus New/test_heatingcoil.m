

clear;


InletAir.temp=[5:1:15]';
row=size(InletAir.temp,1);

InletAir.RH=0.55*ones(row,1);

InletAir.W=PsychWFuTdbRH(InletAir.temp,InletAir.RH);
InletAir.Twb=PsychTwbFuTdbW(InletAir.temp,InletAir.W);
InletAir.DewPTemp=PsychTdpFuTdbRH(InletAir.temp,InletAir.RH);
InletAir.flowrate=2.764*ones(row,1);

InletWater.temp=50*ones(row,1);
InletWater.flowrate=55638/(4180*6*1000)*ones(row,1);

UADesign.UAExternal=6414.19691939161;
UADesign.UAInternal=2.116684983399230e+04;
UADesign.UATotal=4.922523217207511e+03;


DesInletAir.temp=10;
DesInletAir.Twb=18.8;
DesInletAir.RH=PsychRHFuTdbTwb(DesInletAir.temp,DesInletAir.Twb);
DesInletAir.W=PsychWFuTdbRH(DesInletAir.temp,DesInletAir.RH);
DesInletAir.DewPTemp=PsychTdpFuTdbRH(DesInletAir.temp,DesInletAir.RH);
DesInletAir.flowrate=2.764;

DesInletWater.temp=50;
DesInletWater.flowrate=55638/(4180*6*1000);

HeatExchType=2;

AnalysisMode='SimpleAnalysis';

Parameter.AirResis=5;
Parameter.WaterResis=5;

Schedule=1*ones(row,1);

[OutletAir,OutletWater,TotWaterHeatingCoilRate]=...
    HeatingCoil(InletAir,InletWater,UADesign,...
    Schedule,HeatExchType,DesInletAir,DesInletWater,Parameter);

