function [air_out,water_out,heatflow_total]=DesSimplifiedHC_NTU(air_in,water_in,temp_SP,CoilUA,flowtype,parameter_HC)
%% This model calculates the water flowrate in cooling coil from given air outlet temperature.The model is based on the SimplifiedCoolingCoil_NTU.


%% DESCRIPTION
%=============================input=======================
% air_in: a struct,which contains air inlet information;
%                  air_in.temp:     temperature at air inlet;[¡æ]
%                  air_in.RH:       relative humidity;[---]
%                  air_in.flowrate; air flowrate at inlet;[m3/s];
%
% water_in: a struct, which contains water inlet information:
%                  water_in.temp:     temperature at water inlet;[¡æ]
%
% temp_SP:  a column vector, which describes the outlet air temperature setpoint.[¡æ]
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

%% MODEL

if nargin<5
    flowtype=0;
end

if nargin<6
    parameter_HC.cp=[1012 4200];
    parameter_HC.density=[1.29 1000];
    parameter_HC.resistance=[5e5 1e6];
end

% media physical information
cp_air=parameter_HC.cp(1);
cp_water=parameter_HC.cp(2);
density_air=parameter_HC.density(1);
density_water=parameter_HC.density(2);

% solve the equation in SimplifiedCoolingCoil_NTU
row=size(air_in.temp,1);

%%% !!!! initializtion for the output
% AIR SIDE
temp_out_air=zeros(row,1);
RH_out_air=zeros(row,1);
flowrate_air=zeros(row,1);
delta_pressure_air=zeros(row,1);
% WATER SIDE
temp_out_water=zeros(row,1);
flowrate_water=zeros(row,1);
delta_pressure_water=zeros(row,1);
% HEATFLOW
heatflow_total=zeros(row,1);

%%% !!! solve in sequences
k=1;
while k<=row
    
    air_in_hc.temp=air_in.temp(k);
    air_in_hc.RH=air_in.RH(k);
    air_in_hc.flowrate=air_in.flowrate(k);
    
    water_in_hc.temp=water_in.temp(k);
    
    temp_set=temp_SP(k);
    
    fun=@CCEquation;
    x0=density_air*cp_air*air_in.flowrate(k).*abs(air_in.temp(k)-temp_SP(k))./(density_water*cp_water*5);
    FLW=fzero(fun,x0);
    
    % AIR SIDE
    temp_out_air(k)=air_out_hc.temp;
    RH_out_air(k)=air_out_hc.RH;
    flowrate_air(k)=air_out_hc.flowrate;
    delta_pressure_air(k)=air_out_hc.pressure_loss;
    
    % WATER SIDE
    temp_out_water(k)=water_out_hc.temp;
    flowrate_water(k)=FLW;
    delta_pressure_water(k)=water_out_hc.pressure_loss;
    
    % TOTAL HEATFLOW
    heatflow_total(k)=heatflow_TOT;
    
    k=k+1;
end

%%% !!! output for this model
% AIR SIDE
air_out.temp=temp_out_air;
air_out.RH=RH_out_air;
air_out.flowrate=flowrate_air;
air_out.pressure_loss=delta_pressure_air;
% WATER SIDE
water_out.temp=temp_out_water;
water_out.flowrate=flowrate_water;
water_out.pressure_loss=delta_pressure_water;


    function  y=CCEquation(water_flow)
        water_in_hc.flowrate=water_flow;
        [air_out_hc,water_out_hc,heatflow_TOT]=SimplifiedHeatingCoil_NTU(air_in_hc,water_in_hc,CoilUA,flowtype,parameter_HC);
        y=air_out_hc.temp-temp_set;
    end
end
