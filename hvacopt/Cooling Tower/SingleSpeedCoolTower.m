function [OutletWater, CTFanPower,WaterPressureDrop,Qrejection,FanCyclingRatio, SpeedSelected,effectiveness,EcoCost] =...
    SingleSpeedCoolTower( InletAir,InletWater,TempSetPoint,NumParallelON,NumCell ,Parameter,SizingParameter)
%          ! SUBROUTINE INFORMATION:
%          !       AUTHOR         Fu Yangyang
%          !       DATE WRITTEN   Sept. 2014
%          !       MODIFIED       NA
%          !       RE-ENGINEERED  na
%
%          ! PURPOSE OF THIS SUBROUTINE:
%          !
%          ! To simulate the operation of a cooling tower with a SINGLE-speed fan.
%
%          ! METHODOLOGY EMPLOYED:
%          !
%          ! The cooling tower is modeled using effectiveness-NTU relationships for
%          ! counterflow heat exchangers based on Merkel's theory.
%          !
%          ! The subroutine calculates the period of time required to meet a
%          ! leaving water temperature set point. It assumes that part-load
%          ! operation represents a linear interpolation of three steady-state regimes
%          ! (high-speed fan operation, low-speed fan operation and free convection regime).
%          ! Cyclic losses are neglected. The period of time required to meet the
%          ! leaving water temperature set point is used to determine the required
%         ! fan power and energy. Free convection regime is also modeled. This
%          ! occures when the pump is operating and the fan is off. If free convection
%          ! regime cooling is all that is required for a given time step, the leaving
%          ! water temperature is allowed to fall below the leaving water temperature
%          ! set point (free cooling). At times when the cooling tower fan is required,
%          ! the leaving water temperature is at or above the set point.
%          !
%          ! A RunFlag is passed by the upper level manager to indicate the ON/OFF status,
%          ! or schedule, of the cooling tower. If the tower is OFF, outlet water
%          ! temperature and flow rate are passed through the model from inlet node to
%          ! outlet node without intervention (with the exception of free convection
%          ! where water temperature is allowed to float below the outlet water set
%          ! point). Reports are also updated with fan power and fan energy being zero.
%          !
%          ! When the RunFlag indicates an ON condition for the cooling tower, the
%          ! mass flow rate and water temperature are read from the inlet node of the
%          ! cooling tower (water-side). The outdoor air wet-bulb temperature is used
%          ! as the entering condition to the cooling tower (air-side). Input deck
%          ! parameters are read for the free convection regime (pump ON and fan OFF)
%          ! and a leaving water temperature is calculated. If the leaving water temperature
%          ! is at or below the set point, the calculated leaving water temperature is
%          ! placed on the outlet node and no fan power is used. If the calculated leaving
%          ! water temperature is above the set point, the cooling tower fan is turned on
%          ! and parameters for low fan speed are used to again calculate the leaving
%          ! water temperature. If the calculated leaving water temperature is
%          ! below the set point, a fan run-time fraction (FanModeFrac) is calculated and
%          ! used to determine fan power. The leaving water temperature set point is placed
%          ! on the outlet node. If the calculated leaving water temperature is at or above
%          ! the set point, the cooling tower fan is turned on 'high speed' and the routine is
%          ! repeated. If the calculated leaving water temperature is below the set point,
%          ! a fan run-time fraction is calculated for the second stage fan and fan power
%          ! is calculated as FanModeFrac*HighSpeedFanPower+(1-FanModeFrac)*LowSpeedFanPower.
%          ! If the calculated leaving water temperature is above the leaving water temp.
%          ! set point, the calculated leaving water temperature is placed on the outlet
%         ! node and the fan runs at full power (High Speed Fan Power). Water mass flow
%          ! rate is passed from inlet node to outlet node with no intervention.
%          !
%          ! If a tower has multiple cells, the specified inputs of or the autosized capacity
%          !  and air/water flow rates are for the entire tower. The number of cells to operate
%          !  is first determined based on the user entered minimal and maximal water flow fractions
%          !  per cell. If the loads are not met, more cells (if available) will operate to meet
%          !  the loads. Each cell operates in same way - same fan speed etc.
%          !
%          ! REFERENCES:
%          ! ASHRAE HVAC1KIT: A Toolkit for Primary HVAC System Energy Calculation. 1999.
%
%  REAL(r64)              :: AirFlowRate
%  REAL(r64)              :: UAdesign            ! UA value at design conditions (entered by user) [W/C]
%  REAL(r64)              :: OutletWaterTempOFF
%  REAL(r64)              :: OutletWaterTemp1stStage
%  REAL(r64)              :: OutletWaterTemp2ndStage
%  REAL(r64)              :: FanModeFrac
%  REAL(r64)              :: designWaterFlowRate
%  REAL(r64)              :: FanPowerLow
%  REAL(r64)              :: FanPowerHigh
%  REAL(r64)              :: CpWater
%  REAL(r64)              :: TempSetPoint
%
%
% !Added variables for multicell
%  REAL(r64)              :: WaterMassFlowRatePerCellMin
%  REAL(r64)              :: WaterMassFlowRatePerCellMax
%  INTEGER                :: NumCellMin = 0
%  INTEGER                :: NumCellMax = 0
%  INTEGER                :: NumCellON = 0
%  REAL(r64)              :: WaterMassFlowRatePerCell
%  LOGICAL                :: IncrNumCellFlag                   ! determine if yes or no we increase the number of cells



