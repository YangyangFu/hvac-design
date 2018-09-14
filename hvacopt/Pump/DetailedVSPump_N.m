function [water_out,power_total,heat2fluid,N]=DetailedVSPump_N(water_in,head_matrix,diameter,MODE,parameter_pump)
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
    parameter_pump(1).coefficient=[22 -1.387 4.2293 -3.92920 0.8534];% a;
    parameter_pump(2).coefficient=[0.1162 1.5404 -1.4825 0.7664 -0.1971];% b;
    parameter_pump(1).water=[4200 1000];% water feature;
    parameter_pump(1).motor=[0.87]; % motor efficiency;
    parameter_pump(2).motor=1; % motor loss fraction:when the motor is in the fluid,fraction is 1;else,0.
end
% initialization
a=parameter_pump(1).coefficient;
b=parameter_pump(2).coefficient;
cp=parameter_pump(1).water(:,1); % water specific heat;
density=parameter_pump(1).water(:,2);% water density;
eff_motor=parameter_pump(1).motor;
frac_motor_loss=parameter_pump(2).motor;

% inlet condition
temperature_inlet_matrix=water_in.temp;
flowrate_inlet=water_in.flowrate;

massflow_matrix=flowrate_inlet*density;


%%% !!!! initializtion for the output
row=size(water_in.flowrate,1);

temperature_outlet=zeros(row,1);
flowrate_outlet=zeros(row,1);
power_total=zeros(row,1);
heat2fluid=zeros(row,1);
N_matrix=zeros(row,1);
eff_dimen=zeros(row,1);

k=1;
while k<=row
    
    % FAN IS OFF!
    if massflow_matrix(k)<=0
        temperature_outlet(k)=water_in.temp(k);
        flowrate_outlet(k)=water_in.flowrate(k);
        power_total(k)=0;
        heat2fluid(k)=0;
        N_matrix(k)=0;
        % FAN IS ON!
    else
        % iteration for rotate speed
        massflow=massflow_matrix(k);
        head=head_matrix(k);
        
        N0=10;
        fun=@NEquation;
        [N]=fzero(fun,N0);
        N_matrix(k)=N;
        
        eff_dimen(k)=b(1)+b(2)*flow_dimen+b(3)*flow_dimen.^2+b(4)*flow_dimen.^3+b(5)*flow_dimen.^4;
        
        % calculate power
        power_shaft=massflow.*head./(density.*eff_dimen(k));
        power_total(k)=power_shaft/eff_motor;
        
        % calculate the outlet condition
        heat2fluid(k)=power_shaft+(power_total(k)-power_shaft)*frac_motor_loss;
        
        if MODE
            % temperature rise
            parameter_heattransfer.cp=cp;
            parameter_heattransfer.density=density;
            temp_pump.temperature=temperature_inlet_matrix(k);
            [temperature_outlet(k)]=HeatTransfer_Heat(flowrate_inlet(k),temp_pump,heat2fluid(k),0,parameter_heattransfer); % temperature rise model;
            flowrate_outlet(k)=flowrate_inlet(k);
        else
            temperature_outlet(k)=temperature_inlet_matrix(k);
            flowrate_outlet(k)=flowrate_inlet(k);
        end
    end
    k=k+1;
end
% function output
water_out.temp=temperature_outlet;
water_out.flowrate=flowrate_outlet;

    function y=NEquation(N)
        flow_dimen=massflow./(density*N*diameter.^3);
        pressure_dimen=a(1)+a(2)*flow_dimen+a(3)*flow_dimen.^2+a(4)*flow_dimen.^3+a(5)*flow_dimen.^4;
        y=sqrt((head./(density*diameter.^2*pressure_dimen)))-N;
    end

end