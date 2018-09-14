function [OutletAir,OutletWater,TotWaterCoolingCoilRate,SenWaterCoolingCoilRate]=...
    CoolingCoilLMTD(InletAir,InletWater,UA,...
    Schedule,HeatExchType,AnalysisMode,DesInletAir,DesInletWater,Parameter)
%
%          ! FUNCTION INFORMATION:
%          ! AUTHOR         Fu Yangyang
%          ! DATE WRITTEN   Jan 2015
%          ! MODIFIED       na
%          ! RE-ENGINEERED  na
%
%          ! PURPOSE OF THIS FUNCTION:
%          ! The subroutine has the coil logic. Three types of Cooling Coils exist:
%          ! They are 1.CoilDry , 2.CoilWet, 3. CoilPartDryPartWet. The logic for
%          ! the three individual cases is in this subroutine.
%
%          ! METHODOLOGY EMPLOYED:
%          ! Simulates a Coil Model from Design conditions and subsequently uses
%          ! configuration values (example: UA)calculated from those design conditions
%          ! to calculate new performance of coil from operating inputs.The values are
%          ! calculated in the Subroutine InitWaterCoil
%
%          ! REFERENCES:
%          ! ASHRAE Secondary HVAC Toolkit TRNSYS.  1990.  A Transient System
%          ! Simulation Program: Reference Manual. Solar Energy Laboratory, Univ. Wisconsin-
%          ! Madison, pp. 4.6.8-1 - 4.6.8-12.
%          ! Threlkeld, J.L.  1970.  Thermal Environmental Engineering, 2nd Edition,
%          ! Englewood Cliffs: Prentice-Hall,Inc. pp. 254-270.
%
%! FUNCTION ARGUMENT DEFINITIONS:
%  InletAir:   Struct array::: Psychmetrical information of inlet air;
%                    InletAir.temp:    :::    a column, Coil inlet air
%                    temperature;(C)
%                    InletAir.W:       :::    a column, Coil inlet air humidty
%                    ratio;(kg/kg(air));
%                    InletAir.DewPTemp;:::    a column, Coil inlet air dew
%                    point temperature;(C)
%                    InletAir.RH;      :::    a column, coil inlet air RH;
%                    InletAir.flowrate :::    a column, coil inlet flowrate;(m3/s)
% InletWater:  Struct array::: Water inlet information;
%                    InletWater.temp:  :::    a column, coil water inlet
%                    temperature;[C]
%                    InletWater.flowrate::    a column, coil water
%                    flowrate;[m3/s]
% UADesign:    Struct array::: Coil Design UA;
%                    UADesign.UATotal   :::   a number, design total UA;[W/K];
%                    UADesign.UAExternal:::   a number, design external UA;[W/K]
%                    UADesign.UAInternal:::   a number, design internal UA;[W/K]
% Schedule:    Column Vector::: ON/OFF signal;[0,1]
% HeatExchType:Integer ::: Heat exchanger type 
%                          0---Ideal type, where effectiveness=1;
%                          1---Counter flow;
%                          2---Cross flow.
% AnalysisMode: String ::: Cooling coil calculation mode;
%                          'SimpleAnalysis' ---all wet or all dry cooling  coil;
%                          'DetailedAnalysis'---all wet,all dry or part wet and part dry;
% DesInletAir:
%                    DesInletAir.temp:    :::    a column, Design Coil inlet air temperature;(C)
%                    DesInletAir.W:       :::    a column, Design Coil inlet air humidty ratio;(kg/kg(air));
%                    DesInletAir.DewPTemp;:::    a column, Design Coil inlet air dew point temperature;(C)
%                    DesInletAir.RH;      :::    a column, Design coil inlet air RH;
%                    DesInletAir.flowrate :::    a column, Design coil inlet flowrate;(m3/s)
% DesInletWater:  
%                    DesInletWater.temp:  :::    a column, design coil water inlet temperature;[C]
%                    DesInletWater.flowrate::    a column, design coil water flowrate;[m3/s]   
%Parameter:       Struct array;
%                     Parameter.AirResis:  :::  air side pressure drop resistance;
%                     Parameter.WaterResis::::  water side pressure drop resistance;
%! FUNCTION LOCAL VARIABLE DECLARATIONS:
%REAL(r64)     :: AirInletCoilSurfTemp  ! Coil surface temperature at air entrance(C)
%REAL(r64)     :: AirDewPointTemp       ! Temperature dew point at operating condition
%REAL(r64)     :: OutletAirTemp         ! Outlet air temperature at operating condition
%REAL(r64)     :: OutletAirHumRat       ! Outlet air humidity ratio at operating condition
%REAL(r64)     :: OutletWaterTemp       ! Outlet water temperature at operating condtitons
%REAL(r64)     :: TotWaterCoilLoad      ! Total heat transfer rate(W)
%REAL(r64)     :: SenWaterCoilLoad      ! Sensible heat transfer rate
%REAL(r64)     :: SurfAreaWetFraction   ! Fraction of surface area wet
%REAL(r64)     :: AirMassFlowRate       ! Air mass flow rate for the calculation
%




