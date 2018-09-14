function [air_supply,flowrate]=Zone(load_sensible,load_latent,T_supply,air_zone,parameter_zone)
%% Calculate the required air flow in a specific zone under design condition.
% This model considers the sensible heat only.

%% Description
%===============================input=========================
% load_sensible: a column vector, describes sensible load in the zone; [W]
% load_latent:   a column vector, describes lentent load in the zone;[W]
% design_deltaT: a column vector, describes the design temperature
%                difference in HVAC system;[¡æ]
% air_zone:      a struct, describes the design air condition in the zone;
%                air_zone.temp:design temperature in the zone;  [¡æ]
%                air_zone.RH; design relative humidty in the zone;[--]
% parameter_zone: a struct, describes the zone parameters;
%                 parameter_zone.density: air density; [kg/m3];

%==============================output==========================
% flowrate: required air flow ;[m3/s];

%% Equation
if nargin<5
    parameter_zone.density=1.293;
end

row=size(load_sensible,1);

%@@@@@@@@ Initialize the INPUT
% air input
T_return=air_zone.temp;
RH_return=air_zone.RH;
W_return=PsychWFuTdbRH(T_return,RH_return);

% air density
density=parameter_zone.density;

% air specific heat

cp_air_return=PsychCpAirFuTdbW(T_return,W_return);
cp_air_supply=cp_air_return;

% LoadTol : load tolerance
LoadTol=1e-6;
%@@@@@@@@ Initialize the LOCAL VARIABLES
massflow=zeros(row,1);
W_supply=zeros(row,1);

%@@@@@@@@ Calculate the model
k=1;
while k<=row
    if abs(load_sensible(k))>=LoadTol
        % required supply air massflow to remove sensible heat;
        massflow(k)=load_sensible(k)./(cp_air_return(k).*T_return(k)-cp_air_supply(k).*T_supply(k));
        % supply air humidity ratio
        W_supply(k)=W_return(k)-load_latent(k)./(2501000*massflow(k));
    else
        % DO NOT supply air!
        massflow(k)=0 ;
        W_supply(k)=W_return(k);
    end
    k=k+1;
end
% required supply air volume flow rate;
flowrate=massflow./density;

RH_supply=PsychRHFuTdbW(T_supply,W_supply);

%@@@@@@@@ Model OUTPUT
air_supply.temp=T_supply;
air_supply.RH=RH_supply;
air_supply.W=W_supply;
