clear;

%Parameter.A=27.3;
%Parameter.B=353.6;
%Parameter.m=0.58;
%Parameter.n=0.075;
%Parameter.p=1.02;
Parameter.AirResis=5;
Parameter.WaterResis=10;

InletAir.temp=[25:1:30]';
row=size(InletAir.temp,1);

InletAir.RH=0.6*ones(row,1);

[ InletAir ] = PsychInfo( InletAir );

InletAir.flowrate=2.764*ones(row,1);

InletWater.temp=6*ones(row,1);

TempSetPoint=13*ones(row,1);

%SurfaceArea=150;
TempDifference=6;

Schedule=ones(row,1);

DesInformation.AirVelocity=2.5;
DesInformation.AirFlowrate=2.764;
DesInformation.WaterVelocity=1.5;

[OutletAir,OutletWater,TotalHeatflow]=SimpleDesignCoolingCoil(...
    InletAir,InletWater,TempSetPoint,TempDifference,Schedule,Parameter);