if nargin<9   
   Parameter.AirResis=5;
   Parameter.WaterResis=5;
end


%%%%%%%%%%! Initialize the Nominal information
DesInletAirTemp=DesInletAir.temp;
DesInletAirHumRat=DesInletAir.W;
DesAirVolFlowRate=DesInletAir.flowrate;
DesAirMassFlowRate=RhoAirFuTdbWP(DesInletAirTemp,DesInletAirHumRat)*DesAirVolFlowRate;

DesInletWaterTemp=DesInletWater.temp;
DesWaterFlowRate=DesInletWater.flowrate;

DesWaterMassFlowRate=RhoWater(DesInletWaterTemp)*DesWaterFlowRate;

%%%%%%%%%%! Initilize the Input

InletAirTemp=InletAir.temp;
InletAirFlowRate=InletAir.flowrate;
row=size(InletAirTemp,1);

%!Calculate Temperature Dew Point at operating conditions.
AirDewPointTemp= InletAir.DewPTemp;
InletAirHumRat=InletAir.W;

InletWaterTemp=InletWater.temp;
InletWaterFlowRate=InletWater.flowrate;

%ind=find(InletWaterFlowRate~=0);
%InletWaterFlowRate(ind)=max(InletWaterFlowRate(ind),0.2*DesWaterFlowRate);

RhoAir=RhoAirFuTdbWP(InletAirTemp,InletAirHumRat);
InletAirMassFlowRate=RhoAir.*InletAirFlowRate;

InletWaterMassFlowRate=RhoWater(InletWaterTemp).*InletWaterFlowRate;


%%%%%%%%%%! Initialize the Parameter
AirResistance=Parameter.AirResis;
WaterResistance=Parameter.WaterResis;

% Initialize the Local Variables


AirInletCoilSurfTemp=zeros(row,1);  %! Coil surface temperature at air entrance(C)
OutletAirTemp=zeros(row,1);         %! Outlet air temperature at operating condition
OutletAirHumRat=zeros(row,1);       %! Outlet air humidity ratio at operating condition
OutletWaterTemp=zeros(row,1);       %! Outlet water temperature at operating condtitons
TotWaterCoilLoad=0;                 %! Total heat transfer rate(W)
SenWaterCoilLoad=0;                 %! Sensible heat transfer rate
SurfAreaWetFraction=zeros(row,1);   %! Fraction of surface area wet
TotWaterCoolingCoilRate=zeros(row,1);
SenWaterCoolingCoilRate=zeros(row,1);


% Calculate the Varible UA based on inlet water and air mass flowrate;
% WaterCoilType='CoolingCoil';
% [UAExternalTotal,UAInternalTotal,UACoilTotal]=CalcVariableUA(...
%     InletAirMassFlowRate,InletAirTemp,InletWaterMassFlowRate,InletWaterTemp,...
%     DesAirMassFlowRate,DesInletAirTemp,DesWaterMassFlowRate,DesInletWaterTemp,WaterCoilType,UADesign );

UAExternalTotal=UA.external;
UAInternalTotal=UA.internal;
UACoilTotal=UA.total;

% Calculate the Cooling Coil

