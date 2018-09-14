function [ flowrate_air_in,water_out,pressure_drop_water,heatflow,power,epsilon_air] = IdealDesVSCoolingTower_NTU(air_in_CT,water_in_CT,Schedule,temp_water_SP,NumCellON,type_CT,parameter_Fan,parameter_CT)
%COOLINGTOWER 此处显示有关此函数的摘要
%
if nargin<6
    type_CT=1;
end

if nargin<7  
    parameter_Fan.MaxAirFlowRate=81.4;  %! Maximum massflow rate;[m3/s]
    parameter_Fan.MotorRatedOutPwr=18.5;  %! Motor rated power;[w]
    parameter_Fan.RhoAir=1.29;             %! Air density;[kg/m3]
    parameter_Fan.CpAir=1012;

end

if nargin<8  
    parameter_CT(1).water=4200;
    parameter_CT(2).water=1000;
    parameter_CT(1).resistance=5;                %%%% NEED REVISED!!!!!
    parameter_CT(1).parameter=2.3;
    parameter_CT(2).parameter=-0.7;

end

% initialization for parameters
c=parameter_CT(1).parameter; % [0.5 5]
n=parameter_CT(2).parameter; %[-0.35 -1.1]
density_air=parameter_Fan.RhoAir;
density_water=parameter_CT(2).water;
cp_air=parameter_Fan.CpAir;
cp_water=parameter_CT(1).water;
resistance=parameter_CT(1).resistance;

NominalFanPowerCell=parameter_Fan.MotorRatedOutPwr;
NominalAirFlowRateCell=parameter_Fan.MaxAirFlowRate;

% model input
temp_air_in=air_in_CT.temp;
RH_air_in=air_in_CT.RH;
flowrate_water_in=water_in_CT.flowrate;
temp_water_in=water_in_CT.temp;
temp_water_out=temp_water_SP;

NumCellON=NumCellON.*Schedule;

row=size(temp_air_in,1);

% initializtion for outputs
h_air_out_cell_matrix=zeros(row,1);
w_air_out_cell_matrix=zeros(row,1);
epsilon_matrix=zeros(row,1);
heatflow_cell_matrix=zeros(row,1);
flowrate_air_in_cell_matrix=zeros(row,1);
massflow_water_loss_matrix=zeros(row,1);

power_cell=zeros(row,1);

pressure_drop_water=zeros(row,1);


k=1;
while k<=row
    
    
    temp_water_in_cell_matrix=temp_water_in;
    flowrate_water_in_cell_matrix=flowrate_water_in(k)/NumCellON(k);
    h_air_in=PsychTdbRH(temp_air_in,RH_air_in);
    w_air_in=PsychWFuTdbRH(temp_air_in,RH_air_in);
    hs_water_in=PsychTdbRH(temp_water_in_cell_matrix,1.00);
    hs_water_out=PsychTdbRH(temp_water_out,1.00);
    
    % loop through all tower cell
    if (NumCellON(k)>0)&&(flowrate_water_in(k)>0)
        % individual cell analysis
        
        % initialization for the equation
        hs_water_in_cell=hs_water_in(k);
        hs_water_out_cell=hs_water_out(k);
        temp_water_in_cell=temp_water_in_cell_matrix(k);
        temp_water_out_cell=temp_water_out(k);
        flowrate_water_in_cell=flowrate_water_in_cell_matrix;
        h_air_in_cell=h_air_in(k);
        w_air_in_cell=w_air_in(k);
        
        % solve the equation with fzero
        fun=@CoolingTowerEquation;
        flowrate_air_init=(flowrate_water_in_cell.*density_water.*cp_water.*(temp_water_in_cell-temp_water_out_cell))./(16*density_air.*cp_air);
        flowrate_air_in_cell=fzero(fun,flowrate_air_init);
        
        % the output of individual cell
        h_air_out_cell_matrix(k,1)=h_air_out;
        w_air_out_cell_matrix(k,1)=w_air_out;
        flowrate_air_in_cell_matrix(k,1)=flowrate_air_in_cell;
        heatflow_cell_matrix(k,1)=heatflow_cell;
        epsilon_matrix(k,1)=epsilon_air;
        massflow_water_loss_matrix(k,1)=massflow_water_loss_cell;
        
        % power by the fan
        power_cell(k)=NominalFanPowerCell*(flowrate_air_in_cell./NominalAirFlowRateCell)^3;        
        
        %power_cell(k)=exp(-2.3084+6.3769*(log(60*35.31466672*flowrate_air_in_cell)-10.5)/2); % 35.31466672是cfm转化为m3的转换因子；
        
        % pressure drop in each cell
        pressure_drop_water(k)=resistance*(flowrate_water_in(k)*density_water).^2;
        
    elseif (NumCellON(k)==0)||(flowrate_water_in(k)<1e-6)
        power_cell(k)=0;
        heatflow_cell_matrix(k)=0;
        flowrate_air_in_cell_matrix(k)=0;
        pressure_drop_water(k)=0;
    end
    k=k+1;
end

% All identical tower cells analysis
power=NumCellON.*power_cell;
heatflow=NumCellON.*heatflow_cell_matrix;
flowrate_air_in=NumCellON.*flowrate_air_in_cell_matrix;

flowrate_water_out=flowrate_water_in;
%%%% water side output
water_out.temp=temp_water_out;
water_out.flowrate=flowrate_water_out;
%%%% don't care about the air side output


    function y=CoolingTowerEquation(flowrate_air_in_cell)
        
        cp_s=(hs_water_in_cell-hs_water_out_cell)./(temp_water_in_cell-temp_water_out_cell);
        massflow_air_in_cell=flowrate_air_in_cell*density_air;
        massflow_water_in_cell=flowrate_water_in_cell*density_water;
        r=massflow_air_in_cell.*cp_s./(massflow_water_in_cell.*cp_water);
        NTU=c*(massflow_water_in_cell./massflow_air_in_cell).^(n+1);
        
        if type_CT==1                                         % counterflow cooling tower;
            epsilon_air=(1-exp(-NTU*(1-r)))./(1-r*exp(-NTU*(1-r)));
        else                                                  % cross flow cooling tower
            epsilon_air=1./r.*(1-exp(-r.*(1-exp(-NTU))));
        end
        
        h_air_out=h_air_in_cell+epsilon_air*(hs_water_in_cell-h_air_in_cell);
        hs_water_effective=h_air_in_cell+(h_air_out-h_air_in_cell)./(1-exp(-NTU));
        ws_water_effective=PsychWFuTdbH(PsychTdbFuHRH(hs_water_effective,1),hs_water_effective);
        w_air_out=ws_water_effective+(w_air_in_cell-ws_water_effective).*exp(-NTU);
        massflow_water_loss_cell=massflow_air_in_cell.*(w_air_out-w_air_in_cell);
        massflow_water_out=massflow_water_in_cell-massflow_water_loss_cell;
        heatflow_cell=epsilon_air.*massflow_air_in_cell.*(hs_water_in_cell-h_air_in_cell);
        y=massflow_water_in_cell.*cp_water.*temp_water_in_cell-massflow_water_out.*cp_water.*temp_water_out_cell-heatflow_cell;
    end
end

