function [temp_leaving_chw,temp_leaving_cw,deltaP_eva,deltaP_con,power_chiller,heatflow_eva,COP,PLR]=...
    SimDesEleChiller(temp_entering_chw,temp_entering_cw,temp_SP, parameter_chiller)
%% electric chiller model based on condenser entering temperature

%% model discription:
% The chiller model uses user-supplied performance information at reference conditions
% along with three performance curves (curve objects) for cooling capacity and efficiency
% to determine chiller operation at off-reference conditions.
% The three performance curves are:
% 1) Cooling Capacity Function of Temperature Curve
% 2) Energy Input to Cooling Output Ratio Function of Temperature Curve
% 3) Energy Input to Cooling Output Ratio Function of Part Load Ratio Curve

%% Nomenclature
%================================input===============================
% temp_entering_chw: entering chilled water temperature;[��]��
% temp_entering_cw:  entering condenser water temperature;[��]��
% pressure_enter_chw: entering chilled water pressure; [Pa];
% pressure_enter_cw:  entering condenser water pressure;[Pa];
% temp_SP:           leaving chilled water set point temperature;[��];
% parameter_chiller: a struct, which contains:
%                parameter_chiller.coefficient: three matrixes for
%                    fitting cueves' coefficients, which represent
%                    CapFTemp,EIRFTemp and EIRFPLR sequentially;
%                parameter_chiller.nominal: three matrixes for
%                    chiller's nominal information, which represent
%                    capacity,COP and motor efficiency sequentially;
%                parameter_chiller.flowrate:two matrixs for flowrate in
%                    evaporator and condenser sequentially;
%                parameter_PLR: three matrixes for PLR information,
%                    which represent minimum PLR,maximum PLR and minimum
%                    unloading PLR;
%                parameter_density:two matrixes for water density in
%                    evaporator and condenser;
%                parameter_cp:two matrixes for water specific heat in
%                    evaporator and condenser;
%
%=============================output==================================
% temp_leaving_chw: leaving chilled water temperature; [��]
% temp_leaving_cw:  leaving condenser water temperature;[��]
% deltaP_eva��      pressure loss in evaporator; [Pa];
% deltaP_con:       pressure loss in condenser;   [Pa];
% power_chiller:    power consumption;[w];

%% Initialization


if nargin<4
    parameter_chiller(1).coefficient=[0.257896 0.389016*10^(-1) -0.217080*10^(-3) 0.468684*10^(-1) -0.94284*10^(-3) -0.343440*10^(-3)];
    parameter_chiller(2).coefficient=[0.933884 -0.582120*10^(-1) 0.450036*10^(-2) 0.243000*10^(-2) 0.486000*10^(-3) -0.121500*10^(-2)];
    parameter_chiller(3).coefficient=[0.222903 0.313387 0.463710];
    parameter_chiller(1).nominal=2813000;
    parameter_chiller(2).nominal=5.58;
    parameter_chiller(3).nominal=0.97;
    parameter_chiller(1).flowrate=0.134444;
    parameter_chiller(2).flowrate=0.161944;
    parameter_chiller(1).PLR=0.15;
    parameter_chiller(2).PLR=1.2;
    parameter_chiller(3).PLR=0.25;
    parameter_chiller(1).resistance=6;    % resistance factor, whose range can be [1 10]
    parameter_chiller(2).resistance=4;
    parameter_chiller(1).density=999.4;   % water density at 10 �� in evaporator;
    parameter_chiller(2).density=995.5;   % water density at 30 �� in condenser;
    parameter_chiller(1).cp=4191.4;       % water specific heat at 10 �棻
    parameter_chiller(2).cp=4178.4;       % water specific heat at 30 �棻
end

coefficient_CapFT=parameter_chiller(1).coefficient;
coefficient_EIRFTemp=parameter_chiller(2).coefficient;
coefficient_EIRFPLR=parameter_chiller(3).coefficient;

capacity_nominal=parameter_chiller(1).nominal;
COP_nominal=parameter_chiller(2).nominal;
efficiency_motor=parameter_chiller(3).nominal;

