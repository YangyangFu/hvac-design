
clear;

InletAir.temp=25.4;
InletAir.Twb=18.8;
InletAir.RH=PsychRHFuTdbTwb(InletAir.temp,InletAir.Twb);

InletAir=PsychInfo(InletAir);

InletAir.flowrate=42880/3600;

temp=[5:0.2:9];


TempSetPoint=12.8;

%OutletWaterTemp=13;

Schedule=1;

DesInformation.AirVelocity=2.5;
DesInformation.AirFlowrate=62880/3600;
DesInformation.WaterVelocity=1.5;

Parameter.A=27.3;
Parameter.B=353.6;
Parameter.m=0.58;
Parameter.n=0.075;
Parameter.p=1.02;
Parameter.AirResis=16;
Parameter.WaterResis=5;

OutletWaterTemp=12;
SurfaceArea=690;

for i=1:length(temp)
    InletWater.temp=temp(i);
[OutletAir,OutletWater,TotHeatTransferRate,SenWaterCoolingCoilRate]=...
    SimpleDesignCoolingCoilLMTD(...
    InletAir,InletWater,TempSetPoint,SurfaceArea,Schedule,DesInformation,Parameter);
% [OutletAir,OutletWater,SurfaceArea,TotHeatTransferRate]=DesignSurface...
%   (InletAir,InletWater,TempSetPoint,OutletWaterTemp,Schedule,DesInformation,Parameter);
OutletWaterTemp(i)=OutletWater.temp;
end