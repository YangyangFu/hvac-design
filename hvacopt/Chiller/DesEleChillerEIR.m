function [EvaOutlet,ConOutlet,Power,HeatEva,COP,PLR,EconomicCost]=DesEleChillerEIR...
    (temp_entering_chw,temp_entering_cw,temp_SP,NumON,schedule,ParameterChiller,SizingParameter)
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
% deltaP_eva£º      pressure loss in evaporator; [Pa];
% deltaP_con:       pressure loss in condenser;   [Pa];
% power_chiller:    power consumption;[w];
%% Initialization


if nargin<6
    ParameterChiller(1).coefficient=[0.257896 0.389016*10^(-1) -0.217080*10^(-3) 0.468684*10^(-1) -0.94284*10^(-3) -0.343440*10^(-3)];
    ParameterChiller(2).coefficient=[0.933884 -0.582120*10^(-1) 0.450036*10^(-2) 0.243000*10^(-2) 0.486000*10^(-3) -0.121500*10^(-2)];
    ParameterChiller(3).coefficient=[0.222903 0.313387 0.463710];
    ParameterChiller(1).nominal=2813000;
    ParameterChiller(2).nominal=5.58;
    ParameterChiller(3).nominal=0.97;
    ParameterChiller(1).flowrate=0.134444;
    ParameterChiller(2).flowrate=0.161944;
    ParameterChiller(1).PLR=0.15;
    ParameterChiller(2).PLR=1.2;
    ParameterChiller(3).PLR=0.25;
    ParameterChiller(1).resistance=6;    % resistance factor, whose range can be [1 10]
    ParameterChiller(2).resistance=4;
    ParameterChiller(1).density=999.4;   % water density at 10 ¡æ in evaporator;
    ParameterChiller(2).density=995.5;   % water density at 30 ¡æ in condenser;
    ParameterChiller(1).cp=4191.4;       % water specific heat at 10 ¡æ£»
    ParameterChiller(2).cp=4178.4;       % water specific heat at 30 ¡æ£»
end
if  nargin<7
   SizingParameter.DesignPressure=1.0*1e6;% 1 MPa;
   SizingParameter.NumONMax=2;
end

% chiller operation parameter
coefficient_CapFT=ParameterChiller(1).coefficient;
coefficient_EIRFTemp=ParameterChiller(2).coefficient;
coefficient_EIRFPLR=ParameterChiller(3).coefficient;

capacity_nominal=ParameterChiller(1).nominal;
COP_nominal=ParameterChiller(2).nominal;
efficiency_motor=ParameterChiller(3).nominal;

flowrate_eva_max=ParameterChiller(1).flowrate;
flowrate_con_max=ParameterChiller(2).flowrate;
density_eva=ParameterChiller(1).density;
density_con=ParameterChiller(2).density;
massflow_eva_max=density_eva*flowrate_eva_max;
massflow_con_max=density_con*flowrate_con_max;

PLR_MIN=ParameterChiller(1).PLR;
PLR_MAX=ParameterChiller(2).PLR;
PLR_MIN_unloading=ParameterChiller(3).PLR;

cp_water_eva=ParameterChiller(1).cp;
cp_water_con=ParameterChiller(2).cp;

resistance_eva=ParameterChiller(1).resistance;
resistance_con=ParameterChiller(2).resistance;

% chiller sizing parameter
DesignPressure= SizingParameter.DesignPressure;% 1 MPa;
NumONMax=SizingParameter.NumONMax;

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


%% Initialization
temp_leaving_chw=temp_SP;

row=size(temp_SP,1);

massflow_eva=zeros(row,1);

% initialize local varables
[heatflow_required,cap_available,PLR,COP] = deal(zeros(row,1));
[heatflow_eva,heatflow_con,DeltaTemp_eva,cycling_ratio] = deal(zeros(row,1));

[heatflow_falseloading,power_chiller,massflow_con,temp_leaving_cw]= deal(zeros(row,1));

[deltaP_eva,deltaP_con]=deal(zeros(row,1));

NumON=NumON.*schedule;

% Identical chiller plant in parallel model

