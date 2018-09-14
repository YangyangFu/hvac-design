function [flowrate_outlet,pressure_inlet,i]=FlowMerge(flowrate_inlet,pressure_outlet,parameter_fluidmerge)
%% application

%% description
%=================input==========================
% flowrate_inlet:
% pressure_outlet:
% parameter_fluidsplit: a 1-by-3 cell

%================output==========================
% pressure_inlet:
% flowrate_outlet:

%% model equation
% inlitialization
if nargin<3
    parameter_fluidmerge.turbulent_resistance=[0.01 0.01 0.01];
    parameter_fluidmerge.massflow_rate_critic=[0.03];
    parameter_fluidmerge.density=[1000];
end

turbulent_resistance=parameter_fluidmerge.turbulent_resistance;
massflow_rate_critic=parameter_fluidmerge.massflow_rate_critic;
density=parameter_fluidmerge.density;

flowrate_inlet1=flowrate_inlet(:,1);
flowrate_inlet2=flowrate_inlet(:,2);
% convergence tolerance and iteration number
epsilon=0.00001;
k=10^6;

% guess pressure_center

pressure_center(:,1)=pressure_outlet+10;
pressure_center(:,2)=pressure_center(:,1);
% solve the equation and iterate
for i=2:k
    
% use FluidResistance 
parameter_fluidresistance1.turbulent_resistance=turbulent_resistance(:,1);
parameter_fluidresistance1.massflow_rate_critic=massflow_rate_critic(:,1);
parameter_fluidresistance1.density=density(:,1);                                             % branch 1

parameter_fluidresistance2.turbulent_resistance=turbulent_resistance(:,2);
parameter_fluidresistance2.massflow_rate_critic=massflow_rate_critic(:,1);
parameter_fluidresistance2.density=density(:,1);                                           % branch 2

parameter_fluidresistance3.turbulent_resistance=turbulent_resistance(:,3);
parameter_fluidresistance3.massflow_rate_critic=massflow_rate_critic(:,1);
parameter_fluidresistance3.density=density(:,1);                                           % main

[flowrate_outlet1,pressure_inlet1]=FluidResistance_Pressure_outlet(flowrate_inlet1,(pressure_center(:,i)+pressure_center(:,i-1))/2,parameter_fluidresistance1);
[flowrate_outlet2,pressure_inlet2]=FluidResistance_Pressure_outlet(flowrate_inlet2,(pressure_center(:,i)+pressure_center(:,i-1))/2,parameter_fluidresistance2);

flowrate_center=flowrate_outlet1+flowrate_outlet2;

[flowrate_outlet,pressure_center(:,i+1)]=FluidResistance_Pressure_outlet(flowrate_center,pressure_outlet,parameter_fluidresistance3);

obsolute_error(:,i)=abs(pressure_center(:,i+1)-pressure_center(:,i));
relative_error(:,i)=obsolute_error(:,i)./abs(pressure_center(:,i));
 
if (relative_error(:,i)<=epsilon)
    
  break;
end


pressure_inlet=[pressure_inlet1,pressure_inlet2];


end


end
