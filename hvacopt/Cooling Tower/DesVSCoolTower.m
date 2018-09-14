function [water_out_CT,power,heatflow,flowrate_air]=DesVSCoolTower(air_in_CT,water_in_CT,temp_water_out_SP,COEFF,parameter_CT,parameter_fan)

%%

%%

%% model equation
if nargin<6
    parameter_fan(1).PQcoefficient=[0.0015302446 0.0052080574 1.1086242 -0.11635563 0.000];   % a;
    parameter_fan(1).nominal=[3000 1.6435 5500 0.87];                                         % nominal information;
    parameter_fan(1).air=[1012 1.6435];                                                       % air feature;
    parameter_fan(1).fraction=1;
end

if nargin<5
    parameter_CT(1).fraction_freeconv=0.125;
    parameter_CT(1).FRair=[0.2,1];
    parameter_CT(1).nominal=[0.0015,1.6435];
    parameter_CT(1).water=[4200,1000];
end

if nargin<4
    COEFF=load('coefficient.mat');
end

temp_air_in=air_in_CT.temp;
RH_air_in=air_in_CT.RH;

temp_water_in=water_in_CT.temp;
flowrate_water_in=water_in_CT.flowrate;
density_water=parameter_CT(1).water(:,2);
cp_water=parameter_CT(1).water(:,1);
massflow_water_in=flowrate_water_in*density_water;

fraction_freeconv=parameter_CT(1).fraction_freeconv;
FRair_min=parameter_CT(1).FRair(1);
FRair_max=parameter_CT(1).FRair(2);
nominal_flowrate_water=parameter_CT(1).nominal(1);
nominal_flowrate_air=parameter_CT(1).nominal(2);




global CoeffCoolingTower
CoeffCoolingTower=COEFF.coefficient.CoeffCoolingTower;


[row]=size(temp_water_in,1);
temp_water_out_matrix=temp_water_out_SP;

FRwater_matrix=flowrate_water_in/nominal_flowrate_water;
Twb_matrix=PsychTwbFuTdbW(temp_air_in,PsychWFuTdbRH(temp_air_in,RH_air_in));
Tr_matrix=temp_water_in-temp_water_out_matrix;
T_approach_matrix=temp_water_out_matrix-Twb_matrix;
FRair_matrix=zeros(row,1);

ind=find(Tr_matrix<0);

if ~any(ind)
    k=1;
    while k<=row
        FRwater=FRwater_matrix(k);
        Twb=Twb_matrix(k);
        Tr=Tr_matrix(k);
        T_approach=T_approach_matrix(k);
        fun=@FRairEquation;
        x0=(FRair_min+FRair_max)/2;
        FRair=fzero(fun,x0);
        % If FRair is less than 0, then set the FRair to FRair_min
        if FRair<FRair_min
            FRair=FRair_min;
        end
        % if FRair is larger than FRair_max, then set the FRair to FRair_max;
        if FRair>FRair_max
            FRair=FRair_max;
        end
        
        FRair_matrix(k)=FRair;
        k=k+1;
    end
    
    flowrate_air=FRair_matrix.*nominal_flowrate_air;
    temperature_inlet.temperature=temp_air_in;
    temperature_inlet.RH=RH_air_in;
    [power]=VariableSpeedFan(flowrate_air,temperature_inlet,parameter_fan);
    % WATER SIDE OUTLET 
    water_out_CT.temp=temp_water_out_matrix;
    water_out_CT.flowrate=flowrate_water_in;
    % HEAT FLOW
    heatflow=massflow_water_in.*cp_water.*(temp_water_in-temp_water_out_matrix);
    
else
    error('MATLAB:DesVSCoolTower:Tr is negative');
end

    function y=FRairEquation(FRair)
        Coeff=CoeffCoolingTower;
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
            Coeff(33).*FRwater.*(Tr).^2 + Coeff(34).*Twb.*(Tr).^2 + Coeff(35).*(Tr).^3-T_approach;
    end
end