if nargin<6
    Parameter.NomHeatFlow=4.3272e5; %W
    Parameter.NomFlow=[50000/3600 75/3600];
    Parameter.FreeConv=[0.1 0.1*2.1517e4];
    Parameter.FracWaterFlow=[0.4 1.2];
    Parameter.FanON=[5500 2.1517e4];
    Parameter.Resis=5;
end

if nargin<7
    SizingParameter.DesignPressure=1e6;% Pa
    SizingParameter.NumParallelMax=2;
end


%% Initialize the model

%**********************************
%********* Check the input ********
%**********************************

DesAirFlowRateCell=Parameter.NomFlow(1,1);
DesWaterFlowRateCell=Parameter.NomFlow(1,2);

FreeConvAirRatio=Parameter.FreeConv(1,1);
FreeConvTowerUA=Parameter.FreeConv(1,2);

MinFracFlowRate=Parameter.FracWaterFlow(1,1);
MaxFracFlowRate=Parameter.FracWaterFlow(1,2);

% Fan

NominalFanPower=Parameter.FanON(1,1);   % Fan Power in Each Cell;
FanONTowerUA=Parameter.FanON(1,2);      % Fan ON UA Value in parallel(total of cells);

% Pressure Drop
Resistance=Parameter.Resis;

% Sizing Parameter
DesignPressure=SizingParameter.DesignPressure;
NumParallelMax=SizingParameter.NumParallelMax;

%*************************************
%******* Initialize INPUT   **********
%*************************************
% Inlet condition
InletAirTemp=InletAir.temp;% dry bulb temperature;
InletAirRH=InletAir.RH;
[InletAir.H,InletAir.W]=PsychTdbRH(InletAir.temp,InletAir.RH);
InletAir.Twb=PsychTwbFuTdbW(InletAir.temp,InletAir.W);

InletWaterTemp=InletWater.temp;
WaterFlowRate=InletWater.flowrate;



row=size(WaterFlowRate,1);

TempSetPoint=TempSetPoint.*ones(row,1);

% Nominal Condition

FreeConvAirFlowRate=FreeConvAirRatio*DesAirFlowRateCell;
FanONAirFlowRate=DesAirFlowRateCell;




%*********************************************
%******* Initialize OUTPUT  ******************
%********************************************
OutletWaterTemp=TempSetPoint;


%**********************************************
%******* Initialize Local Variable   **********
%**********************************************

%!set local variable for tower
WaterFlowRatePerParallel=zeros(row,1);
NumCellMin=zeros(row,1);
NumCellMax=zeros(row,1);
NumCellON=zeros(row,1);
WaterFlowRatePerCell=zeros(row,1);
CTFanPower=zeros(row,1);
SpeedSel=zeros(row,1);
FanModeFrac= zeros(row,1);
effectiveness=zeros(row,1);
OutletWaterTempOFF  = InletWaterTemp;
OutletWaterTempON = OutletWaterTemp;
AirFlowRate=zeros(row,1);

%! Added for multi-cell. Determine the number of cells operating
WaterFlowRatePerCellMin = DesWaterFlowRateCell * MinFracFlowRate ;%/NumCell;
%WaterFlowRatePerCellMax = DesWaterFlowRate * MaxFracFlowRate ;%/NumCell;


%% Calculate the model
% Calculate from free convection


