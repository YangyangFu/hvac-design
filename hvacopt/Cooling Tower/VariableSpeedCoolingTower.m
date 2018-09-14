function [power_fan,flowrate_air_out,temp_water_out,pressure_out,heatflow]=VariableSpeedCoolingTower(air_in_CT,water_in_CT,pressure_in,temp_water_out_set,coefficient,parameter_CT,parameter_fan)
%% application
%The input object CoolingTower:VariableSpeed provides models for variable
%speed towers that is based on empirical curve fits of manufacturer¡¯s
%performance data or field measurements. The user specifies tower
%performance at design conditions, and empirical curves are used to
%determine the approach temperature and fan power at off-design conditions.
%The user defines tower performance by entering the inlet air wet-bulb
%temperature, tower range, and tower approach temperature at the design
%conditions. The corresponding water flow rate, air flow rate, and fan
%power must also be specified. The model will account for tower performance
%in the ¡°free convection¡± regime, when the tower fan is off but the water
%pump remains on and heat transfer still occurs (albeit at a low level).
%Basin heater operation and makeup water usage (due to evaporation, drift,
%and blowdown) are also modeled. The cooling tower seeks to maintain the
%temperature of the water exiting the cooling tower at (or below) a
%setpoint. The setpoint temperature is defined by the field ¡°Condenser Loop
%Temperature Setpoint schedule or reference¡± for the CondenserLoop object.
%The model simulates the outlet water temperature in four successive steps:
%1. The model first determines the tower outlet water temperature with the
%tower fan operating at maximum speed. If the outlet water temperature is
%above the setpoint temperature, the fan runs at maximum speed.
%2. If the outlet water temperature with maximum fan speed is below the setpoint
%temperature, then the model next determines the impact of ¡°free
%convection¡± (water flowing through tower with fan off). If the exiting
%water temperature based on ¡°free convection¡± is at or below the setpoint,
%then the tower fan is not turned on.
%3.If the outlet water temperature remains above the setpoint after ¡°free convection¡± is modeled, then the
%tower fan is turned on at the minimum fan speed (minimum air flow rate
%ratio) to reduce the leaving water temperature. If the outlet water
%temperature is below the setpoint at minimum fan speed, the tower fan is
%cycled on and off to maintain the outlet water setpoint temperature.
%4.If the outlet water temperature remains above the setpoint after minimum fan
%speed is modeled, then the tower fan is turned on and the model determines
%the required air flow rate and corresponding fan speed to meet the desired
%setpoint temperature.

%% model description
% The variable speed tower model utilizes user-defined tower performance at
% design conditions along with empirical curves to determine tower heat
% rejection and fan power at off-design conditions. The following sections
% describe how each of these tower performance areas is modeled.
%
% The air outlet contidion is not considered.

%============================input===================
% air_in_CT:       a struct representing air side input in the cooling tower, which
%                  is composed of inlet air temperature and relative humidity placed in air_CT.air;
% water_in_CT:     a struct representing water side input in the cooling tower,
%                  which is composed of inlet water temperature [¡æ] and flowrate [m3/s];
% temp_water_out_set: the outlet water temperature setpoint in the cooling
%                     tower.
% coefficient:     a struct representing the coefficients of cooling
%                  tower. The element coefficient.CoeffCoolingTower is a
%                  35-by-1 matrix representing cooling tower performance
%                  cureve.
% parameter_CT:    parameter_CT(1).fraction_freeconv represent air flow rate ratio in free convection regime,default 0.125;
%                  parameter_CT(1).FRair(1) describes the minimum FRair, default 0.2;
%                  parameter_CT(1).FRair(2) describes the maximum FRair, default 1.0;
%                  parameter_CT(1).nominal represent the nominal inlet
%                  water flowrate;[m3/s];
%                  parameter_CT(2).nominal represents the nominal inlet air
%                  flowrate;[m3/s];
% parameter_fan:   parameter_fan(1).PQcoefficient is the coefficients for fan power-flowrate curve;
%                  parameter_fan(1).nominal is a 1-by-4 matrix, describing
%                  pressure rise, nominal flowrate,nominal power and motor
%                  efficiency;
%                  parameter_fan(1).air is a 1-by-2 matrix,representing air
%                  specific heat and density, respectively;
%                  parameter_fan(1).fraction representing the fraction of
%                  motor heat transfered to the air.

%============================output=======================================
% power_fan:
% flowrate_air_out:
% temp_air_out:
% temp_water_out:

%% model equation
if nargin<7
    parameter_fan(1).PQcoefficient=[0.0015302446 0.0052080574 1.1086242 -0.11635563 0.000];   % a;
    parameter_fan(1).nominal=[3000 1.6435 5500 0.87];                                         % nominal information;
    parameter_fan(1).air=[1012 1.6435];                                                       % air feature;
    parameter_fan(1).fraction=1;
end

