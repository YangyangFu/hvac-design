function [AirOutletTemp,WaterOutletTemp,SHR]=CoolingCoil_SHR
%% application
% The SHR(sensible heat ratio) method is based on using the dry-bulb
% temperature difference as the driving potential, and the total heat
% transfer under wet conditions is calculated using the SHR. If TS, the
% surface tempeature of teh coil, happens to be above the dew point of the
% inlet air, the dry coil model is used;to predict Tao. Otherwise, the SHR
% model is used to calculate Tao for the wet condition.
%% description
% ================================input=======================
% ka: Air-side convective heat transfer parameter;
% ================================output========================


%% equation

% determine the type of cooling coil: dry, wet or partially wet;

RH=0.5;
ka=2000;
kw=20000;
Rw=0.0001;
AirCp=1012;
WaerCp=4200;
AirInletTemp=24;
WaterInletTemp=7;

AirMassFlow=1.935; %density_air*flowrate_air;
WaterMassFlow=2.64;%density_water*flowrate_water;

a=ka*AirMassFlow.^0.8;              
b=kw*WaterMassFlow.^0.8;

AirCap=AirCp*AirMassFlow;
WaterCap=WaerCp*WaterMassFlow;

MinCap=min(AirCap,WaterCap);
MaxCap=max(AirCap,WaterCap);

z=MinCap./MaxCap; 

bf=exp(-ka*AirMassFlow.^0.8./AirCap);
[AirInletEnthalpy,~,AirInletDewTemp]=PsychTdbRH(AirInletTemp,RH);

%******************************
%******   Dry Coil  **********
%******************************
UA=1./(1./a+1./b+Rw);
NTU=UA./MinCap;
epsilon=(1-exp(-NTU.*(1-z)))./(1-z.*exp(-NTU.*(1-z)));
HeatTrans=epsilon.*MinCap.*(AirInletTemp-WaterInletTemp);

WaterOutletTemp=WaterInletTemp+HeatTrans./WaterCap;

AirOutletTemp=AirInletTemp-HeatTrans./AirCap;

CoilSurfaceTemp=(AirOutletTemp-bf.*AirInletTemp)./(1-bf);

Dry=(CoilSurfaceTemp>AirInletDewTemp);
SHR=1;
%**************************************
%**********   Wet Coil  **************
%**************************************
if (~Dry)
    % ³õÖµ
HeatTransInit=HeatTrans;
fun=@CoolingCoil_SHR_Equation;
HeatTrans=fzero(fun,HeatTransInit);

WaterOutletTemp=HeatTrans./WaterCap+WaterInletTemp;    
end  

function y=CoolingCoil_SHR_Equation(HeatTransIter)
AirOutletEnthalpy=AirInletEnthalpy-HeatTransIter./AirMassFlow;
CoilSurfaceEnthalpy=(AirOutletEnthalpy-bf.*AirInletEnthalpy)./(1-bf);
CoilSurfaceTemp=PsychTdbFuHRH(CoilSurfaceEnthalpy,1);
AirOutletTemp=bf.*(AirInletTemp-CoilSurfaceTemp)+CoilSurfaceTemp;

SHR=AirCap.*(AirInletTemp-AirOutletTemp)./(AirMassFlow.*(AirInletEnthalpy-AirOutletEnthalpy));

UA=1./(SHR./a+1./b+Rw);
NTU=UA./MinCap;
epsilon=(1-exp(-NTU.*(1-z)))./(1-z.*exp(-NTU.*(1-z)));
y=epsilon.*MinCap.*(AirInletTemp-WaterInletTemp)./SHR-HeatTransIter;
end
end