function [temp_out,RH_out,flowrate_out]=AirMixer(temp_in,RH_in,flowrate_in,parameter_airmixer)
%% application

%% description
% ===========================input=====================
% temp_in: a struct, which contains 
%                          temp_in.temp1: temperature at inlet 1; [¡æ]
%                          temp_in.temp2: temperature at inlet 2; [¡æ]
% RH_in:   a struct, which contains
%                          RH_in.RH1:     relative humidity at inlet 1;
%                          RH_in.RH2:     relative humidity at inlet 2;

% flowrate_in: a struct, which contains
%                         flowrate_in.flowrate1; flowrate at inlet 1;[m3/s]
%                         flowrate_in.flowrate2: flowrate at inlet 2;[m3/s]
% parameter_airmixer: a struct, which contains
%                          parameter_airmixer.density: air density;[kg/m3]£»
%                          parameter_airmixer.barom_pressure:barometric
%                          pressure;[Pa]

% ===================================output================================


%% equation

if nargin<4
    parameter_airmixer.density=1.29;
    parameter_airmixer.barom_pressure=101325;
    parameter_airmixer.resistance=[5e5 5e5 5e5];
end

temp_in1=temp_in.temp1;
temp_in2=temp_in.temp2;
RH_in1=RH_in.RH1;
RH_in2=RH_in.RH2;
flowrate_in1=flowrate_in.flowrate1;
flowrate_in2=flowrate_in.flowrate2;

density_air=parameter_airmixer.density;
barom_pressure=parameter_airmixer.barom_pressure;


massflow_in1=flowrate_in1*density_air;
massflow_in2=flowrate_in2*density_air;

massflow_out=massflow_in1+massflow_in2;

[w_in1]=PsychWFuTdbRH(temp_in1,RH_in1,barom_pressure);
[w_in2]=PsychWFuTdbRH(temp_in2,RH_in2,barom_pressure);

%@@@@@@@@ Initialize the OUTPUT

row=size(flowrate_in1,1);
flowrate_out=zeros(row,1);
w_out=zeros(row,1);
temp_out=zeros(row,1);
RH_out=zeros(row,1);

k=1;
while k<=row
    if massflow_out(k)<=0
        % outlet calculation
        flowrate_out(k)=0;
        w_out(k)=0;
        temp_out(k)=0;
        RH_out(k)=0;
    else
        flowrate_out(k)=massflow_out(k)/density_air;
        w_out(k)=(massflow_in1(k).*w_in1(k)+massflow_in2(k).*w_in2(k))./massflow_out(k);
        temp_out(k)=(massflow_in1(k).*temp_in1(k)+massflow_in2(k).*temp_in2(k))./massflow_out(k);
        RH_out(k)=PsychRHFuTdbW(temp_out(k),w_out(k),barom_pressure);
    end
    k=k+1;
end