k=1;
while k<=row
    
    if (NumParallelON(k)~=0)
        WaterFlowRatePerParallel(k)=WaterFlowRate(k)/NumParallelON(k);
        
        % !round it up to the nearest integer
        %NumCellMin(k) = min(fix((WaterFlowRatePerParallel(k) / WaterFlowRatePerCellMax)+0.9999),NumCell);
        %NumCellMax(k) = min(fix((WaterFlowRatePerParallel(k) / WaterFlowRatePerCellMin)+0.9999),NumCell);
        
        % ! cap min at 1
        %if(NumCellMin<=0);
            NumCellMin(k)=1;
        %end
        %if(NumCellMax<=0);
        %    NumCellMax(k)=1;
        %end
        
        NumCellON(k) = NumCellMin(k);
        
        WaterFlowRatePerCell(k) = WaterFlowRatePerParallel(k) ./ NumCellON(k);
        
        
        
        IncrNumCellFlag =1;
        
        while (IncrNumCellFlag)
            
            IncrNumCellFlag = 0;
            
            %! Calculate the outlet water temperature using free convection
            UAdesign  = FreeConvTowerUA ;%/ NumCell;
            AirFlowRate(k) = FreeConvAirFlowRate;% / NumCell;
            
            InletAIR.flowrate(k)=AirFlowRate(k) ;
            InletAIR.temp=InletAirTemp(k);
            InletAIR.RH=InletAirRH(k);
            InletAIR.H=InletAir.H(k);
            InletAIR.W=InletAir.W(k);
            InletAIR.Twb=InletAir.Twb(k);
            
            InletWATER.temp=InletWaterTemp(k);
            InletWATER.flowrate=WaterFlowRatePerCell(k);
            
            [OutletWaterTempOFF(k),effectiveness(k)]=SimSimpleTower(InletAIR,InletWATER,UAdesign);
            
            %!     Setpoint was met using free convection regime (pump ON and fan OFF)
            CTFanPower(k)    = 0.0;
            OutletWaterTemp(k) = OutletWaterTempOFF(k);
            SpeedSel(k) = 0;
            
            if(OutletWaterTempOFF(k) > TempSetPoint(k))
                %!   Setpoint was not met (or free conv. not used),turn on cooling tower fan
                UAdesign           = FanONTowerUA ;%/ NumCell;     Design UA Value in each cell
                AirFlowRate(k)     = FanONAirFlowRate;% / NumCell; Design air flow rate with fan on in each cell
                FanPowerLow        = NominalFanPower;  % Fan Power in each cell;
                
                InletAIR.flowrate=AirFlowRate(k) ;
                InletAIR.temp=InletAirTemp(k);
                InletAIR.RH=InletAirRH(k);
                InletAIR.H=InletAir.H(k);
                InletAIR.W=InletAir.W(k);
                InletAIR.Twb=InletAir.Twb(k);
                
                InletWATER.temp=InletWaterTemp(k);
                InletWATER.flowrate=WaterFlowRatePerCell(k);
                
                [OutletWaterTempON(k),effectiveness(k)]= SimSimpleTower(InletAIR,InletWATER,UAdesign);
                
                if(OutletWaterTempON(k) <=TempSetPoint(k))
                    %         Setpoint was met with pump ON and fan ON , calculate fan mode fraction
                    FanModeFrac(k)     = (TempSetPoint(k)-OutletWaterTempOFF(k))/(OutletWaterTempON(k)-OutletWaterTempOFF(k));
                    CTFanPower(k)      = FanModeFrac(k) * FanPowerLow;
                    OutletWaterTemp(k) = TempSetPoint(k);
                    SpeedSel(k) = 1;
                    
                else
                    % Setpoint was not met, cooling tower ran at full capacity
                    OutletWaterTemp(k) = OutletWaterTempON(k);
                    CTFanPower(k)      = FanPowerLow;
                    SpeedSel(k) = 1;
                    FanModeFrac(k) = 1;
                    % if possible increase the number of cells and do the calculations again with the new water mass flow rate per cell
                    if (NumCellON(k) <NumCell)&&((WaterFlowRatePerParallel(k)/(NumCellON(k)+1) > WaterFlowRatePerCellMin))
                        NumCellON(k) = NumCellON(k) + 1;
                        WaterFlowRatePerCell(k) = WaterFlowRatePerParallel(k) / NumCellON(k);
                        IncrNumCellFlag = 1;
                    end
                end
                
                
                
            end
        end
        
    else
        CTFanPower(k)=0;
        FanModeFrac(k)=0;
        SpeedSel(k)=0;
        OutletWaterTemp(k)=0;
    end
    k=k+1;
end

% Economic Model
% Capitial Cost model
% Data from the RMeans Construction Data indicate that the capitial cost of
% Cooling Tower is function of its rated heat rejection capacity
RatedCapacity= NumCell*Parameter.NomHeatFlow;
RatedCapacityTON=RatedCapacity./(1000*3.517);   %  1TON =3.517KW 
CapitalCostUSDBaseline=98.692*RatedCapacityTON+6761.7; % x=[50~1000]
% Data from the RMeans Construction Data indicate that the capitial cost of
% VFD is function of its rated horsepower

if DesignPressure==1.0*1e6
    CapitalCostUSD=CapitalCostUSDBaseline;
elseif DesignPressure==1.6*1e6
    CapitalCostUSD=CapitalCostUSDBaseline*(1+0.05);
elseif DesignPressure==2.0*1e6
    CapitalCostUSD=CapitalCostUSDBaseline*(1+0.11);
elseif DesignPressure==2.5*1e6
    CapitalCostUSD=CapitalCostUSDBaseline*(1+0.18);
elseif DesignPressure>2.5*1e6
    CapitalCostUSD=CapitalCostUSDBaseline*(1+0.26);
end



%!output the fraction of the time step the fan is ON
FanCyclingRatio = FanModeFrac;
SpeedSelected = SpeedSel;
CTFanPower=CTFanPower.*NumCellON.*NumParallelON;

WaterDensity=RhoWater(InletWaterTemp);
WaterMassFlowRate=WaterDensity.*WaterFlowRate;
CpWater  = PsychCpWater(InletWaterTemp);
Qrejection = WaterMassFlowRate .* CpWater .* (InletWaterTemp - OutletWaterTemp);

%Outlet Water
OutletWater.temp=OutletWaterTemp;
OutletWater.flowrate=WaterFlowRate;

%Pressure Drop
WaterPressureDrop=Resistance.*WaterMassFlowRate.^2;

% Economic Model
EcoCost.CapCost=CapitalCostUSD*NumParallelMax;


end

