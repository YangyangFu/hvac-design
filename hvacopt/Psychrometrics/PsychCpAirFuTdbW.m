function [CpAir]=PsychCpAirFuTdbW(Tdb,W) 
%
%          ! FUNCTION INFORMATION:
%          !       AUTHOR         J. C. VanderZee
%          !       DATE WRITTEN   Feb. 1994
%          !       MODIFIED       na
%          !       RE-ENGINEERED  na
%
%          ! PURPOSE OF THIS FUNCTION:
%          ! This function provides the heat capacity of air {J/kg-C} as function of humidity ratio.
%
%          ! METHODOLOGY EMPLOYED:
%          ! take numerical derivative of PsyHFnTdbW function
%
%          ! REFERENCES:
%          ! see PsyHFnTdbW ref. to ASHRAE Fundamentals
%          ! USAGE:  cpa = PsyCpAirFnWTdb(w,T)
%
%          ! USE STATEMENTS:
%          ! na
%
%
%          ! FUNCTION ARGUMENT DEFINITIONS:
%      REAL(r64), intent(in)  :: dw    ! humidity ratio {kg/kg-dry-air}
%      REAL(r64), intent(in)  :: T    ! input temperature {Celsius}
%      character(len=*), intent(in), optional :: calledfrom  ! routine this function was called from (error messages)
%      REAL(r64)         :: cpa  ! result => heat capacity of air {J/kg-C}
%
%          ! FUNCTION LOCAL VARIABLE DECLARATIONS:
%      REAL(r64) h1  ! PsyHFnTdbW result of input parameters
%      REAL(r64) tt  ! input temperature (T) + .1
%      REAL(r64) h2  ! PsyHFnTdbW result of input humidity ratio and tt
%      REAL(r64) w  ! humidity ratio

      W=max(W,1.0e-5);
      h1 = PsychHFuTdbW(Tdb,W);
      tt = Tdb + 0.1;
      h2 = PsychHFuTdbW(tt,W);
      CpAir = (h2-h1)/0.1;

 
end 