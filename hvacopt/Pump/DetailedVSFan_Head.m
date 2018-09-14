function [air_out,head,power_total,heat2fluid,eff_dimen]=DetailedVSFan_Head(air_in,N,diameter,MODE,parameter_fan)
%% Calculate head from given rotate speed and flowrate.
%
%% description
% =================================input===============================
% air_in: a struct describing inlet air information;
%         air_in.temp: inlet temperature;[¡æ]
%         air_in.RH:   inlet relative humidity;[--]
%         air_in.flowrate: inlet flowrate;[m3/s];
%         air_in.pressure: inlet pressure;[Pa];
% N:                 rotote speed;[1/s]
% diameter:          diameter of mover;[m];
% =================================output==============================
%
%% equation

if nargin<5
    parameter_fan(1).coefficient=[4.19370, -1.63370,12.2110, -23.9619, 9.81620];% a;
    parameter_fan(2).coefficient=[0.61900e-1, 3.14170 ,-5.75510, 6.16760 ,-3.37480];% b;
    parameter_fan(1).air=[1012 1.29];% air feature;
    parameter_fan(1).motor=[0.87]; % motor efficiency;
    parameter_fan(2).motor=0; % motor loss fraction:when the motor is in the fluid,fraction is 1;else,0.
end

if nargin<4
    MODE=0;
end
a=parameter_fan(1).coefficient;
b=parameter_fan(2).coefficient;
cp=parameter_fan(1).air(:,1); % air specific heat;
density=parameter_fan(1).air(:,2);% air density;
eff_motor=parameter_fan(1).motor;
frac_motor_loss=parameter_fan(2).motor;

temperature_inlet=air_in.temp;
RH_inlet=air_in.RH;
flowrate_inlet=air_in.flowrate;


massflow=flowrate_inlet*density;

flow_dimen=massflow/(density*N.*diameter.^3);

if flow_dimen<=0
    air_out=air_in;
    head=0;
    power_total=0;
    heat2fluid=0;
else
    pressure_dimen=a(1)+a(2)*flow_dimen+a(3)*flow_dimen.^2+a(4)*flow_dimen.^3+a(5)*flow_dimen.^4;
    head=pressure_dimen.*(density*diameter.^2.*N.^2);
    eff_dimen=b(1)+b(2)*flow_dimen+b(3)*flow_dimen.^2+b(4)*flow_dimen.^3+b(5)*flow_dimen.^4;
    
    % calculate power
    power_shaft=massflow.*head./(density.*eff_dimen);
    power_total=power_shaft/eff_motor;
    
    
    if MODE
        % calculate the outlet condition
        heat2fluid=power_shaft+(power_total-power_shaft)*frac_motor_loss;
        % temperature rise through fan
        temp_in.temperature=temperature_inlet;
        temp_in.RH=RH_inlet;
        [temp_out]=HeatTransfer_Heat(flowrate_inlet,temp_in,heat2fluid,1); % temperature rise model;
        temperature_out=temp_out.temp;
        RH_out=temp_out.RH;
        flowrate_outlet=flowrate_inlet;
       
    else
        heat2fluid=0;
        temperature_out=temperature_inlet;
        RH_out=RH_inlet;
        flowrate_outlet=flowrate_inlet;       
    end
    % function output
    air_out.temp=temperature_out;
    air_out.RH=RH_out;
    air_out.flowrate=flowrate_outlet;
   
end
end