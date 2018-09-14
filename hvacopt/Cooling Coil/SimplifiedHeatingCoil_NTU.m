function [ air_out,water_out,heatflow ] = SimplifiedHeatingCoil_NTU(air_in,water_in,CoilUA,flowtype,parameter_HC)
%% DESSIMPLIFIEDHEATINGCOIL
%
%
%% description
% ============================input==============================
% air_in: a struct, which contains
%                         air_in.flowrate: volume flow at the air side;[m3/s]
%                         air_in.temp:     temperature at the air side
%                         inlet;[¡æ]£»
% water_in: a struct, which contains
%                         water_in.flowrate:volume flow at the water
%                         side;[m3/s];
%                         water_in.temp: temperature at the water side
%                         inlet; [¡æ]£»
% parameter_HC: a struct, which contains
%                          parameter_HC.cp: specific heat value for air and
%                          water respectively;[J/(kg.K)];
%                          parameter_HC.density: density for air and water
%                          respectively;[kg/m3];
%                          parameter_HC.UA: U-factor times area value;[W/¡æ]
% ============================output===============================
% air_out: a struct, which contains
%                         air_out.flowrate: volume flow at the air side;[m3/s]
%                         air_out.temp:     temperature at the air side
%                         inlet;[¡æ]£»
% water_out: a struct, which contains
%                         water_out.flowrate:volume flow at the water
%                         side;[m3/s];
%                         water_out.temp: temperature at the water side
%                         inlet; [¡æ]£»
% heatflow: the total heat through heating coil;[W];
%% equation

if nargin<5
    parameter_HC.cp=[1012 4200];
    parameter_HC.density=[1.29 1000];
    parameter_HC.resistance=[5e5 1e6];
end

%%%!!! INITIALIZATION
% initialization for the PARAMETERS
resistance_air=parameter_HC.resistance(1);
resistance_water=parameter_HC.resistance(2);

cp_air=parameter_HC.cp(1);
cp_water=parameter_HC.cp(2);
density_air=parameter_HC.density(1);
density_water=parameter_HC.density(2);

% initialization for the INPUT
flowrate_air_in=air_in.flowrate;
temp_air_in=air_in.temp;
RH_in=air_in.RH;
[W_in]=PsychWFuTdbRH(temp_air_in,RH_in);

flowrate_water_in=water_in.flowrate;
temp_water_in=water_in.temp;

%%% !!! CHECK FOR THE INLET CONDITION
if temp_air_in>temp_water_in
   flowrate_water_in=0;
end
massflow_air=flowrate_air_in*density_air;
massflow_water=flowrate_water_in*density_water;

%%%!!! EPSILON~NTU MODEL EQUATION
cap_air=cp_air*massflow_air;
cap_water=cp_water*massflow_water;
cap_min=min(cap_air,cap_water);
cap_max=max(cap_air,cap_water);

z=cap_min./cap_max;                              % capacitance flow ratio;

NTU=CoilUA./cap_min;
eta=NTU.^(-0.22);
if flowtype==0 % counter flow
    epsilon=(1-exp(-NTU.*(1-z)))./(1-z.*exp(-NTU.*(1-z)));
else           % cross flow
    epsilon=1-exp((exp(-NTU.*z.*eta)-1)./(z.*eta));
end

%%% !!! OUTLET CONDITION
temp_air_out=temp_air_in+epsilon*cap_min.*(temp_water_in-temp_air_in)./cap_air;
temp_water_out=temp_water_in-cap_air.*(temp_air_out-temp_air_in)./cap_water;
flowrate_air_out=flowrate_air_in;
flowrate_water_out=flowrate_water_in;
W_out=W_in;
[RH_out]=PsychRHFuTdbW(temp_air_out,W_out);

heatflow=cap_water.*(temp_water_out-temp_water_in);

% pressure calculation
DeltaP_air=resistance_air*massflow_air.^2;
DeltaP_water=resistance_water*massflow_water.^2;

%%%% !!! OUTPUT
air_out.temp=temp_air_out;
air_out.RH=RH_out;
air_out.flowrate=flowrate_air_out;
air_out.pressure_loss=DeltaP_air;

water_out.temp=temp_water_out;
water_out.flowrate=flowrate_water_out;
water_out.pressure_loss=DeltaP_water;

end

