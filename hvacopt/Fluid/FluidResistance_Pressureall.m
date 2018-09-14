function [flowrate_inlet,flowrate_outlet,pressure_drop]=FluidResistance_Pressureall(pressure_inlet,pressure_outlet,parameter_fluidresistance)
%%

%% description
%=======================input================


%=======================output================


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
pressure_drop_critic=turbulent_resistance(1)*massflow_rate_critic(1)^2;
pressure_drop=pressure_inlet-pressure_outlet;

if pressure_drop<-pressure_drop_critic
   display('reverse flow occurs in FluidResistance');
   massflow_rate_inlet=-(-pressure_drop/turbulent_resistance(1)).^0.5;

elseif pressure_drop>pressure_drop_critic
       massflow_rate_inlet=(pressure_drop/turbulent_resistance(1)).^0.5;
else
       massflow_rate_inlet=pressure_drop/(turbulent_resistance(1)*massflow_rate_critic(1));
end

   flowrate_inlet=massflow_rate_inlet/density(1);
   flowrate_outlet=flowrate_inlet;
   
end
