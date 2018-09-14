function [OutletAir,OutletWater,TotWaterCoolingCoilRate,SenWaterCoolingCoilRate]...
    =DesCoolingCoil(InletAir,InletWater,OutletAirTempSetPoint,UADesign,...
    Schedule,HeatExchType,AnalysisMode,DesInletAir,DesInletWater,Parameter)
%
%          ! FUNCTION INFORMATION:
%          ! AUTHOR         Fu Yangyang
%          ! DATE WRITTEN   Jan 2015
%          ! MODIFIED       na
%          ! RE-ENGINEERED  na
%
%          ! PURPOSE OF THIS FUNCTION:
%          ! This function invert the CoolingCoil model for water side
%          ! flow rate.Three types of coils are provided:
%          ! They are 1.CoilDry , 2.CoilWet, 3.CoilPartDryPartWet. The logic for
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

InletAirTemp=InletAir.temp;
InletAirFlowRate=InletAir.flowrate;

InletAirHumRat=InletAir.W;
AirDewPointTemp=InletAir.DewPTemp;
InletWaterTemp=InletWater.temp;

row=size(InletAirTemp,1);

WaterRho=RhoWater(InletWaterTemp);
WaterCp=PsychCpWater(InletWaterTemp);

%  FUNCTION LOCAL VARIABLES
OutletAirTemp=zeros(row,1);
OutletAirRH=zeros(row,1);
OutletAirHumRat=zeros(row,1);
OutletAirEnthalpy=zeros(row,1);
OutletAirWetBulbTemp=zeros(row,1);
OutletAirFlowRate=zeros(row,1);
AirDeltaP=zeros(row,1);

OutletWaterTemp=zeros(row,1);
WaterDeltaP=zeros(row,1);
OutletWaterFlowRate=zeros(row,1);

TotWaterCoolingCoilRate=zeros(row,1);
SenWaterCoolingCoilRate=zeros(row,1);



k=1;
while k<=row
    
    InletAirIter.temp=InletAirTemp(k);
    InletAirIter.flowrate=InletAirFlowRate(k);
    
    InletAirIter.W=InletAirHumRat(k);
    InletAirIter.DewPTemp=AirDewPointTemp(k);
    InletWaterIter.temp=InletWaterTemp(k);
    
    ScheduleIter=Schedule(k);
    WaterVolFlowRateInit=DesInletWater.flowrate; 
    %! Iteration for the output based on given temperature set point
    fun=@CoolingCoilEquation;   
       
    %options=optimoptions('fsolve','Algorithm','levenberg-marquardt');
    %OutletWaterFlowRate(k)=fsolve(fun,WaterVolFlowRateInit,options);
    
    [OutletWaterFlowRate(k),~,exitflag]=fzero(fun,WaterVolFlowRateInit);
    WaterVolFlowRateInit=OutletWaterFlowRate(k);
    if exitflag>0
        OutletWaterFlowRate(k)=max(OutletWaterFlowRate(k),0.2*DesInletWater.flowrate);
        OutletWaterTemp(k)=OutletWaterIter.temp;
        WaterDeltaP(k)=OutletWaterIter.pressure_loss;
    else
        OutletWaterFlowRate(k)=DesInletWater.flowrate;
        OutletWaterTemp(k)=TotWaterCoolingCoilRateIter./(WaterRho(k)*OutletWaterFlowRate(k)*WaterCp(k))+InletWaterTemp(k);
        WaterDeltaP(k)=Parameter.WaterResis*(WaterRho(k)*OutletWaterFlowRate(k)).^2;
    end
    
    OutletAirTemp(k)=OutletAirIter.temp;
    OutletAirRH(k)=OutletAirIter.RH;
    OutletAirHumRat(k)=OutletAirIter.W;
    OutletAirEnthalpy(k)=OutletAirIter.H;
    OutletAirWetBulbTemp(k)=OutletAirIter.Twb;
    OutletAirFlowRate(k)=OutletAirIter.flowrate;
    AirDeltaP(k)=OutletAirIter.pressure_loss;
       
    TotWaterCoolingCoilRate(k)=TotWaterCoolingCoilRateIter;
    SenWaterCoolingCoilRate(k)=SenWaterCoolingCoilRateIter;
    
    k=k+1;
end

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

    function error=CoolingCoilEquation(InletWaterVolFlowRate)
        InletWaterIter.flowrate=InletWaterVolFlowRate;
        [OutletAirIter,OutletWaterIter,TotWaterCoolingCoilRateIter,SenWaterCoolingCoilRateIter]=...
            CoolingCoil(InletAirIter,InletWaterIter,UADesign,...
            ScheduleIter,HeatExchType,AnalysisMode,DesInletAir,DesInletWater,Parameter);
        error=OutletAirIter.temp-OutletAirTempSetPoint(k);
    end
end