function [OutletWaterTemp,effectiveness,Qactual]=SimSimpleTower(InletAir,InletWater,UAdesign)
%
%         ! SUBROUTINE INFORMATION:
%          !       AUTHOR         Fu Yangyang
%          !       DATE WRITTEN   Sept. 2014
%          !       MODIFIED       na
%          !       RE-ENGINEERED  Shirey, Raustad, Jan 2001
%
%          ! PURPOSE OF THIS SUBROUTINE:
%          !
%          ! See purpose for Single Speed or Two Speed tower model
%
%          ! METHODOLOGY EMPLOYED:
%          !
%          ! See methodology for Single Speed or Two Speed tower model
%
%          ! REFERENCES:
%          !
%          ! Merkel, F. 1925.  Verduftungskuhlung. VDI Forschungsarbeiten, Nr 275, Berlin.
%          ! ASHRAE     1999.  HVAC1KIT: A Toolkit for Primary HVAC System Energy Calculations.
%
%          ! USE STATEMENTS:
%          ! na
%
%! SUBROUTINE ARGUMENT DEFINITIONS:
% INTEGER                :: TowerNum
% REAL(r64)              :: WaterMassFlowRate
% REAL(r64)              :: AirFlowRate
% REAL(r64)              :: UAdesign
% REAL(r64)              :: OutletWaterTemp
%
%! SUBROUTINE PARAMETER DEFINITIONS:
% INTEGER, PARAMETER   :: IterMax           = 50      ! Maximum number of iterations allowed
% REAL(r64), PARAMETER :: WetBulbTolerance  = 0.00001d0 ! Maximum error for exiting wet-bulb temperature between iterations
%                                                       ! [delta K/K]
% REAL(r64), PARAMETER :: DeltaTwbTolerance = 0.001d0   ! Maximum error (tolerance) in DeltaTwb for iteration convergence [C]
%
% INTEGER                :: Iter                 ! Number of iterations completed
% REAL(r64)              :: MdotCpWater          ! Water mass flow rate times the heat capacity [W/K]
% REAL(r64)              :: InletAirTemp         ! Dry-bulb temperature of air entering the tower [C]
% REAL(r64)              :: CpWater              ! Heat capacity of water [J/kg/K]
% REAL(r64)              :: CpAir                ! Heat capacity of air [J/kg/K]
% REAL(r64)              :: AirDensity           ! Density of air [kg/m3]
% REAL(r64)              :: AirMassFlowRate      ! Mass flow rate of air [kg/s]
% REAL(r64)              :: effectiveness        ! Effectiveness of the heat exchanger [-]
% REAL(r64)              :: UAactual             ! UA value at actual conditions [W/C]
% REAL(r64)              :: InletAirEnthalpy     ! Enthalpy of entering moist air [J/kg]
% REAL(r64)              :: InletAirWetBulb      ! Wetbulb temp of entering moist air [C]
% REAL(r64)              :: OutletAirEnthalpy    ! Enthalpy of exiting moist air [J/kg]
% REAL(r64)              :: OutletAirWetBulb     ! Wetbulb temp of exiting moist air [C]
% REAL(r64)              :: OutletAirWetBulbLast ! temporary Wetbulb temp of exiting moist air [C]
% REAL(r64)              :: AirCapacity          ! MdotCp of air through the tower
% REAL(r64)              :: CapacityRatioMin     ! Minimum capacity of airside and waterside
% REAL(r64)              :: CapacityRatioMax     ! Maximum capacity of airside and waterside
% REAL(r64)              :: CapacityRatio        ! Ratio of minimum to maximum capacity
% REAL(r64)              :: NumTransferUnits     ! Number of transfer Units [NTU]
% REAL(r64)              :: WetBulbError      ! Calculated error for exiting wet-bulb temperature between iterations [delta K/K]
% REAL(r64)              :: CpAirside            ! Delta enthalpy of the tower air divides by delta air wet-bulb temp [J/kg/K]
% REAL(r64)              :: Qactual              ! Actual heat transfer rate between tower water and air [W]
% REAL(r64)              :: DeltaTwb             ! Absolute value of difference between inlet and outlet air wet-bulb temp [C]


%% ! set inlet and outlet node numbers, and initialize some local variables

WetBulbTolerance  = 0.00001;
IterMax           = 1000;
DeltaTwbTolerance = 0.001;

%! set local tower inlet and outlet temperature variables
InletAirTemp=InletAir.temp;
InletAirRH=InletAir.RH;
InletAirEnthalpy=InletAir.H;
InletAirHumRat=InletAir.W;
InletAirWetBulb=InletAir.Twb;
AirFlowRate=InletAir.flowrate;

