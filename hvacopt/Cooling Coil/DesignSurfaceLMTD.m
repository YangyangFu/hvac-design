function [OutletAir,OutletWater,SurfaceArea,TotHeatTransferRate,SenWaterCoolingCoilRate]=...
    DesignSurfaceLMTD(...
    InletAir,InletWater,TempSetPoint,OutletWaterTemp,Schedule,DesInformation,Parameter)

% Simplified cooling coil for design process.
%   %
%          ! FUNCTION INFORMATION:
%          ! AUTHOR         Fu Yangyang
%          ! DATE WRITTEN   Jul 2015
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



if nargin<6
    DesInformation.AirVelocity=2.5;
    DesInformation.AirFlowrate=62880/3600;
    DesInformation.WaterVelocity=1.5;
    DesInformation.WaterFlowrate=0.1;
end
if nargin<7
    Parameter.A=27.3;
    Parameter.B=353.6;
    Parameter.m=0.58;
    Parameter.n=0.075;
    Parameter.p=1.02;
    Parameter.AirResis=16;
    Parameter.WaterResis=5;
    
end

%% INITIAIIZATION
% Initialize the parameters, inputs and local variables before the
% simulaiton starts

% INITIALIZE THE PARAMETERS
A=Parameter.A;
B=Parameter.B;
m=Parameter.m;
n=Parameter.n;
p=Parameter.p;
AirResistance=Parameter.AirResis;
WaterResistance=Parameter.WaterResis;


% _% INITIALIZE THE INPUT
% Inlet air
InletAirTemp=InletAir.temp;
InletAirHumidityRatio=InletAir.W;
InletAirRH=InletAir.RH;
InletAirEnthalpy=InletAir.H;
InletAirDewPointTemp=InletAir.DewPTemp;

AirVolFlowrate=InletAir.flowrate;
RhoAir=RhoAirFuTdbWP(InletAirTemp,InletAirHumidityRatio);
AirMassFlowRate=RhoAir.*AirVolFlowrate;

% OutletAirTemp
OutletAirTemp=TempSetPoint;

% Inlet water
InletWaterTemp=InletWater.temp;
RhoWaterCoil=RhoWater(InletWaterTemp);

Row=length(AirMassFlowRate);

% *INITIALIZE THE NOMINAL INFORMATION*
DesAirVelocity=DesInformation.AirVelocity;
DesAirVolFlowrate=DesInformation.AirFlowrate;
DesWaterVelocity=DesInformation.WaterVelocity;
DesWaterFlowrate=DesInformation.WaterFlowrate;

MinWaterMassFlowrate=0.2*1e3*DesWaterFlowrate;
MaxWaterMassFlowrate=1.2*1e3*DesWaterFlowrate;


% *INITIALIZE THE LOCAL VARIABLES*
OutletAirHumidityRatio=zeros(Row,1);
OutletAirRH=zeros(Row,1);
OutletAirEnthalpy=zeros(Row,1);
AirPressureDrop=zeros(Row,1);
TotHeatTransferRate=zeros(Row,1);
SenWaterCoolingCoilRate=zeros(Row,1);

WetIndex=zeros(Row,1);
InternalU=zeros(Row,1);
ExternalU=zeros(Row,1);
TotalU=zeros(Row,1);
LMTD=zeros(Row,1);

OutletWaterTemp=OutletWaterTemp*ones(Row,1);
WaterMassFlowRate=zeros(Row,1);
WaterPressureDrop=zeros(Row,1);


% determine the coil condition and the outlet condition
AirCp=PsychCpAirFuTdbW(InletAirTemp,InletAirHumidityRatio);
WaterCp=PsychCpWater(InletWaterTemp);

AirVelocity=DesAirVelocity*AirVolFlowrate./DesAirVolFlowrate;


%% DO THE SIMULATION
% Simulation starts