k=1;
while k<=row
    %! If Coil is Scheduled ON then do the simulation
    if((Schedule(k)~=0.0)&&(InletWaterMassFlowRate(k) > 0.0) && (InletAirMassFlowRate(k)>0))
        
        CoolingCoilAnalysisMode=AnalysisMode;
        
        switch CoolingCoilAnalysisMode
            case 'DetailedAnalysis'
                %!Coil is completely dry if AirDewPointTemp is less than InletWaterTemp,hence Call CoilCompletelyDry
                if (AirDewPointTemp(k) <=InletWaterTemp(k))
                    
                    %!Calculate the leaving conditions and performance of dry coil
                    [OutletAirTemp(k),OutletAirHumRat(k),OutletWaterTemp(k),TotWaterCoilLoad]=CoilCompletelyDry (...
                        InletAirMassFlowRate(k),InletAirTemp(k),InletAirHumRat(k),...
                        InletWaterTemp(k),InletWaterMassFlowRate(k),UACoilTotal,HeatExchType);
                    
                    SenWaterCoilLoad = TotWaterCoilLoad;
                    SurfAreaWetFraction(k) = 0;
                    
                else
                    %!Else If AirDewPointTemp is greater than InletWaterTemp then assume the
                    %!external surface of coil is completely wet,hence Call CoilCompletelyWet
                    %!Calculate the leaving conditions and performance of wet coil
                    [OutletAirTemp(k),OutletAirHumRat(k),OutletWaterTemp(k),...
                        TotWaterCoilLoad,SenWaterCoilLoad,SurfAreaWetFraction(k),AirInletCoilSurfTemp(k)]...
                        =CoilCompletelyWet (InletAirMassFlowRate(k),InletAirTemp(k),InletAirHumRat(k),...
                        InletWaterMassFlowRate(k),InletWaterTemp(k),UAExternalTotal,UAInternalTotal,HeatExchType);

                end  %!End if for dry coil
                
            case 'SimpleAnalysis'
                %!Coil is completely dry if AirDewPointTemp is less than InletWaterTemp,hence Call CoilCompletelyDry
                if (AirDewPointTemp(k) < InletWaterTemp(k))
                    
                    %!Calculate the leaving conditions and performance of dry coil
                    [OutletAirTemp(k),OutletAirHumRat(k),OutletWaterTemp(k),TotWaterCoilLoad]=CoilCompletelyDry (...
                        InletAirMassFlowRate(k),InletAirTemp(k),InletAirHumRat(k),...
                        InletWaterTemp(k),InletWaterMassFlowRate(k),UACoilTotal,HeatExchType);
                    
                    SenWaterCoilLoad = TotWaterCoilLoad;
                    SurfAreaWetFraction(k) = 0;
                    
                else
                    %!Else If AirDewPointTemp is greater than InletWaterTemp then assume the
                    %!external surface of coil is completely wet,hence Call CoilCompletelyWet
                    %!Calculate the leaving conditions and performance of wet coil
                    
                    [OutletAirTemp(k),OutletAirHumRat(k),OutletWaterTemp(k),...
                        TotWaterCoilLoad,SenWaterCoilLoad,SurfAreaWetFraction(k),AirInletCoilSurfTemp(k)]...
                        =CoilCompletelyWet (InletAirMassFlowRate(k),InletAirTemp(k),InletAirHumRat(k),...
                        InletWaterMassFlowRate(k),InletWaterTemp(k),UAExternalTotal,UAInternalTotal,HeatExchType);
                end  %!End if for dry coil
                
        end
        
        %! Report outlet variables at nodes
        
        %!Report output results if the coil was operating
        
        TotWaterCoolingCoilRate(k)=TotWaterCoilLoad;
        SenWaterCoolingCoilRate(k)=SenWaterCoilLoad;
        
    else
        %!If both mass flow rates are zero, set outputs to inputs and return
        OutletWaterTemp(k) = InletWaterTemp(k);
        OutletAirTemp(k)   = InletAirTemp(k);
        OutletAirHumRat(k) = InletAirHumRat(k);
        TotWaterCoolingCoilRate(k)=0.0;
        SenWaterCoolingCoilRate(k)=0.0;
        SurfAreaWetFraction(k)=0.0;
        
    end  %!End of the Flow or No flow If block
    
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