function [OutletAirTemp,OutletAirHumRat,OutletWaterTemp,...
    TotWaterCoilLoad,SenWaterCoilLoad,SurfAreaWetFraction,AirInletCoilSurfTemp]...
    =CoilCompletelyWet (InletAirMassFlowRate,AirTempIn,InletAirHumRat,...
    InletWaterMassFlowRate,WaterTempIn,UAExternalTotal,UAInternalTotal,HeatExchType)
%
%          ! FUNCTION INFORMATION:
%          ! AUTHOR         Fu Yangyang
%          ! DATE WRITTEN   Jan 2015
%          ! MODIFIED       na
%          ! RE-ENGINEERED  na
%
%          ! PURPOSE OF THIS FUNCTION:
%          ! Calculate the performance of a cooling coil when the external fin surface is
%          ! complete wet.  Results include outlet air temperature and humidity,
%          ! outlet water temperature, sensible and total cooling capacities, and the wet
%          ! fraction of the air-side surface area.
%
%          ! METHODOLOGY EMPLOYED:
%          ! Models coil as counterflow heat exchanger. Approximates saturated air enthalpy as
%          ! a linear function of temperature
%          ! TRNSYS.  1990.  A Transient System Simulation Program: Reference Manual.
%          ! Solar Energy Laboratory, Univ. Wisconsin Madison, pp. 4.6.8-1 - 4.6.8-12.
%          ! Threlkeld, J.L.  1970.  Thermal Environmental Engineering, 2nd Edition,
%          ! Englewood Cliffs: Prentice-Hall,Inc. pp. 254-270.
%          ! Coil Uses Enthalpy Based Heat Transfer Coefficents and converts them to
%          ! convential UA values. Intermediate value of fictitious Cp is defined. This follow
%          ! the same procedure followed in the Design Calculation of the Coil. See the node in
%          ! the one time calculation for design condition.
%
%          ! REFERENCES:
%          ! Elmahdy, A.H. and Mitalas, G.P.  1977."A Simple Model for Cooling and
%          ! Dehumidifying Coils for Use In Calculating Energy Requirements for Buildings,"
%          ! ASHRAE Transactions,Vol.83 Part 2, pp. 103-117.
%
%! FUNCTION ARGUMENT DEFINITIONS:
%      Integer, intent(in) :: CoilNum               ! Number of Coil
%      REAL(r64), intent(in) :: WaterTempIn         ! Water temperature IN to this function (C)
%      REAL(r64), intent(in) :: AirTempIn           ! Air dry bulb temperature IN to this function(C)
%      REAL(r64), intent(in) :: AirHumRat           ! Air Humidity Ratio IN to this funcation (C)
%      REAL(r64), intent(in) :: UAInternalTotal     ! Internal overall heat transfer coefficient(W/m2 C)
%      REAL(r64), intent(in) :: UAExternalTotal     ! External overall heat transfer coefficient(W/m2 C)
%      REAL(r64)     ::  OutletWaterTemp       ! Leaving water temperature (C)
%      REAL(r64)     ::  OutletAirTemp         ! Leaving air dry bulb temperature(C)
%      REAL(r64)     ::  OutletAirHumRat       ! Leaving air humidity ratio
%      REAL(r64)     ::  TotWaterCoilLoad      ! Total heat transfer rate(W)
%      REAL(r64)     ::  SenWaterCoilLoad      ! Sensible heat transfer rate(W)
%      REAL(r64)     ::  AirInletCoilSurfTemp  ! Surface temperature at air entrance(C)
%      REAL(r64)     ::  SurfAreaWetFraction   ! Fraction of surface area wet
%      INTEGER, INTENT(IN) :: FanOpMode        ! fan operating mode
%      REAL(r64),    INTENT(IN) :: PartLoadRatio  ! part-load ratio of heating coil
%
%! FUNCTION LOCAL VARIABLE DECLARATIONS:
%      REAL(r64) AirSideResist                    ! Air-side resistance to heat transfer(m2 C/W)
%      REAL(r64) WaterSideResist                  ! Liquid-side resistance to heat transfer(m2 C/W)
%      REAL(r64) EnteringAirDewPt                 ! Entering air dew point(C)
%      REAL(r64) UACoilTotalEnth                  ! Overall enthalpy heat transfer coefficient(kg/s)
%      REAL(r64) CapacityRateAirWet               ! Air-side capacity rate(kg/s)
%      REAL(r64) CapacityRateWaterWet             ! Liquid-side capacity rate(kg/s)
%      REAL(r64) ResistRatio                      ! Ratio of resistances
%      REAL(r64) EnthAirOutlet                    ! Outlet air enthalpy
%      REAL(r64) EnthSatAirInletWaterTemp         ! Saturated enthalpy of air at entering water temperature(J/kg)
%      REAL(r64) EnthSatAirOutletWaterTemp        ! Saturated enthalpy of air at exit water temperature(J/kg)
%      REAL(r64) EnthSatAirCoilSurfaceEntryTemp   ! Saturated enthalpy of air at entering surface temperature(J/kg)
%      REAL(r64) EnthSatAirCoilSurfaceExitTemp    ! Saturated enthalpy of air at exit surface temperature(J/kg)
%      REAL(r64) EnthAirInlet                     ! Enthalpy of air at inlet
%      REAL(r64) IntermediateCpSat                ! Coefficient for equation below(J/kg C)
%                                            ! EnthSat1-EnthSat2 = IntermediateCpSat*(TSat1-TSat2)
%                                            ! (all water and surface temperatures are
%                                            ! related to saturated air enthalpies for
%                                            ! wet surface heat transfer calculations)
%      REAL(r64),Parameter::SmallNo = 1.d-9       ! smallNo used in place of 0
%      REAL(r64) :: AirMassFlow
%      REAL(r64) :: WaterMassFlowRate
%      REAL(r64) :: Cp



