function [temp_leaving_chw,temp_leaving_cw,pressure_leave_chw,pressure_leave_cw,power_chiller,COP,PLR]...
    =EleChillerEIR(temp_entering_chw,temp_entering_cw,pressure_enter_chw,pressure_enter_cw,temp_SP,...
    load, parameter_chiller)
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
% temp_entering_chw: entering chilled water temperature;[¡æ]£»
% temp_entering_cw:  entering condenser water temperature;[¡æ]£»
% pressure_enter_chw: entering chilled water pressure; [Pa];
% pressure_enter_cw:  entering condenser water pressure;[Pa]; 
% temp_SP:           leaving chilled water set point temperature;[¡æ];
% load:              cooling ratio handled by chiller plant;[w];
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
% temp_leaving_chw: leaving chilled water temperature; [¡æ]
% temp_leaving_cw:  leaving condenser water temperature;[¡æ]
% pressure_leave_chw: leaving chilled water pressure; [Pa];
% pressure_leave_cw:  leaving condenser water pressure;[Pa];
% power_chiller:    power consumption;[w];

%% Initialization


if nargin<7
   parameter_chiller(1).coefficient=[0.257896 0.389016*10^(-1) -0.217080*10^(-3) 0.468684*10^(-1) -0.94284*10^(-3) -0.343440*10^(-3)];
   parameter_chiller(2).coefficient=[0.933884 -0.582120*10^(-1) 0.450036*10^(-2) 0.243000*10^(-2) 0.486000*10^(-3) -0.121500*10^(-2)];
   parameter_chiller(3).coefficient=[0.222903 0.313387 0.463710];
   parameter_chiller(1).nominal=25000;
   parameter_chiller(2).nominal=2.75;
   parameter_chiller(3).nominal=1;
   parameter_chiller(1).flowrate=0.001075;
   parameter_chiller(2).flowrate=0.001345;
   parameter_chiller(1).PLR=0.15;
   parameter_chiller(2).PLR=1.2;
   parameter_chiller(3).PLR=0.25; 
   parameter_chiller(1).density=999.4;   % water density at 10 ¡æ in evaporator;
   parameter_chiller(2).density=995.5;   % water density at 30 ¡æ in condenser;
   parameter_chiller(1).cp=4191.4;       % water specific heat at 10 ¡æ£»
   parameter_chiller(2).cp=4178.4;       % water specific heat at 30 ¡æ£»
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
              D_EIRPLR=coefficient_EIRFPLR(1,4);
% calculates the evaporator heat transfer rate required to bring the
% entering chilled water temperature down to the leaving chilled water
% setpoint temperature;
   cap_required=massflow_eva*cp_water_eva*(temp_entering_chw-temp_SP);
% heatflow in evaporator;
    heatflow_eva=min(load,cap_required);
    
%% Iteration for leaving chilled water temperature.
row=size(load,1);
x0=temp_SP;
[temp_leaving_chw,n]=iterate1(x0);

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
EIRPLR=A_EIRPLR+B_EIRPLR*PLR+C_EIRPLR*PLR.^2+D_EIRPLR*PLR.^3;

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
pressure_leave_chw=pressure_enter_chw-80000; 
pressure_leave_cw=pressure_enter_cw-80000;

%% Iteration function
% iteration algorithm function 
function [x1,n]=iterate1(x)
  x1=CapFTemp(x);
  n=1;
  while (norm(x1-x)>=10^(-6))&&(n<=10^6)
    x=x1;
    x1=CapFTemp(x);
    n=n+1;
  end
end
% equation for solution
function y=CapFTemp(temp_leaving_chw)
    
    % available capacity at off-reference condition;
    CAPFT=A_CAPFT+B_CAPFT*temp_leaving_chw+C_CAPFT*temp_leaving_chw.^2 ...
    +D_CAPFT*temp_entering_cw+E_CAPFT*temp_entering_cw.^2+...
    F_CAPFT*temp_leaving_chw.*temp_entering_cw;

    cap_available=CAPFT*capacity_nominal;  
   % calculate leaving chilled water temperature ;
   for i=1:row
    if heatflow_eva(i)<=cap_available(i)
        % if heatflow in evaporator is less than available capacity, the
        % leaving chilled water temperature is set to the SetPoint value;
        y(i,:)=temp_SP(i);
    else
        % if heatflow in evaporator is larger than available capacity, the
        % leaving chilled water temperature is calculated using available
        % capacity;
        y(i,:)=temp_entering_chw(i)-cap_available(i)./(massflow_eva*cp_water_eva);
    end
   end
end
end
