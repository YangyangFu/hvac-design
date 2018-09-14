function [ pressure_inlet,flowrate_outlet ] =FlowSplit( flowrate_inlet,pressure_outlet,parameter_fluidsplit )
%% application

%% description
%=================input==========================
% flowrate_inlet:
% pressure_outlet: a 1-by-2 matrix describing pressure at each outlet; 
% parameter_fluidsplit: a struct 

%================output==========================
% pressure_inlet:
% flowrate_outlet:

%% model equation
% inlitialization

if nargin<3
    parameter_fluidsplit.turbulent_resistance=[0.01 0.01 0.01];
    parameter_fluidsplit.massflow_rate_critic=[0.03];
    parameter_fluidsplit.density=[1000];
end

turbulent_resistance=parameter_fluidsplit.turbulent_resistance;
massflow_rate_critic=parameter_fluidsplit.massflow_rate_critic;
density=parameter_fluidsplit.density;

pressure_outlet1=pressure_outlet(:,1);
pressure_outlet2=pressure_outlet(:,2);

% convergence tolerance and iteration number
epsilon=0.000001;
k=10^6;

% guess pressure_center

pressure_center(:,1)=pressure_outlet1+10;
pressure_center(:,2)=pressure_center(:,1);
for i=2:k
    
% solve the equation and iterate
parameter_fluidresistance1.turbulent_resistance=turbulent_resistance(:,1);
parameter_fluidresistance1.massflow_rate_critic=massflow_rate_critic(:,1);
parameter_fluidresistance1.density=density(:,1);                                             % main

parameter_fluidresistance2.turbulent_resistance=turbulent_resistance(:,2);
parameter_fluidresistance2.massflow_rate_critic=massflow_rate_critic(:,1);
parameter_fluidresistance2.density=density(:,1);                                           % branch 1

parameter_fluidresistance3.turbulent_resistance=turbulent_resistance(:,3);
parameter_fluidresistance3.massflow_rate_critic=massflow_rate_critic(:,1);
parameter_fluidresistance3.density=density(:,1);                                           % branch 2


[flowrate_center,pressure_inlet]=FluidResistance_Pressure_outlet(flowrate_inlet,(pressure_center(:,i)+pressure_center(:,i-1))/2,parameter_fluidresistance1);



[flowrate_inlet1,flowrate_outlet1]=FluidResistance_Pressureall((pressure_center(:,i)+pressure_center(:,i-1))/2,pressure_outlet1,parameter_fluidresistance2);
flowrate_inlet2=flowrate_center-flowrate_inlet1;
[flowrate_outlet2,pressure_center(:,i+1)]=FluidResistance_Pressure_outlet(flowrate_inlet2,pressure_outlet2,parameter_fluidresistance3);

obsolute_error(:,i)=abs(pressure_center(:,i+1)-pressure_center(:,i));
relative_error(:,i)=obsolute_error(:,i)./abs(pressure_center(:,i));
 
if (relative_error(:,i)>epsilon)
    disp('cannot converge in FlowSplit');
  break
end


flowrate_outlet=[flowrate_outlet1 flowrate_outlet2];


end


end

