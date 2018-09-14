function [temp_air_out,flowrate_air_out,heatflow,power]=EleHeatingCoil_Control(temp_air_in,flowrate_air_in,temp_sp,QCoilReq,cap_nominal,parameter_EHC)
% The electric air heating coil is a simple capacity model with a
% user-input efficiency. In many cases, this efficiency for the electric
% coil will be 100%. This coil only has air nodes to connect it in the
% system. The coil can be used in the air loop simulation or in the zone
% equipment as a reheat coil. Depending on where it is used determines if
% this coil is temperature or capacity controlled. 

%% description
% =========================input=========================
% temp_air_in:          inlet air temperature; [¡æ]
% flowrate_air_in:      inlet air flowrate;    [¡æ]
% temp_sp:              outlet air temperature setpoint. Used in
%                       temperature control¡£  [¡æ]
% QCoilReq:             heatflow required. Used in capacity control.[W]
% cap_nominal:          nominal capactiy.      [W]
% ========================output=========================
% temp_air_out:          inlet air temperature; [¡æ]
% flowrate_air_out:      inlet air flowrate;    [¡æ]
% heatflow:              heat flow through electrical heating coil.[W];
% power:                 power consumption in electrical heating coil.[W];

%% equation
if nargin<5
    cap_nominal=6000;
end
if nargin<6
    parameter_EHC.cp=1012;
    parameter_EHC.density=1.29;
    parameter_EHC.eff=0.99;
end

cp_air=parameter_EHC.cp;
density_air=parameter_EHC.density;
efficiency=parameter_EHC.eff;

massflow_air=flowrate_air_in*density_air;
cap_air=massflow_air*cp_air;

% Control output to meet load QCoilReq
if (QCoilReq>0) & (temp_sp==0)
    % check to see if the Required heating capacity is greater than the
    % user specified capacity.
    if QCoilReq>cap_nominal
        heat_HC=cap_nominal;
    else
        heat_HC=QCoilReq;
    end
    % outlet condition
    temp_air_out=temp_air_in+heat_HC./cap_air;
   
%   Control coil output to meet a setpoint temperature 
elseif (QCoilReq==0) & (temp_sp>0)
    heat_HC=cap_air.*(temp_sp-temp_air_in);
    % check to see if setpoint above enetering temperature. If not, set
    % output to zero.
    if heat_HC<0
        heat_HC=0;
        temp_air_out=temp_air_in;
    % check to see if the Required heating capacity is greater than the user
    % specified capacity.
    elseif (heat_HC>cap_nominal)
       heat_HC=cap_nominal;
       temp_air_out=temp_air_in+heat_HC./cap_air;
    else
       temp_air_out=temp_sp;
    end
    
end
    flowrate_air_out=flowrate_air_in;
    heatflow=heat_HC;
    power=heatflow./efficiency;