if nargin<6
    parameter_CT(1).fraction_freeconv=0.125;
    parameter_CT(1).FRair=[0.2,1];
    parameter_CT(1).nominal=[0.0015,1.6435];
    parameter_CT(1).water=[4200,1000];
end

if nargin<5
    load coefficient;
end

temp_air_in=air_in_CT.temp;
RH_air_in=air_in_CT.RH;

temp_water_in=water_in_CT.temp;
flowrate_water_in=water_in_CT.flowrate;
density_water=parameter_CT(1).water(:,2);
cp_water=parameter_CT(1).water(:,1);
massflow_water_in=flowrate_water_in*density_water;


global CoeffCoolingTower
CoeffCoolingTower=coefficient.CoeffCoolingTower;

fraction_freeconv=parameter_CT(1).fraction_freeconv;
FRair_min=parameter_CT(1).FRair(1);
FRair_max=parameter_CT(1).FRair(2);
nominal_flowrate_water=parameter_CT(1).nominal(1);
nominal_flowrate_air=parameter_CT(1).nominal(2);



%% 1£ºFan at MAXimum speed



[row]=size(temp_air_in,1);


FRair=ones(row,1);
Twb=PsychTwbFuTdbW(temp_air_in,PsychWFuTdbRH(temp_air_in,RH_air_in));     % [¡æ]
FRwater=flowrate_water_in/nominal_flowrate_water;                         % [m3/s]
x0=Twb+2;
fun=@VariableCoolingTowerEquation;
x1=fzero(fun,x0);
temp_water_out_fanMAX=x1;

fanPLR=zeros(row,1);
flowrate_air_in=zeros(row,1);
flowrate_air_out=zeros(row,1);
temp_water_out=zeros(row,1);
power_fan=zeros(row,1);
temp_water_out_fanMIN=zeros(row,1);
Tr1=zeros(row,1);


for i=1:row
    if temp_water_out_fanMAX(i,1)>=temp_water_out_set(i,1)
        fanPLR(i,1)=1;
        FRair(i,1)=1;
        flowrate_air_in(i,1)=FRair(i,1)*nominal_flowrate_air;
        
        temperature_inlet.temperature=temp_air_in(i:1);
        temperature_inlet.RH=RH_air_in(i,1);
        [power]=VariableSpeedFan(flowrate_air_in(i,1),temperature_inlet,parameter_fan);
        power_fan(i,1)=fanPLR(i,1)*power;
        temp_water_out(i,1)=temp_water_out_fanMAX(i,1);
        
    else
        %% 2: free convection
        temp_water_out_fanOFF=zeros(row,1);
        temp_water_out_fanOFF(i,1)=temp_water_in(i,1)-fraction_freeconv*(temp_water_in(i,1)-temp_water_out_fanMAX(i,1));
        if temp_water_out_fanOFF(i,1)<temp_water_out_set(i,1)
            fanPLR(i,1)=0;
            FRair(i,1)=fraction_freeconv;
            flowrate_air_in(i,1)=FRair(i,1)*nominal_flowrate_air;
            temperature_inlet.temperature=temp_air_in(i,1);
            temperature_inlet.RH=RH_air_in(i,1);
            [power]=VariableSpeedFan(flowrate_air_in(i,1),temperature_inlet,parameter_fan);
            power_fan(i,1)=fanPLR(i,1).*power;
            temp_water_out(i,1)=temp_water_out_fanOFF(i,1);
            flowrate_air_out(i,1)=flowrate_air_in(i,1);
        else
            FRair(i,1)=FRair_min;                                          % minimum air flowrate defined by the user
            fun=@VariableCoolingTowerEquation;
            x0=[0 50];
            x1=fzero(fun,x0);
            
            temp_water_out_fanMIN(i,1)=x1(i,1);
            %% 3. fan at minimum speed
            if temp_water_out_fanMIN(i,1)<temp_water_out_set(i,1)
                temp_water_out(i,1)=temp_water_out_fanMIN(i,1);
                
                fanPLR(i,1)=(temp_water_out_fanOFF(i,1)-temp_water_out_set(i,1))./(temp_water_out_fanOFF(i,1)-temp_water_out_fanMIN(i,1));
                flowrate_air_in(i,1)=FRair(i,1)*nominal_flowrate_air;
                temperature_inlet.temperature=temp_air_in(i,1);
                temperature_inlet.RH=RH_air_in(i,1);
                [power]=VariableSpeedFan(flowrate_air_in(i,1),temperature_inlet,parameter_fan);
                power_fan(i,1)=fanPLR(i,1)*power;
                flowrate_air_out(i,1)=flowrate_air_in(i,1);
            else
                %% 4. iteration for FRair
                temp_water_out(i,1)=temp_water_out_set(i,1);
                Tr1(i,1)=temp_water_in(i,1)-temp_water_out(i,1);
                temp_approach=zeros(row,1);
                temp_approach(i,1)=temp_water_out(i,1)-Twb(i,1);
               % iteration for FRair 
                x2=(FRair_min+FRair_max)/2;
                fun=@VariableCoolingTower;
                x1=fzero(fun,x2);
                
                FRair(i,1)=x1(i,1);
                fanPLR(i,1)=1;
                flowrate_air_in(i,1)=FRair(i,1)*nominal_flowrate_air;
                temperature_inlet.temperature=temp_air_in(i,1);
                temperature_inlet.RH=RH_air_in(i,1);
                [power]=VariableSpeedFan(flowrate_air_in(i,1),temperature_inlet,parameter_fan);
                power_fan(i,1)=fanPLR(i,1)*power;
                flowrate_air_out(i,1)=flowrate_air_in(i,1);
            end
            
        end
        
    end
