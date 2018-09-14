clear;
air_in_CT.temp=[35;35;35;35;35;35;35;35;35;35];


water_in_CT.temp=[30.7094644936604;31.2888461029964;31.3082074313147;31.7468167601194;32.2293231296428;32.7487018547631;33.2968882785465;33.8667482360702;34.4524561657565;35.0493835106006] ;




[r1,c]=size(water_in_CT.temp);
[r2,c2]=size(air_in_CT.temp);

air_in_CT.RH=0.6*ones(r2,1);
temp_water_SP=30*ones(r1,1);

water_in_CT.flowrate=0.0264*ones(r1,1);


NCell=2;

type_CT=1;

[ flowrate_air_in,water_out,pressure_drop_water,heatflow,power] = DesVSCoolingTower_NTU(air_in_CT,water_in_CT,temp_water_SP,NCell,type_CT);

