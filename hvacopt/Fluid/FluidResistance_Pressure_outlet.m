function [flowrate_outlet,pressure_inlet,pressure_drop]=FluidResistance_Pressure_outlet(flowrate_inlet,pressure_outlet,parameter_fluidresistance)
%% application
% leakage is not considered in this model.

%% description
% ==================input===================
% flowrate_inlet:   volume flow rate in the inlet  [m3/s];
% flowrate_outlet:  volume flow rate in the outlet [m3/s];
% parameter_fluidresistance: a 1-by-3 matrix,the first value is turbulent
%                            resistance Rt[1/kg.m],the second value is critical
%                            massflow rate [kg/s].
%=================output====================
% flowrate_outlet:
% pressure_outlet:
%% model equation


if nargin<3
    parameter_fluidresistance.turbulent_resistance=[0.01];
    parameter_fluidresistance.massflow_rate_critic=[0.03];
    parameter_fluidresistance.density=[1000];
end 
% initialization
turbulent_resistance=parameter_fluidresistance.turbulent_resistance;
massflow_rate_critic=parameter_fluidresistance.massflow_rate_critic;
density=parameter_fluidresistance.density;

% model equation

massflow_rate=density(1)*flowrate_inlet;

if massflow_rate<=massflow_rate_critic(1)
    pressure_drop=turbulent_resistance(1)*massflow_rate_critic(1)*massflow_rate;
else
    pressure_drop=turbulent_resistance(1)*massflow_rate.^2;
end

pressure_inlet=pressure_outlet+pressure_drop;
flowrate_outlet=flowrate_inlet;
end
