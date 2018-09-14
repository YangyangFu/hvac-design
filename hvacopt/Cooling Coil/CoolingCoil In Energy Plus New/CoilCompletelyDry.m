function [OutletAirTemp,OutletAirHumRat,OutletWaterTemp,Q]=CoilCompletelyDry (...
    InletAirMassFlowRate,AirTempIn,InletAirHumRat,WaterTempIn,InletWaterMassFlowRate,CoilUA,HeatExchType)
%
%! FUNCTION INFORMATION:
%! AUTHOR         Fuyangyang
%! DATE WRITTEN   Jan 2015
%! MODIFIED       na
%! RE-ENGINEERED  na
%
%          ! PURPOSE OF THIS FUNCTION:
%          ! Calculate the performance of a sensible air-liquid heat exchanger.  Calculated
%          ! results include outlet air temperature and humidity, outlet water temperature,
%          ! and heat transfer rate.
%
%
%          ! METHODOLOGY EMPLOYED:
%          ! Models coil using effectiveness-NTU model.
%
%          ! REFERENCES:
%          ! Kays, W.M. and A.L. London.  1964,Compact Heat Exchangers, 2nd Edition,
%          ! New York: McGraw-Hill.
%
%
%! FUNCTION ARGUMENT DEFINITIONS:
%
%       WaterTempIn;  %! Entering water temperature
%       AirTempIn;    %! Entering air dry bulb temperature
%       CoilUA;       %! Overall heat transfer coefficient
%
%! FUNCTION LOCAL VARIABLE DECLARATIONS:
%       OutletWaterTemp   ! Leaving water temperature
%       OutletAirTemp     ! Leaving air dry bulb temperature
%       OutletAirHumRat   ! Leaving air humidity ratio
%       Q                 ! Heat transfer rate
%       CapacitanceAir    ! Air-side capacity rate(W/C)
%       CapacitanceWater  ! Water-side capacity rate(W/C)
%       AirMassFlow
%       WaterMassFlowRate
%       Cp



AirMassFlow       =InletAirMassFlowRate;
WaterMassFlowRate =InletWaterMassFlowRate;


%! Calculate air and water capacity rates
CapacitanceAir = AirMassFlow.*  ...
    PsychCpAirFuTdbW(AirTempIn,InletAirHumRat);
%! Water Capacity Rate
Cp =  PsychCpWater(WaterTempIn);

CapacitanceWater = WaterMassFlowRate.* Cp;

%! Determine the air and water outlet conditions

[OutletWaterTemp,OutletAirTemp]=CoilOutletStreamCondition( CapacitanceWater,WaterTempIn,CapacitanceAir,AirTempIn,CoilUA,HeatExchType);

%! Calculate the total and sensible heat transfer rate both are equal in case of Dry Coil
Q=CapacitanceAir.*(AirTempIn-OutletAirTemp);

%! Outlet humidity is equal to Inlet Humidity because its a dry coil
OutletAirHumRat = InletAirHumRat;

return
end

