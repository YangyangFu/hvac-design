function [air_out,water_out,heatflow_total,epsilon]=SimplifiedCoolingCoil_NTU(air_in,water_in,CoilUA,flowtype,parameter_CC)
%% This model derives from "the chilled water based cooling coil" in energy plus.

%% Description
%=============================input=======================
% air_in: a struct,which contains air inlet information;
%                  air_in.temp:     temperature at air inlet;[¡æ]
%                  air_in.RH:       relative humidity;[---]
%                  air_in.flowrate; air flowrate at inlet;[m3/s];
%                  air_in.pressure: air pressure at inlet;[Pa]
% water_in: a struct, which contains water inlet information:
%                  water_in.temp:     temperature at water inlet;[¡æ]
%                  water_in.flowrate: water flowrate at inlet;[m3/s]
%                  water_in.pressure: water pressure at inlet;[Pa]
% CoilUA: the total UA value of a cooling coil; [W/K];
% flowtype: the flow type of a heat exchanger.
%                 0----  represents counter flow;
%                 else-- represents cross flow;
% parameter_CC: a struct, which contains media information and nominal information of cooling coil;
%             parameter_CC.cp: specific heat of air and
%                 water,respectively;default value is [1012
%                 4200];[J/(kg.K)];
%             parameter_CC.density: density of air and
%                 water,respectively;default value is [1.29,1000];[kg/m3]
%             parameter_CC.air_nominal: air side nominal inlet
%                 information,which contains inlet temperature and RH;
%             parameter_CC.water_nominal: water side nominal
%                 information, which contains inlet temperature[¡æ] and
%                 temperature range[¡æ];
%             parameter-CC.resisitance:  flow resistance at air side and water side respectively;[1/(kg.m)]
%=============================output======================
%
%% model equation
if nargin<4
    flowtype=0;
end
if nargin<5
    parameter_CC.cp=[1012 4200];
    parameter_CC.density=[1.29 1000];
    parameter_CC.air_nominal=[25,0.5]; % air side nominal inlet condition
    parameter_CC.water_nominal=[6,6];  % water side nominal condition
    parameter_CC.resistance=[5e2 1e6]; 
end
%%% !!! INITIALIZATION
% initilization for the PARAMETERS
cp_air=parameter_CC.cp(1);
cp_water=parameter_CC.cp(2);
density_air=parameter_CC.density(1);
density_water=parameter_CC.density(2);
temp_air_in_nom=parameter_CC.air_nominal(1);
RH_in_nom=parameter_CC.air_nominal(2);
temp_water_in_nom=parameter_CC.water_nominal(1);
resistance_air=parameter_CC.resistance(1);
resistance_water=parameter_CC.resistance(2);

% initialization for the INPUT
temp_air_in=air_in.temp;
RH_in=air_in.RH;
flowrate_air=air_in.flowrate;

temp_water_in=water_in.temp;
flowrate_water=water_in.flowrate;

%%% !!! CHECK FOR THE INLET CONDITION
if temp_air_in<temp_water_in
    flowrate_water=0;
end
massflow_air=flowrate_air*density_air;
massflow_water=flowrate_water*density_water;

%%% !!! Effectiveness Equations
cap_air=massflow_air*cp_air;
cap_water=massflow_water*cp_water;

minCap=min(cap_air,cap_water);
maxCap=max(cap_air,cap_water);

ratio=minCap./maxCap;
NTU=CoilUA./minCap;

if flowtype==0   % ideal
    epsilon=ones(size(flowrate_air));
elseif flowtype==1   % counter flow
    epsilon=(1-exp(-NTU.*(1-ratio)))./(1-ratio.*exp(-NTU.*(1-ratio)));
elseif flowtype==2         % cross flow
    epsilon=1-exp((exp(-NTU.*ratio.*NTU^(-0.22))-1)./(ratio.*NTU^(-0.22)));
end

% Coil outlet Conditions
max_heatflow=minCap.*(temp_air_in-temp_water_in);

temp_air_out=temp_air_in-epsilon.*max_heatflow./cap_air;


% dry or wet coil determination
[h_air_in,W_in,temp_air_in_dp]=PsychTdbRH(temp_air_in,RH_in);

% dry coil
if temp_air_in_dp<temp_water_in
    heatflow_total=epsilon.*max_heatflow;
    W_out=W_in;
    RH_out=PsychRHFuTdbW(temp_air_out,W_out);
end

% wet coil
if temp_air_in_dp>=temp_water_in
    % Typical assumption: UA_internal=3.3¡ÁUA_external;
    UA_external=1.3*CoilUA ;
    UA_internal=10/3*UA_external;
    
    [h_air_in_nom_dp]=PsychTdbRH(temp_air_in_nom,RH_in_nom);
    [h_water_in_nom]=PsychTdbRH(temp_water_in_nom,1);
    cp_sat=(h_air_in_nom_dp-h_water_in_nom)./(temp_air_in_nom-temp_water_in_nom);
    
    CoilUA_enthalpy=1./(cp_sat./UA_internal+cp_air./UA_external);
    min_cp=min(massflow_air,massflow_water*cp_water/cp_sat);
    NTU=CoilUA_enthalpy./min_cp;
    
    if flowtype==0   % ideal
        epsilon=ones(size(flowrate_air));
    elseif flowtype==1   % counter flow
        epsilon=(1-exp(-NTU.*(1-ratio)))./(1-ratio.*exp(-NTU.*(1-ratio)));
    elseif flowtype==2         % cross flow
        epsilon=1-exp((exp(-NTU.*ratio.*NTU^(-0.22))-1)./(ratio.*NTU^(-0.22)));
    end
    
    
    [h_water_in]=PsychTdbRH(temp_water_in,1);
    max_heatflow=min_cp.*(h_air_in-h_water_in);
    
    heatflow_total=epsilon.*max_heatflow;
    
    h_air_out=h_air_in-heatflow_total./massflow_air;
    
    eta=1-exp(-UA_external./cap_air);
    h_air_condensate=h_air_in-(h_air_in-h_air_out)./eta;
    temp_air_condensate=PsychTdbFuHRH(h_air_condensate,1);
    
    if temp_air_condensate<temp_air_in_dp
        temp_air_out=temp_air_in-(temp_air_in-temp_air_condensate).*eta;
        W_out=PsychWFuTdbH(temp_air_out,h_air_out);
        RH_out=PsychRHFuTdbW(temp_air_out,W_out);
    else % there is no condensation and the inlet and oulet humidity ratio are equal
        W_out=W_in;
        temp_air_out=PsychTdbFuHW( h_air_out,W_out );
        RH_out=PsychRHFuTdbW(temp_air_out,W_out);
    end
end

% Water Outlet condition
temp_water_out=temp_water_in+heatflow_total./cap_water;

% Pressure calculation
DeltaP_air=resistance_air*massflow_air.^2;
DeltaP_water=resistance_water*massflow_water.^2;

% OUTPUT of this model
air_out.temp=temp_air_out;
air_out.RH=RH_out;
air_out.flowrate=flowrate_air;
air_out.pressure_loss=DeltaP_air;

water_out.temp=temp_water_out;
water_out.flowrate=flowrate_water;
water_out.pressure_loss=DeltaP_water;
end