end

heatflow=massflow_water_in.*cp_water.*(temp_water_in-temp_water_out);
pressure_out=pressure_in-80000;



    function y=VariableCoolingTowerEquation(temp_water_out)
        Coeff=CoeffCoolingTower;
        Tr=temp_water_in-temp_water_out;
        y=Coeff(1) + Coeff(2).*FRair + Coeff(3).*(FRair).^2 + ...
            Coeff(4).*(FRair).^3 + Coeff(5).*FRwater + Coeff(6).*FRair.*FRwater + ...
            Coeff(7).*(FRair).^2.*FRwater + Coeff(8).*(FRwater).^2 + Coeff(9).*FRair.*(FRwater).^2 +...
            Coeff(10).*(FRwater).^3 + Coeff(11).*Twb + Coeff(12).*FRair.*Twb + ...
            Coeff(13).*(FRair).^2.*Twb + Coeff(14).*FRwater.*Twb +...
            Coeff(15).*FRair.*FRwater.*Twb + Coeff(16).*(FRwater).^2.*Twb +...
            Coeff(17).*(Twb).^2 + Coeff(18).*FRair.*(Twb).^2 +...
            Coeff(19).*FRwater.*(Twb).^2 + Coeff(20).*(Twb).^3 + Coeff(21).*Tr +...
            Coeff(22).*FRair.*Tr + Coeff(23).*(FRair).^2.*Tr +...
            Coeff(24).*FRwater.*Tr + Coeff(25).*FRair.*FRwater.*Tr +...
            Coeff(26).*(FRwater).^2.*Tr + Coeff(27).*Twb.*Tr +...
            Coeff(28).*FRair.*Twb.*Tr + Coeff(29).*FRwater.*Twb.*Tr +...
            Coeff(30).*(Twb).^2.*Tr + Coeff(31).*(Tr).^2 + Coeff(32).*FRair.*(Tr).^2 +...
            Coeff(33).*FRwater.*(Tr).^2 + Coeff(34).*Twb.*(Tr).^2 + Coeff(35).*(Tr).^3+Twb-temp_water_out;
    end

    function y=VariableCoolingTower(FRair)
        Coeff=CoeffCoolingTower;
        Tr=temp_water_in-temp_water_out;
        y=  Coeff(1)  +Coeff(2)*FRair+ Coeff(3)*(FRair).^2 + ...
            Coeff(4).*(FRair).^3 + Coeff(5).*FRwater + Coeff(6).*FRair.*FRwater + ...
            Coeff(7).*(FRair).^2.*FRwater + Coeff(8).*(FRwater).^2 + Coeff(9).*FRair.*(FRwater).^2 +...
            Coeff(10).*(FRwater).^3 + Coeff(11).*Twb + Coeff(12).*FRair.*Twb + ...
            Coeff(13).*(FRair).^2.*Twb + Coeff(14).*FRwater.*Twb +...
            Coeff(15).*FRair.*FRwater.*Twb + Coeff(16).*(FRwater).^2.*Twb +...
            Coeff(17).*(Twb).^2 + Coeff(18).*FRair.*(Twb).^2 +...
            Coeff(19).*FRwater.*(Twb).^2 + Coeff(20).*(Twb).^3 + Coeff(21).*Tr +...
            Coeff(22).*FRair.*Tr + Coeff(23).*(FRair).^2.*Tr +...
            Coeff(24).*FRwater.*Tr + Coeff(25).*FRair.*FRwater.*Tr +...
            Coeff(26).*(FRwater).^2.*Tr + Coeff(27).*Twb.*Tr +...
            Coeff(28).*FRair.*Twb.*Tr + Coeff(29).*FRwater.*Twb.*Tr +...
            Coeff(30).*(Twb).^2.*Tr + Coeff(31).*(Tr).^2 + Coeff(32).*FRair.*(Tr).^2 +...
            Coeff(33).*FRwater.*(Tr).^2 + Coeff(34).*Twb.*(Tr).^2 + Coeff(35).*(Tr).^3-temp_approach;
    end

end




















