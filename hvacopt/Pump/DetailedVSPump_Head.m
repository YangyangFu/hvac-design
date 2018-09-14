function [water_out,head,power_total,heat2fluid]=DetailedVSPump_Head(water_in,N,diameter,parameter_pump)
%% Calculate head from given rotate speed and flowrate.
%
%% description
% =================================input===============================
% temperature_inlet: inlet temperature;[¡æ]
% flowrate_inlet:    inlet flowrate;[m3/s];
% pressure_inlet:    inlet pressure;[Pa]
% N:                 rotote speed;[1/s]
% diameter:          diameter of mover;[m];
% =================================output==============================
%
%% equation

if nargin<4
    parameter_pump(1).coefficient=[22 -1.387 4.2293 -3.92920 0.8534];% a;
    parameter_pump(2).coefficient=[0.1162 1.5404 -1.4825 0.7664 -0.1971];% b;
    parameter_pump(1).water=[4200 1000];% water feature;
    parameter_pump(1).motor=[0.87]; % motor efficiency;
    parameter_pump(2).motor=1; % motor loss fraction:when the motor is in the fluid,fraction is 1;else,0.
end
a=parameter_pump(1).coefficient;
b=parameter_pump(2).coefficient;
cp=parameter_pump(1).water(:,1); % water specific heat;
density=parameter_pump(1).water(:,2);% water density;
eff_motor=parameter_pump(1).motor;
frac_motor_loss=parameter_pump(2).motor;

temperature_inlet=water_in.temp;
flowrate_inlet=water_in.flowrate;
pressure_inlet=water_in.pressure;

massflow=flowrate_inlet*density;

flow_dimen=massflow./(density*N.*diameter.^3);
if  flow_dimen<=0
    water_out=water_in;
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
    
    % calculate the outlet condition
    heat2fluid=power_shaft+(power_total-power_shaft)*frac_motor_loss;
    
    parameter_heattransfer.cp=cp;
    parameter_heattransfer.density=density;
    temp_pump.temperature=temperature_inlet;
    [temperature_outlet]=HeatTransfer_Heat(flowrate_inlet,temp_pump,heat2fluid,0,parameter_heattransfer); % temperature rise model;
    flowrate_outlet=flowrate_inlet;
    pressure_outlet=head+pressure_inlet;
    
    % function output
    water_out.temp=temperature_outlet;
    water_out.flowrate=flowrate_outlet;
    water_out.pressure=pressure_outlet;
end
end