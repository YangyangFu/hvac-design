function [flowrate_control,flowrate_bypass]=ThreePort(s,flowrate_primary,parameter_valve)
%% application 
% [Salsbabury,1996,Fault detection and diagnosis in HVAC system using
% Analytical model];
% expotient characteristic has been modelled in this component.

%% description
% =========================input=======================
% s: valve stem position; can be handled by control signals;        [0-1]
% flowrate_max:           maximum flowrate through the control port;[m3/s]
% parameter_valve: a struct, containing
%                  parameter_valve.belta: curvature parameter of the control port
%                  parameter_valve.A:  authority of the control port;tycally in [0.5 0.8];
%                  parameter_valve.density: fluid density;         [kg/m3]

% =========================output======================
% flowrate_control: the flowrate in the control port;

%% equation
if vargin<2
    flowrate_primary=0.001;
end
if vargin<3
    parameter_valve.belta=2.75;
    parameter_valve.A=0.55;
    parameter_valve.density=1000;
end

belta=parameter_valve.belta;
A=parameter_valve.A; % [0.5 0.8]
density_water=parameter_valve.density;

massflow_primary=flowrate_primary*density_water;


if belta==0
    fraction=s;
else
    fraction=(1-exp(belta*s))./(1-exp(belta));
end
massflow_rate=massflow_primary./(sqrt(1+A*(fraction.^(-2)-1)));
flowrate_control=massflow_rate./density_water; 
flowrate_bypass=primary_flow-flow_control;





