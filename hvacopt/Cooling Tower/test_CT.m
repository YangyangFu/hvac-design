clear;
air_in_CT.temp=[26 27 28 29 30 31 32]';


water_in_CT.temp=[31 32 33 34 35 36 37]';




[r1,c]=size(water_in_CT.temp);

air_in_CT.RH=0.5*ones(r1,1);
temp_water_SP=30*ones(r1,1);

water_in_CT.flowrate=0.0015*ones(r1,1);

[r2,c2]=size(air_in_CT.temp);

for i=1:r2
    air_in.temp=air_in_CT.temp(i,1)*ones(r1,1);
    air_in.RH=air_in_CT.RH;
    [ flowrate_air_in,water_out,pressure_drop_water,heatflow,power] = DesVSCoolingTower_NTU(air_in_CT,water_in_CT,temp_water_SP,3);
    P(:,i)=power;
    Heat(:,i)=heatflow;
    FLA(:,1)=flowrate_air_in;
end
TEMP_AIR_IN=air_in_CT.temp;
TEMP_WATER_IN=water_in_CT.temp;


surfl(TEMP_AIR_IN,TEMP_WATER_IN,P);
title('Power-Ta,in-Tw,in');
xlabel('Ta,in (¡æ)');
ylabel('Tw,in (¡æ)');
zlabel('Power (W)');