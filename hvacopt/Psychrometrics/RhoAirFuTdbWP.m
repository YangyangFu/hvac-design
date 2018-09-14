function [RhoAir]=RhoAirFuTdbWP(Tdb,W,barom_pressure) 
%          ! FUNCTION INFORMATION:
%          !       AUTHOR         G. S. Wright
%          !       DATE WRITTEN   June 2, 1994
%          !       MODIFIED       na
%          !       RE-ENGINEERED  na
%
%          ! PURPOSE OF THIS FUNCTION:
%          ! This function provides density of air as a function of barometric
%          ! pressure, dry bulb temperature, and humidity ratio.
%
%          ! METHODOLOGY EMPLOYED:
%          ! ideal gas law
%          !    universal gas const for air 287 J/(kg K)
%          !    air/water molecular mass ratio 28.9645/18.01534
%
%          ! REFERENCES:
%          ! Wylan & Sontag, Fundamentals of Classical Thermodynamics.
%          ! ASHRAE handbook 1985 Fundamentals, Ch. 6, eqn. (6),(26)
%
%          ! USE STATEMENTS:
%          ! na
%
%! FUNCTION ARGUMENT DEFINITIONS:
%      REAL(r64), intent(in)  :: pb     ! barometric pressure (Pascals)
%      REAL(r64), intent(in)  :: tdb    ! dry bulb temperature (Celsius)
%      REAL(r64), intent(in)  :: dw      ! humidity ratio (kg water vapor/kg dry air)
%      character(len=*), intent(in), optional :: calledfrom  ! routine this function was called from (error messages) !unused1208
%      REAL(r64)         :: rhoair ! result=> density of air
%
%       REAL(r64) w  ! humidity ratio


if nargin<3
    barom_pressure=101325;
end

      KelvinConv=273.15;
      W=max(W,1.0e-5);
      RhoAir = barom_pressure./(287*(Tdb+KelvinConv).*(1+1.6077687*W));

end 