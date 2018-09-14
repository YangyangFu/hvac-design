function [air_out,water_out,heatflow_total,epsilon]=DesSimplifiedCC_NTU(air_in,water_in,temp_SP,CoilUA,flowtype,parameter_CC)
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
    parameter_CC.cp=[1012 4200];
    parameter_CC.density=[1.29 1000];
    parameter_CC.air_nominal=[27,0.5]; % air side nominal inlet condition
    parameter_CC.water_nominal=[7,5];  % water side nominal condition
    parameter_CC.resistance=[5e3 1e4];
end

% media physical information
cp_air=parameter_CC.cp(1);
cp_water=parameter_CC.cp(2);
density_air=parameter_CC.density(1);
density_water=parameter_CC.density(2);


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
    
    air_in_cc.temp=air_in.temp(k);
    air_in_cc.RH=air_in.RH(k);
    air_in_cc.flowrate=air_in.flowrate(k);
    
    water_in_cc.temp=water_in.temp(k);
    
    temp_set=temp_SP(k);
    
    fun=@CCEquation;
    x0=density_air*cp_air*air_in.flowrate(k).*abs(air_in.temp(k)-temp_SP(k))./(density_water*cp_water*5);
    options=optimoptions('fsolve','Algorithm','levenberg-marquardt');
    FLW=fsolve(fun,x0,options);
    
    % FLW=fzero(fun,x0);
    
    % AIR SIDE
    temp_out_air(k)=air_out_cc.temp;
    RH_out_air(k)=air_out_cc.RH;
    flowrate_air(k)=air_out_cc.flowrate;
    delta_pressure_air(k)=air_out_cc.pressure_loss;
    
    % WATER SIDE
    temp_out_water(k)=water_out_cc.temp;
    flowrate_water(k)=FLW;
    delta_pressure_water(k)=water_out_cc.pressure_loss;
    
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
        water_in_cc.flowrate=water_flow;
        [air_out_cc,water_out_cc,heatflow_TOT,epsilon]=SimplifiedCoolingCoil_NTU(air_in_cc,water_in_cc,CoilUA,flowtype,parameter_CC);
        y=air_out_cc.temp-temp_set;
    end
end
