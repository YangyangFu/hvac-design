function [power,flowrate_outlet,temperature_outlet]=VariableSpeedFan(flowrate_inlet,temperature_inlet,parameter_fan)
%% application

%% description
%=================input==========================
% flowrate_inlet:
% temperature_inlet:  a struct including :
%                     temperature_inlet.temperature: a column vector representing inlet temperature;[¡æ] 
%                     te,perature_inlet.RH:          a column vector representing inlet relative humidity.if the medium is water, this column is blank.                            

% 
% parameter_fluidsplit: a 1-by-3 cell

%================output==========================
% pressure_inlet:
% flowrate_outlet:

%% model equation
% initialization
if nargin<3
    parameter_fan(1).PQcoefficient=[0.0015302446 0.0052080574 1.1086242 -0.11635563 0.000];% a;
    
    parameter_fan(1).nominal=[3000 1.3 5500 0.87];% nominal information;
    parameter_fan(1).air=[1012 1.29];% water feature;
    parameter_fan(1).fraction=1;
end

b=parameter_fan(1).PQcoefficient;

head=parameter_fan(1).nominal(:,1); % [Pa];
flowrate_rated=parameter_fan(1).nominal(:,2);% [m3/s];
power_rated=parameter_fan(1).nominal(:,3); % [W];
eta_motor=parameter_fan(1).nominal(:,4); % 

cp=parameter_fan(1).air(:,1); % air specific heat;
density=parameter_fan(1).air(:,2);% air density;

fraction_motor2air=1;                 % The fraction of the motor heat that is added to the air stream. A value of 0 means that the motor is completely outside the air stream. A value of 1 means that all of the motor heat loss will go into the air stream and act to cause a temperature rise. Must be between 0 and 1.
% equation

row=size(flowrate_inlet,1);
power=zeros(row,1);
plr=flowrate_inlet./flowrate_rated;
for i=1:row
if plr(i,1)==0
    power(i,1)=0;
else
    power(i,1)=power_rated*(b(1)+b(2)*plr(i,1)+b(3)*plr(i,1).^2+b(4)*plr(i,1).^3+b(5)*plr(i,1).^4);  % P-Q curve;
end
end
power_shaft=eta_motor.*power;
heat2fluid=power_shaft+(power-power_shaft)*fraction_motor2air;



parameter_heattransfer.cp(:,2)=cp;
parameter_heattransfer.density(:,2)=density;

[temperature_outlet]=HeatTransfer_Heat(flowrate_inlet,temperature_inlet,heat2fluid,1,parameter_heattransfer); % temperature rise model;
flowrate_outlet=flowrate_inlet;