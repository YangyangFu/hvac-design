function [air_out,power_total,heat2fluid,N]=DetailedVSFan_N(air_in,head,diameter,MODE,parameter_fan)
%% Calculate Rotate Speed from given head and flowrate.
%
%% description
% =================================input===============================

% =================================output==============================

%% equation
if nargin<4
   MODE=0; 

end
if nargin<5
    parameter_fan(1).coefficient=[22 -1.387 4.2293 -3.92920 0.8534];% a;
    parameter_fan(2).coefficient=[0.1162 1.5404 -1.4825 0.7664 -0.1971];% b;
    parameter_fan(1).air=[1012 1.29];% air feature;
    parameter_fan(1).motor=[0.87]; % motor efficiency;
    parameter_fan(2).motor=1; % motor loss fraction:when the motor is in the fluid,fraction is 1;else,0.
end
a=parameter_fan(1).coefficient;
b=parameter_fan(2).coefficient;
cp=parameter_fan(1).air(:,1); % water specific heat;
density=parameter_fan(1).air(:,2);% water density;
eff_motor=parameter_fan(1).motor;
frac_motor_loss=parameter_fan(2).motor;

temperature_inlet=air_in.temp;
RH_inlet=air_in.RH;
flowrate_inlet=air_in.flowrate;

massflow=flowrate_inlet*density;

% FAN IS OFF!
if massflow<=0
    air_out=air_in;
    power_total=0;
    heat2fluid=0;
    N=0;
    % FAN IS ON!
else
    % iteration for rotate speed
    N0=20;
    fun=@NEquation;
    [N]=fzero(fun,N0);
    
    flow_dimen=massflow./(density*N*diameter.^3);
    eff_dimen=b(1)+b(2)*flow_dimen+b(3)*flow_dimen.^2+b(4)*flow_dimen.^3+b(5)*flow_dimen.^4;
    
    % calculate power
    power_shaft=massflow.*head./(density.*eff_dimen);
    power_total=power_shaft/eff_motor;
    
    if MODE
    % calculate the outlet condition
    heat2fluid=power_shaft+(power_total-power_shaft)*frac_motor_loss;
    
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
    

    function y=NEquation(N)
        flow_dimen=massflow./(density*N*diameter.^3);       
        pressure_dimen=a(1)+a(2)*flow_dimen+a(3)*flow_dimen.^2+a(4)*flow_dimen.^3+a(5)*flow_dimen.^4;       
        y=sqrt((head./(density*diameter.^2*pressure_dimen)))-N;
    end

end