InletWaterTemp=InletWater.temp;
WaterFlowRate=InletWater.flowrate;

OutletWaterTemp   = InletWaterTemp;

KelvinConv=273.15;



%! set water and air properties
AirDensity        = RhoAirFuTdbWP(InletAirTemp,InletAirHumRat);
AirMassFlowRate   = AirFlowRate.*AirDensity;
WaterDensity=RhoWater(InletWaterTemp);
WaterMassFlowRate=WaterFlowRate.*WaterDensity;
CpAir             = PsychCpAirFuTdbW(InletAirTemp,InletAirHumRat);
CpWater           = PsychCpWater(InletWaterTemp);

row=size(WaterFlowRate,1);

%! Initialize the local variables
Qactual    = zeros(row,1);
MdotCpWater= zeros(row,1);
OutletAirEnthalpy= zeros(row,1);
CpAirside= zeros(row,1);
AirCapacity= zeros(row,1);
CapacityRatio= zeros(row,1);
UAactual= zeros(row,1);
effectiveness= zeros(row,1);
OutletAirWetBulbLast= zeros(row,1);

WetBulbError      = ones(row,1);
DeltaTwb          = ones(row,1);

%! initialize exiting wet bulb temperature before iterating on final solution
OutletAirWetBulb = InletAirWetBulb + 6.0;

%! Calcluate mass flow rates


k=1;
while k<=row    
    
    if (WaterMassFlowRate(k) > 0)
        MdotCpWater(k) =   WaterMassFlowRate(k) * CpWater(k);
    else
        OutletWaterTemp(k) = InletWaterTemp;
    end
    
    Iter = 0;
    while ((WetBulbError(k)>WetBulbTolerance) && (Iter<IterMax) && (DeltaTwb(k)>DeltaTwbTolerance))
        Iter = Iter + 1;
        %!OutletAirEnthalpy = PsyHFnTdbRhPb(OutletAirWetBulb,1.0,OutBaroPress)
        OutletAirEnthalpy(k) =PsychTdbRH(OutletAirWetBulb(k),1.0);
        %! calculate the airside specific heat and capacity
        CpAirside(k)   =   (OutletAirEnthalpy(k) - InletAirEnthalpy(k))./(OutletAirWetBulb(k)-InletAirWetBulb(k));
        AirCapacity(k) = AirMassFlowRate(k) .* CpAirside(k);
        %! calculate the minimum to maximum capacity ratios of airside and waterside
        CapacityRatioMin = min(AirCapacity(k),MdotCpWater(k));
        CapacityRatioMax = max(AirCapacity(k),MdotCpWater(k));
        CapacityRatio (k)   = CapacityRatioMin./CapacityRatioMax;
        %! Calculate heat transfer coefficient and number of transfer units (NTU)
        UAactual(k) = UAdesign*CpAirside(k)./CpAir(k);
        NumTransferUnits = UAactual(k)./CapacityRatioMin;
        %! calculate heat exchanger effectiveness
        if (CapacityRatio(k)<0.995)
            effectiveness(k) = (1.0-exp(-1.0*NumTransferUnits.*(1.0-CapacityRatio(k))))./ ...
                (1.0-CapacityRatio(k).*exp(-1.0*NumTransferUnits.*(1.0-CapacityRatio(k))));
        else
            effectiveness(k) = NumTransferUnits./(1.0+NumTransferUnits);
        end
        
        %! calculate water to air heat transfer and store last exiting WB temp of air
        Qactual(k) = effectiveness(k) .* CapacityRatioMin .* (InletWaterTemp(k)-InletAirWetBulb(k));
        OutletAirWetBulbLast(k) = OutletAirWetBulb(k);
        %! calculate new exiting wet bulb temperature of airstream
        OutletAirWetBulb(k) = InletAirWetBulb(k) + Qactual(k)./AirCapacity(k);
        %! Check error tolerance and exit if satisfied
        DeltaTwb(k) = abs(OutletAirWetBulb(k) - InletAirWetBulb(k));
        %! Add KelvinConv to denominator below convert OutletAirWetBulbLast to Kelvin to avoid divide by zero.
        %! Wet bulb error units are delta K/K
        WetBulbError(k) = abs((OutletAirWetBulb(k) - OutletAirWetBulbLast(k))./(OutletAirWetBulbLast(k)+KelvinConv));        
    end
    
    if(Qactual(k) > 0.0)
        OutletWaterTemp(k) = InletWaterTemp(k) - Qactual(k)./ MdotCpWater(k);
    else
        OutletWaterTemp(k) = InletWaterTemp(k);
    end
    
    k=k+1;
end

end