i=1;
while i<=Row
    %! If Coil is Scheduled ON then do the simulation
    if((Schedule(i)~=0.0)&&(AirMassFlowRate(i)>0))
        
        if InletAirDewPointTemp(i)<InletWaterTemp(i)
            % dry coil outlet condition
            OutletAirHumidityRatio(i,:)=InletAirHumidityRatio(i);
            OutletAirRH(i,:)=PsychRHFuTdbW(OutletAirTemp(i),OutletAirHumidityRatio(i));
            OutletAirEnthalpy(i,:)=PsychHFuTdbW(OutletAirTemp(i),OutletAirHumidityRatio(i));
            
            % Calculate the t otal heat flow on air side
            TotHeatTransferRate(i,:)=AirMassFlowRate(i).*AirCp(i).*(InletAirTemp(i)-OutletAirTemp(i));
            
            
        else
            % wet coil outlet condition
            OutletAirRH(i,:)=0.95;
            OutletAirHumidityRatio(i,:)=PsychWFuTdbRH(OutletAirTemp(i),OutletAirRH(i));
            OutletAirEnthalpy(i,:)=PsychHFuTdbW(OutletAirTemp(i),OutletAirHumidityRatio(i));
            
            % Calculate the total heat flow on air side
            TotHeatTransferRate(i,:)=AirMassFlowRate(i).*(InletAirEnthalpy(i)-OutletAirEnthalpy(i));
            
        end
        
        % Calculate
        WetIndex(i,:)=(InletAirEnthalpy(i)-OutletAirEnthalpy(i))./AirCp(i)./(InletAirTemp(i)-OutletAirTemp(i));
        
        % Calculate the total U value. Ignore the change of water side U value
        % duing operating phase.
        %TotalU(i,:)=1./(1./(A*AirVelocity(i).^m.*WetIndex(i).^p)+1./(B.*WaterVelocity(i).^n));
        
        % Assume that the external U is 3.3 times internal U;
        ExternalU(i)=A*AirVelocity(i).^m.*WetIndex(i).^p;
        InternalU(i)=3.3*ExternalU(i);
        TotalU(i)=1./(1./InternalU(i)+1./ExternalU(i));
        
        % Calculate the outlet water temperature, assuming a counter flow is used.
        deltaT1=InletAirTemp(i)-OutletWaterTemp(i);
        deltaT2=OutletAirTemp(i)-InletWaterTemp(i);
        LMTD(i,:)=(deltaT1-deltaT2)./log(deltaT1/deltaT2);
        
        
        SurfaceArea=TotHeatTransferRate(i)./TotalU(i)/LMTD(i);
        
        %******* The following codes have been discarded*******************
        %******************************************************************
        % Initial value
        %x0=InletWaterTemp(i)+5;
        % iterate for the outlet water temperature by given LMTD
        %fun=@LMTDEquation;
        %OutletWaterTemp(i,:)=fsolve(fun,x0);
        %OutletWaterTemp(i,:)=InletWaterTemp(i)+WaterTempDifference;
        %******************************************************************
        
        
            WaterMassFlowRate(i,:)=TotHeatTransferRate(i)./WaterCp(i)./(OutletWaterTemp(i)-InletWaterTemp(i)); % Kg/s
            
            WaterMassFlowRate(i,:)=min(max(WaterMassFlowRate(i,:),MinWaterMassFlowrate),MaxWaterMassFlowrate);
            
            % Sensible Heat Flowrate
            SenWaterCoolingCoilRate(i)=AirMassFlowRate(i)*AirCp(i)*(InletAirTemp(i)-OutletAirTemp(i));
            
            % the pressure drop through water side
            WaterPressureDrop(i)=WaterResistance*WaterMassFlowRate(i).^2; % Pa
            % the pressure drop through air side
            AirPressureDrop(i)=AirResistance*AirMassFlowRate(i).^2;% Pa
            
       
        
        
    else
        OutletAirTemp(i)=InletAirTemp(i);
        OutletAirRH(i)=InletAirRH(i);
        OutletAirHumidityRatio(i)=InletAirHumidityRatio(i);
        OutletAirEnthalpy(i)=InletAirEnthalpy(i);
        
        OutletWaterTemp(i)=InletWaterTemp(i);
        
        TotHeatTransferRate(i)=0;
        SenWaterCoolingCoilRate(i)=0;
        
        AirPressureDrop(i)=0;
        WaterMassFlowRate(i)=0;
        WaterPressureDrop(i)=0;
    end
    
    i=i+1;
end


%% UPDATE THE OUTPUT
WaterVolFlowRate=WaterMassFlowRate./RhoWaterCoil;

% Output of air side
OutletAir.temp=OutletAirTemp;
OutletAir.RH=OutletAirRH;
OutletAir.W=OutletAirHumidityRatio;
OutletAir.H=OutletAirEnthalpy;
OutletAir.Twb=PsychTwbFuTdbW(OutletAirTemp,OutletAirHumidityRatio);
OutletAir.flowrate=AirVolFlowrate;
OutletAir.pressure_loss=AirPressureDrop;

% Outlet of Water Side
OutletWater.flowrate=WaterVolFlowRate;
OutletWater.temp=OutletWaterTemp;
OutletWater.pressure_loss=WaterPressureDrop;


end


