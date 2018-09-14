function [ Rho ] = RhoWater( Tdb )
%
%          !       AUTHOR         FUYANGYANG
%          !       DATE WRITTEN   January 2015
%
%          ! PURPOSE OF THIS FUNCTION:
%          ! This function provides the density of water at a specific temperature.
%
%          ! METHODOLOGY EMPLOYED:
%          !     Density of water [kg/m3]
%          !     (RANGE: KelvinConv - 423.15 DEG. K) (convert to C first)
%
%          ! REFERENCES:
%          ! na
%=========================Input==========================
% TB:   Dry bulb temperature. [C]
%=========================Output=========================
% Rho:  Water Density; [m3/kg]

Rho=1000.1207e0+8.3215874e-4*Tdb-4.929976e-3*Tdb.^2+8.4791863e-06*Tdb.^3;


end

