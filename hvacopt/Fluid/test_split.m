clear;

primary.temp=7;
primary.pressure=101325;
primary.resistance=1e5;

a{1}=[0.0001 1e5];
a{2}=[0.0001 5e5];



[temp_out,flowrate_out,pressure_out]=Merge(primary,1000,a);