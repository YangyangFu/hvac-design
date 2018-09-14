function [flowrate_outlet,temperature_outlet, pressure_outlet]=VariableSpeedPump...
    (flowrate_inlet,temperature_inlet,pressure_inlet,parameter_pump)
%% application

%% description
%=================input==========================
% flowrate_inlet:
% temperature_inlet:
% pressure_inlet:
% parameter_fluidsplit: a 1-by-3 cell

%================output==========================
% pressure_inlet:
% flowrate_outlet:

%% model equation
% initialization
if nargin<4
    parameter_pump(1).coefficient=[0 1 0 0];% a;
    parameter_pump(2).coefficient=[0 1 0 0];% b;
    parameter_pump(1).nominal=[300000 0.0011 500 0.87];% nominal information;
    parameter_pump(1).water=[4200 1000];% water feature;
end
a=parameter_pump(1).coefficient;
b=parameter_pump(2).coefficient;

head=parameter_pump(1).nominal(:,1); % [Pa];
flowrate_rated=parameter_pump(1).nominal(:,2);% [m3/s];
power_rated=parameter_pump(1).nominal(:,3); % [W];
eta_motor=parameter_pump(1).nominal(:,4); % 

cp=parameter_pump(1).water(:,1); % water specific heat;
density=parameter_pump(1).water(:,2);% water density;

% equation

plr=flowrate_inlet./flowrate_rated;
pressure_rise=head*(a(1)+a(2)*plr+a(3)*plr.^2+a(4)*plr.^3); % H -Q curve;
pressure_outlet=pressure_inlet+pressure_rise;
power=power_rated*(b(1)+b(2)*plr+b(3)*plr.^2+b(4)*plr.^3);  % P-Q curve;

heat2fluid=eta_motor.*power-pressure_rise.*flowrate_inlet;

if heat2fluid<=0
    disp('error: 泵的有效效率大于电机效率');
end

parameter_heattransfer.cp=cp;
parameter_heattransfer.density=density;
[temperature_outlet]=HeatTransfer_Heat(flowrate_inlet,temperature_inlet,heat2fluid,parameter_heattransfer); % temperature rise model;
flowrate_outlet=flowrate_inlet;