k=1;
while k<=row
    
    if NumON(k)~=0
        
        %% Set the massflow in evaporator;
        % Constant flowrate in evaporator
        massflow_eva(k)=massflow_eva_max;
        
        %% heatflow MET BY SP control
        heatflow_required(k)=massflow_eva(k)*cp_water_eva*(temp_entering_chw(k)-temp_SP(k));
        heatflow_required(k)=max(0,heatflow_required(k));
        
       %% Set evaporator heat transfer rate
        heatflow_eva(k)=  max(heatflow_required(k),0);   
        
        %% Determine the PLR (part load ratio).
        cap_available(k)=capacity_nominal.*(A_CAPFT+B_CAPFT*temp_leaving_chw(k)+C_CAPFT*temp_leaving_chw(k).^2 ...
            +D_CAPFT*temp_entering_cw(k)+E_CAPFT*temp_entering_cw(k).^2+...
            F_CAPFT*temp_leaving_chw(k).*temp_entering_cw(k));
        
        if (cap_available(k)>0)
            PLR(k)=max(0,min((abs(heatflow_eva(k))./cap_available(k)),PLR_MAX));
        else
            PLR(k)=0;
        end
   
        
        %% Outlet temperature in Evaporator
        if (massflow_eva(k)~=0)
            DeltaTemp_eva(k)=heatflow_eva(k)./massflow_eva(k)/cp_water_eva;
        else
            DeltaTemp_eva(k)=0;
        end
        
        temp_leaving_chw(k)=temp_entering_chw(k)-DeltaTemp_eva(k);
        
        %% The on-off cycling ratio of the chiller is calculated,when the chiller part load ratio is less than the minimum part load ratio
        cycling_ratio(k)=min((PLR(k)./PLR_MIN),1);
        
        if (cap_available(k)>0)
            PLR(k)=max(PLR(k),PLR_MIN_unloading);
        else
            PLR(k)=0;
        end
        
        
        
        %% The amount of false loading on the chiller is calculated.
        heatflow_falseloading(k)=cap_available(k).*PLR(k).*cycling_ratio(k)-heatflow_eva(k);
        
        %% The electrical power consumption for the chiller compressor is calculated.
        % calculate the EIR as a function of temperature;
        EIRFT=A_EIRFT+B_EIRFT*temp_leaving_chw(k)+C_EIRFT*temp_leaving_chw(k).^2+...
            D_EIRFT*temp_entering_cw(k)+E_EIRFT*temp_entering_cw(k).^2+...
            F_EIRFT*temp_leaving_chw(k).*temp_entering_cw(k);
        
        % calculate the EIR as a function of PLR;
        EIRPLR=A_EIRPLR+B_EIRPLR*PLR(k)+C_EIRPLR*PLR(k).^2+D_EIRPLR*PLR(k).^3;
        
        % calculate the power consumption and COP;
%         if PLR(k)<0.5
%             power_chiller(k)=2*(cap_available(k).*EIRFT.*EIRPLR.*cycling_ratio(k)/COP_nominal);
%         end
            power_chiller(k)=(cap_available(k).*EIRFT.*EIRPLR.*cycling_ratio(k)/COP_nominal);
        
        COP(k)=heatflow_eva(k)./power_chiller(k);
        
        %% Condenser water loop: heat rejection and temperature
        % Condenser water flowrate
        massflow_con(k)=massflow_con_max;
        % heat rejection
        heatflow_con(k)=power_chiller(k)*efficiency_motor+heatflow_eva(k)+heatflow_falseloading(k);
        % water temperature leaving  the condenser;
        temp_leaving_cw(k)=temp_entering_cw(k)+heatflow_con(k)./(massflow_con(k)*cp_water_con);
        %% Pressure calculation
        % pressure drop through evaporator and condenser is assumed to be
        % constant,80 kPa.
        deltaP_eva(k)=resistance_eva.*massflow_eva(k).^2;
        deltaP_con(k)=resistance_con.*massflow_con(k).^2;
        
    else % NumON=0, all chillers are off!
        heatflow_falseloading(k);
        power_chiller(k)=0;
        massflow_con(k)=0;
        cycling_ratio(k)=0;
        PLR(k)=0;
        temp_leaving_cw(k)=temp_entering_cw(k);
        
        cap_available(k)=0;
        heatflow_eva(k)=0;
        heatflow_con(k)=0;
        DeltaTemp_eva(k)=0;
        temp_leaving_chw(k)=temp_entering_chw(k);       
        
        deltaP_eva(k)=0;
        deltaP_con(k)=0;
    end
    k=k+1;
end

%% Economical Model
CapacityforEco=max(capacity_nominal,100*3.517e3);
CapitalCostUSDBaseline= 0.129*CapacityforEco - 13585;
if DesignPressure==1.0*1e6
    CapitalCostUSD=CapitalCostUSDBaseline;
elseif DesignPressure==1.6*1e6
    CapitalCostUSD=CapitalCostUSDBaseline*(1+0.05);
elseif DesignPressure==2.0*1e6
    CapitalCostUSD=CapitalCostUSDBaseline*(1+0.11);
elseif DesignPressure==2.5*1e6
    CapitalCostUSD=CapitalCostUSDBaseline*(1+0.18);
elseif DesignPressure>2.5*1e6
    CapitalCostUSD=CapitalCostUSDBaseline*(1+0.26);
end

%% Output of parallel chiller
EvaOutlet.flowrate=NumON.*massflow_eva./density_eva;
EvaOutlet.temp=temp_leaving_chw;
EvaOutlet.pressure_loss=deltaP_eva;

ConOutlet.flowrate=NumON.*massflow_con./density_con;
ConOutlet.temp=temp_leaving_cw;
ConOutlet.pressure_loss=deltaP_con;

Power=power_chiller.*NumON;
HeatEva=heatflow_eva.*NumON;

EconomicCost.CapCost=CapitalCostUSD*NumONMax;


end



