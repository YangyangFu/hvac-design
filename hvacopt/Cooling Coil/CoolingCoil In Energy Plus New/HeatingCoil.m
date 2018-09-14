function [OutletAir,OutletWater,TotWaterHeatingCoilRate]=...
    HeatingCoil(InletAir,InletWater,UADesign,...
    Schedule,HeatExchType,DesInletAir,DesInletWater,Parameter)
%
if nargin<9   
   Parameter.AirResis=5;
   Parameter.WaterResis=5;
end




%%%%%%%%%%! Initilize the Input

InletAirTemp=InletAir.temp;
InletAirFlowRate=InletAir.flowrate;
%!Calculate Temperature Dew Point at operating conditions.
InletAirHumRat=InletAir.W;
AirDewPointTemp= InletAir.DewPTemp;

InletWaterTemp=InletWater.temp;
InletWaterFlowRate=InletWater.flowrate;

RhoAir=RhoAirFuTdbWP(InletAirTemp,InletAirHumRat);
InletAirMassFlowRate=RhoAir.*InletAirFlowRate;

InletWaterMassFlowRate=RhoWater(InletWaterTemp).*InletWaterFlowRate;

%%%%%%%%%%! Initialize the Nominal information
DesInletAirTemp=DesInletAir.temp;
DesInletAirHumRat=DesInletAir.W;

DesAirVolFlowRate=DesInletAir.flowrate;
DesAirMassFlowRate=RhoAirFuTdbWP(DesInletAirTemp,DesInletAirHumRat)*DesAirVolFlowRate;

DesInletWaterTemp=DesInletWater.temp;
DesWaterFlowRate=DesInletWater.flowrate;

DesWaterMassFlowRate=RhoWater(DesInletWaterTemp)*DesWaterFlowRate;


%%%%%%%%%%! Initialize the Parameter
AirResistance=Parameter.AirResis;
WaterResistance=Parameter.WaterResis;

% Initialize the Local Variables
row=size(InletAirTemp,1);

OutletAirTemp=zeros(row,1);         %! Outlet air temperature at operating condition
OutletAirHumRat=zeros(row,1);       %! Outlet air humidity ratio at operating condition
OutletWaterTemp=zeros(row,1);       %! Outlet water temperature at operating condtitons
TotWaterHeatingCoilRate=zeros(row,1);%!Total heating rate,which has a negtive value.[-W]



% Calculate the Varible UA based on inlet water and air mass flowrate;
WaterCoilType='HeatingCoil';
[~,~,UACoilTotal]=CalcVariableUA(...
    InletAirMassFlowRate,InletAirTemp,InletWaterMassFlowRate,InletWaterTemp,...
    DesAirMassFlowRate,DesInletAirTemp,DesWaterMassFlowRate,DesInletWaterTemp,WaterCoilType,UADesign );

k=1;
while k<=row
    %! If Coil is Scheduled ON then do the simulation
    if((Schedule(k)~=0.0)&&(InletWaterMassFlowRate(k) > 0.0) && (InletAirMassFlowRate(k)>0))
        
        %!Calculate the leaving conditions and performance of dry coil
                    [OutletAirTemp(k),OutletAirHumRat(k),OutletWaterTemp(k),TotWaterCoilLoad]=CoilCompletelyDry (...
                        InletAirMassFlowRate(k),InletAirTemp(k),InletAirHumRat(k),...
                        InletWaterTemp(k),InletWaterMassFlowRate(k),UACoilTotal(k),HeatExchType);
                    
                    TotWaterHeatingCoilRate(k) = TotWaterCoilLoad;

    else
        
       %!If both mass flow rates are zero, set outputs to inputs and return
        OutletWaterTemp(k) = InletWaterTemp(k);
        OutletAirTemp(k)   = InletAirTemp(k);
        OutletAirHumRat(k) = InletAirHumRat(k);
        TotWaterHeatingCoilRate(k)=0.0;

    end
    k=k+1;
end
% Calculate the output 
OutletWaterFlowRate =InletWaterFlowRate;
OutletAirFlowRate = InletAirFlowRate;
OutletAirEnthalpy = PsychHFuTdbW(OutletAirTemp,OutletAirHumRat);
OutletAirRH=PsychRHFuTdbW(OutletAirTemp,OutletAirHumRat);
OutletAirWetBulbTemp=PsychTwbFuTdbW(OutletAirTemp,OutletAirHumRat);
AirDeltaP=AirResistance*InletAirMassFlowRate.^2;
WaterDeltaP=WaterResistance*InletWaterMassFlowRate.^2;

OutletAir.temp=OutletAirTemp;
OutletAir.RH=OutletAirRH;
OutletAir.W=OutletAirHumRat;
OutletAir.H=OutletAirEnthalpy;
OutletAir.Twb=OutletAirWetBulbTemp;
OutletAir.flowrate=OutletAirFlowRate;
OutletAir.pressure_loss=AirDeltaP;

OutletWater.temp=OutletWaterTemp;
OutletWater.flowrate=OutletWaterFlowRate;
OutletWater.pressure_loss=WaterDeltaP;
return
end