SurfAreaWetFraction = 1;
SmallNo = 1e-9;       %! smallNo used in place of 0


AirSideResist = 1/max(UAExternalTotal,SmallNo);
WaterSideResist = 1/max(UAInternalTotal,SmallNo);



AirMassFlow       = InletAirMassFlowRate;
WaterMassFlowRate = InletWaterMassFlowRate;



%! Calculate enthalpies of entering air and water

%! Enthalpy of air at inlet to the coil
EnthAirInlet= PsychHFuTdbW(AirTempIn,InletAirHumRat );

%! Saturation Enthalpy of Air at inlet water temperature
EnthSatAirInletWaterTemp=PsychHFuTdbRH(WaterTempIn,1);

%! Estimate IntermediateCpSat using entering air dewpoint and water temperature
EnteringAirDewPt = PsychTdpFuTdbRH(AirTempIn,PsychRHFuTdbW(AirTempIn,InletAirHumRat));

%! An intermediate value of Specific heat . EnthSat1-EnthSat2 = IntermediateCpSat*(TSat1-TSat2)
IntermediateCpSat=(PsychHFuTdbRH(EnteringAirDewPt,1)- ...
    EnthSatAirInletWaterTemp)/(EnteringAirDewPt-WaterTempIn);

%! Determine air and water enthalpy outlet conditions by modeling
%! coil as counterflow enthalpy heat exchanger
UACoilTotalEnth = 1./(IntermediateCpSat*WaterSideResist+AirSideResist*PsychCpAirFuTdbW(AirTempIn,0.0));
CapacityRateAirWet = AirMassFlow;
Cp =  PsychCpWater(WaterTempIn);
CapacityRateWaterWet = WaterMassFlowRate.*(Cp./IntermediateCpSat);

[EnthAirOutlet,EnthSatAirOutletWaterTemp]=CoilOutletStreamCondition(CapacityRateAirWet,EnthAirInlet,CapacityRateWaterWet,...
    EnthSatAirInletWaterTemp,UACoilTotalEnth,HeatExchType);
%! Calculate entering and leaving external surface conditions from
%! air and water conditions and the ratio of resistances
ResistRatio=(WaterSideResist)/(WaterSideResist+  ...
    PsychCpAirFuTdbW(AirTempIn,0)./IntermediateCpSat.*AirSideResist);
EnthSatAirCoilSurfaceEntryTemp = EnthSatAirOutletWaterTemp + ResistRatio* ...
    (EnthAirInlet-EnthSatAirOutletWaterTemp);
EnthSatAirCoilSurfaceExitTemp = EnthSatAirInletWaterTemp + ResistRatio.* ...
    (EnthAirOutlet-EnthSatAirInletWaterTemp);

%! Calculate Coil Surface Temperature at air entry to the coil
AirInletCoilSurfTemp=  PsychTdbFuHRH(EnthSatAirCoilSurfaceEntryTemp,1);

%! Calculate outlet air temperature and humidity from enthalpies and surface conditions.
TotWaterCoilLoad = InletAirMassFlowRate*(EnthAirInlet-EnthAirOutlet);
OutletWaterTemp = WaterTempIn+TotWaterCoilLoad./max(InletWaterMassFlowRate,SmallNo)./Cp;

%! Calculates out put variable for  the completely wet coil
[OutletAirTemp,OutletAirHumRat,SenWaterCoilLoad]=WetCoilOutletCondition(AirMassFlow,AirTempIn,InletAirHumRat,...
    EnthAirInlet,EnthAirOutlet,UAExternalTotal);

return
end
