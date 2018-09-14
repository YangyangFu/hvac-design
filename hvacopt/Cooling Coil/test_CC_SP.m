
clear;
temp_SP=[13.5:0.5:18]';

row=size(temp_SP,1);

air_in.temp=24.5;
air_in.RH=0.5559;
air_in.w=PsychWFuTdbRH(air_in.temp,air_in.RH);
air_in.flowrate=42060/3600;
air_in.pressure=101325;

water_in.temp=6;

water_in.pressure=101325;

CoilUA=1.06*15464.28857;

flowtype=2;
for i=1:row
[air_out,water_out,heatflow_total,epsilon]=DesSimplifiedCC_NTU(air_in,water_in,temp_SP(i),CoilUA,flowtype);

WaterOutTemp(i,1)=water_out.temp;
WaterOutFlowRate(i,1)=water_out.flowrate;
HeatFlow(i,1)=heatflow_total;
EPS(i,1)=epsilon;
end

 plotyy(temp_SP,WaterOutFlowRate,temp_SP,WaterOutTemp);