clear;

InletAir.temp=15.3;
InletAir.Twb=12;
InletAir.RH=PsychRHFuTdbTwb(InletAir.temp,InletAir.Twb);
InletAir.W=PsychWFuTdbRH(InletAir.temp,InletAir.RH);
InletAir.DewPTemp=PsychTdpFuTdbRH(InletAir.temp,InletAir.RH);
InletAir.flowrate=62720/3600;
InletAir.H=PsychHFuTdbRH(InletAir.temp,InletAir.RH);

OutletAir.temp=30;
OutletAir.W=InletAir.W;
%OutletAir.Twb=12.8;
OutletAir.RH=PsychRHFuTdbW(OutletAir.temp,OutletAir.W);

OutletAir.DewPTemp=PsychTdpFuTdbRH(OutletAir.temp,OutletAir.RH);
OutletAir.H=PsychHFuTdbRH(OutletAir.temp,OutletAir.RH);

InletWater.temp=60;

InletWater.flowrate=3.158987118711866e+05/(4180*20*RhoWater(InletWater.temp));



HeatExchType=2;

AnalysisMode='SimpleAnalysis';

Parameter.AirResis=6.351;
Parameter.WaterResis=396;

Schedule=1;

[UADesign,DesTotWaterCoilLoad]=DesignUAHeatingCoil...
    (InletAir,InletWater,OutletAir,HeatExchType,Parameter);

%[UA,DesOutletWaterTemp,TOTALHEAT]=DesignUA(InletAir,InletWater,OutletAir,HeatExchType,Parameter);