function [SurfaceArea]=EstimateHEXSurfaceArea(UACoilExternal,UACoilInternal)
%
%          ! FUNCTION INFORMATION:
%          !       AUTHOR         Fu Yangyang
%          !       DATE WRITTEN   Jan 2015
%          !       MODIFIED
%          !       RE-ENGINEERED
%
%          ! PURPOSE OF THIS FUNCTION:
%          ! Splits the UA value of a simple coil:cooling:water heat exchanger model into
%          ! "A" and U" values.
%
%          ! METHODOLOGY EMPLOYED:
%          ! A typical design U overall heat transfer coefficient is used to split the "UA" into "A"
%          ! and "U" values. Currently a constant U value calculated for a typical cooling coil is
%          ! used. The assumptions used to calculate a typical U value are:
%          !     (1) tube side water velocity of 2.0 [m/s]
%          !     (2) inside to outside total surface area ratio (Ai/Ao) =  0.07 [-]
%          !     (3) fins overall efficiency = 0.92 based on aluminum fin, 12 fins per inch, and
%          !         fins area to total outside surafce area ratio of about 90%.
%          !     (4) air side convection coefficient of 140.0 [W/m2C].  Assumes sensible convection
%          !         of 58.0 [W/m2C] and 82.0 [W/m2C] sensible convection equivalent of the mass
%          !         transfer coefficient converted using the approximate relation:
%          !         hequivalent = hmasstransfer/Cpair.
%
%          ! REFERENCES:
%


%! FUNCTION PARAMETER DEFINITIONS:
OverallFinEfficiency = 0.92;  %! Assumes aluminum fins, 12 fins per inch, fins
%! area of about 90% of external surface area Ao.
AreaRatio = 0.07;             %! Heat exchanger Inside to Outside surface area ratio
%! design values range from (Ai/Ao) = 0.06 to 0.08

%! INTERFACE BLOCK SPECIFICATIONS
%! na

%! DERIVED TYPE DEFINITIONS
%! na

%! FUNCTION LOCAL VARIABLE DECLARATIONS:
%UOverallHeatTransferCoef      ! over all heat transfer coefficient for coil [W/m2C]
%hAirTubeOutside               ! Air side heat transfer coefficient [W/m2C]
%hWaterTubeInside              ! water (tube) side heat transfer coefficient [W/m2C]

UACoilTotal = 1/(1/UACoilExternal ...
    + 1/UACoilInternal);

%! Tube side water convection heat transfer coefficient of the cooling coil is calculated for
%! inside tube diameter of 0.0122m (~0.5 inch nominal diameter) and water velocity 2.0 m/s:
hWaterTubeInside = 1429*(2^0.8)*(0.0122^(-0.2));

%! Constant value air side heat transfer coefficient is assumed. This coefficient has sensible
%! (58.d0 [W/m2C]) and latent (82.d0 [W/m2C]) heat transfer coefficient components.
hAirTubeOutside = 58 + 82;

%! Estimate the overall heat transfer coefficient, UOverallHeatTransferCoef in [W/(m2C)].
%! Neglecting tube wall and fouling resistance, the overall U value can be estimated as:
%! 1/UOverallHeatTransferCoef = 1/(hi*AreaRatio) + 1/(ho*OverallFinEfficiency)

UOverallHeatTransferCoef = 1/(1/(hWaterTubeInside*AreaRatio) ...
    + 1/(hAirTubeOutside*OverallFinEfficiency));

%! the heat exchanger surface area is calculated as follows:
SurfaceArea=UACoilTotal/UOverallHeatTransferCoef;

return
end

