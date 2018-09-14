function [OutletAirTemp,OutletAirHumRat,SenWaterCoilLoad]=WetCoilOutletCondition(InletAirMassFlowRate,AirTempIn,InletAirHumRat,EnthAirInlet,EnthAirOutlet,UACoilExternal)
%! Subroutine for caculating outlet condition if coil is wet , for Cooling Coil
%          ! FUNCTION INFORMATION:
%          ! AUTHOR         FuYangyang
%          ! DATE WRITTEN   Jan 2015
%          ! MODIFIED       na
%          ! RE-ENGINEERED  na
%
%          ! PURPOSE OF THIS FUNCTION:
%          ! Calculate the leaving air temperature,the leaving air humidity ratio and the
%          ! sensible cooling capacity of wet cooling coil.
%
%          ! METHODOLOGY EMPLOYED:
%          ! Assumes condensate at uniform temperature.
%
%          ! REFERENCES:
%          ! Elmahdy, A.H. and Mitalas, G.P.  1977."A Simple Model for Cooling and
%          ! Dehumidifying Coils for Use In Calculating Energy Requirements for Buildings,"
%          ! ASHRAE Transactions,Vol.83 Part 2, pp. 103-117.
%
%          ! USE STATEMENTS:
%

          %! FUNCTION ARGUMENT DEFINITIONS:
%      Integer, intent(in) ::  CoilNum        !
%      REAL(r64), intent(in) :: AirTempIn      ! Entering air dry bulb temperature(C)
%      REAL(r64), intent(in) :: EnthAirInlet      ! Entering air enthalpy(J/kg)
%      REAL(r64), intent(in) :: EnthAirOutlet     ! Leaving air enthalpy(J/kg)
%      REAL(r64), intent(in) :: UACoilExternal    ! Heat transfer coefficient for external surface (W/C)
%      REAL(r64)        :: OutletAirTemp     ! Leaving air dry bulb temperature(C)
%      REAL(r64)        :: OutletAirHumRat   ! Leaving air humidity ratio
%      REAL(r64)        :: SenWaterCoilLoad  ! Sensible heat transfer rate(W)
%
          %! FUNCTION PARAMETER DEFINITIONS:
       SmallNo=1e-9 ;%! SmallNo value used in place of zero

          %! FUNCTION LOCAL VARIABLE DECLARATIONS:
%      REAL(r64) CapacitanceAir         ! Air capacity rate(W/C)
%      REAL(r64) NTU                    ! Number of heat transfer units
%      REAL(r64) effectiveness          ! Heat exchanger effectiveness
%      REAL(r64) EnthAirCondensateTemp  ! Saturated air enthalpy at temperature of condensate(J/kg)
%      REAL(r64) TempCondensation       ! Temperature of condensate(C)
%      REAL(r64) TempAirDewPoint        ! Temperature air dew point


          %! Determine the temperature effectiveness, assuming the temperature
          %! of the condensate is constant (MinimumCapacityStream/MaximumCapacityStream = 0) and the specific heat
          %! of moist air is constant
      CapacitanceAir = InletAirMassFlowRate*   ...
                                    PsychCpAirFuTdbW(AirTempIn,InletAirHumRat);


          %! Calculating NTU from UA and Capacitance.
      if (UACoilExternal > 0.00) 
        if (CapacitanceAir > 0.0) 
          NTU = UACoilExternal/CapacitanceAir;
        else
          NTU = 0.0;
        end
        effectiveness = 1.0 - exp(-NTU);
      else
        effectiveness = 0.0;
      end

          %! Calculate coil surface enthalpy and temperature at the exit
          %! of the wet part of the coil using the effectiveness relation
      effectiveness = max(effectiveness,SmallNo);
      EnthAirCondensateTemp = EnthAirInlet-(EnthAirInlet-EnthAirOutlet)/effectiveness;


        %! Calculate condensate temperature as the saturation temperature
        %! at given saturation enthalpy
      TempCondensation=  PsychTdbFuHRH(EnthAirCondensateTemp,1.0);

      TempAirDewPoint=PsychTdpFuTdbRH(AirTempIn,PsychRHFuTdbW(AirTempIn,InletAirHumRat));

      if((TempAirDewPoint-TempCondensation)>0.1)

           %! Calculate Outlet Air Temperature using effectivness
           OutletAirTemp = AirTempIn-(AirTempIn-TempCondensation)*effectiveness;
           %! Calculate Outlet air humidity ratio from PsyWFnTdbH routine
           OutletAirHumRat  = PsychWFuTdbH(OutletAirTemp,EnthAirOutlet);

      else
           OutletAirHumRat=InletAirHumRat;
           OutletAirTemp=PsychTdbFuHW(EnthAirOutlet,OutletAirHumRat);
      end

        %! Calculate Sensible Coil Load
      SenWaterCoilLoad = CapacitanceAir*(AirTempIn-OutletAirTemp);

     return
end