flowrate_eva=parameter_chiller(1).flowrate;
flowrate_con=parameter_chiller(2).flowrate;
density_eva=parameter_chiller(1).density;
density_con=parameter_chiller(2).density;
massflow_eva=density_eva*flowrate_eva;
massflow_con=density_con*flowrate_con;

PLR_MIN=parameter_chiller(1).PLR;
PLR_MAX=parameter_chiller(2).PLR;
PLR_MIN_unloading=parameter_chiller(3).PLR;

cp_water_eva=parameter_chiller(1).cp;
cp_water_con=parameter_chiller(2).cp;

resistance_eva=parameter_chiller(1).resistance;
resistance_con=parameter_chiller(2).resistance;

% coefficient for CAPFTemp
A_CAPFT=coefficient_CapFT(1,1);
B_CAPFT=coefficient_CapFT(1,2);
C_CAPFT=coefficient_CapFT(1,3);
D_CAPFT=coefficient_CapFT(1,4);
E_CAPFT=coefficient_CapFT(1,5);
F_CAPFT=coefficient_CapFT(1,6);
% coefficient for EIRFTemp
A_EIRFT=coefficient_EIRFTemp(1,1);
B_EIRFT=coefficient_EIRFTemp(1,2);
C_EIRFT=coefficient_EIRFTemp(1,3);
D_EIRFT=coefficient_EIRFTemp(1,4);
E_EIRFT=coefficient_EIRFTemp(1,5);
F_EIRFT=coefficient_EIRFTemp(1,6);
% coefficient for EIRFPLR
A_EIRPLR=coefficient_EIRFPLR(1,1);
B_EIRPLR=coefficient_EIRFPLR(1,2);
C_EIRPLR=coefficient_EIRFPLR(1,3);




%% calculate simply the leaving chilled water temperature.
temp_leaving_chw=temp_SP;

%% heatflow in evaporator;
heatflow_eva=massflow_eva*cp_water_eva*(temp_entering_chw-temp_SP);
heatflow_eva=max(0,heatflow_eva);


%% Determine the PLR (part load ratio).
cap_available=capacity_nominal.*(A_CAPFT+B_CAPFT*temp_leaving_chw+C_CAPFT*temp_leaving_chw.^2 ...
    +D_CAPFT*temp_entering_cw+E_CAPFT*temp_entering_cw.^2+...
    F_CAPFT*temp_leaving_chw.*temp_entering_cw);

PLR=max(0,min((heatflow_eva./cap_available),PLR_MAX));

%% The on-off cycling ratio of the chiller is calculated,when the chiller part load ratio is less than the minimum part load ratio
cycling_ratio=min((PLR./PLR_MIN),1);

PLR=max(PLR,PLR_MIN_unloading);

%% The amount of false loading on the chiller is calculated.
heatflow_falseloading=cap_available.*PLR.*cycling_ratio-heatflow_eva;

%% The electrical power consumption for the chiller compressor is calculated.
% calculate the EIR as a function of temperature;
EIRFT=A_EIRFT+B_EIRFT*temp_leaving_chw+C_EIRFT*temp_leaving_chw.^2+...
    D_EIRFT*temp_entering_cw+E_EIRFT*temp_entering_cw.^2+...
    F_EIRFT*temp_leaving_chw.*temp_entering_cw;

% calculate the EIR as a function of PLR;
EIRPLR=A_EIRPLR+B_EIRPLR*PLR+C_EIRPLR*PLR.^2;

% calculate the power consumption and COP;
power_chiller=cap_available.*EIRFT.*EIRPLR.*cycling_ratio/COP_nominal;

COP=heatflow_eva./power_chiller;

%% Condenser water loop: heat rejection and temperature
% heat rejection
heatflow_con=power_chiller*efficiency_motor+heatflow_eva+heatflow_falseloading;
% water temperature leaving  the condenser;
temp_leaving_cw=temp_entering_cw+heatflow_con./(massflow_con*cp_water_con);
%% Pressure calculation
% pressure drop through evaporator and condenser is assumed to be
% constant,80 kPa.
deltaP_eva=resistance_eva.*massflow_eva.^2;
deltaP_con=resistance_con.*massflow_con.^2;



