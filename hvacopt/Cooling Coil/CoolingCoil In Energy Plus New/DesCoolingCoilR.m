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

%%%%%%%%%%! Initialize the Nominal information
DesInletAirTemp=DesInletAir.temp;
DesInletAirHumRat=DesInletAir.W;
DesAirVolFlowRate=DesInletAir.flowrate;
DesAirMassFlowRate=RhoAirFuTdbWP(DesInletAirTemp,DesInletAirHumRat)*DesAirVolFlowRate;

DesInletWaterTemp=DesInletWater.temp;
DesWaterFlowRate=DesInletWater.flowrate;

DesWaterMassFlowRate=RhoWater(DesInletWaterTemp)*DesWaterFlowRate;

InletAirTemp=InletAir.temp;
InletAirFlowRate=InletAir.flowrate;

InletAirHumRat=InletAir.W;
InletAirRh = PsychRHFuTdbW(InletAirTemp,InletAirHumRat);
AirDewPointTemp=InletAir.DewPTemp;
InletWaterTemp=InletWater.temp;

RhoAir=RhoAirFuTdbWP(InletAirTemp,InletAirHumRat);
InletAirMassFlowRate=RhoAir.*InletAirFlowRate;

row=size(InletAirTemp,1);

WaterRho=RhoWater(InletWaterTemp);
WaterCp=PsychCpWater(InletWaterTemp);

%%%%%%%%%%! Initialize the Parameter
AirResistance=Parameter.AirResis;
WaterResistance=Parameter.WaterResis;

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
 InletWaterMassFlowRate=zeros(row,1);

%% Calculate the Varible UA based on inlet water and air mass flowrate;

 k=1;
 while k<=row
     %! If Coil is Scheduled ON then do the simulation
     if((Schedule(k)~=0.0) && (InletAirMassFlowRate(k)>0))
         if (AirDewPointTemp(k) <=InletWaterTemp(k))
             CpAir = PsychCpAirFuTdbW(InletAirTemp(k),InletAirHumRat(k));
             Cp =  PsychCpWater(InletWaterTemp(k));
             TotWaterCoolingCoilRate(k) =InletAirMassFlowRate(k).*CpAir.*abs(InletAirTemp(k)-OutletAirTempSetPoint(k));
             
             WaterCoilType='CoolingCoil';
             InletWaterMassFlowRate(k)=TotWaterCoolingCoilRate(k)/(4.*Cp);
             [UAExternalTotal,UAInternalTotal,UACoilTotal]=CalcVariableUA(...
                 InletAirMassFlowRate,InletAirTemp,InletWaterMassFlowRate,InletWaterTemp,...
                 DesAirMassFlowRate,DesInletAirTemp,DesWaterMassFlowRate,DesInletWaterTemp,WaterCoilType,UADesign);
             if(InletWaterMassFlowRate(k) > 0)
                 LMTD=TotWaterCoolingCoilRate(k)/UACoilTotal(k);
                 OutletWaterTemp(k) = InletAirTemp(k)- (LMTD.*2-(OutletAirTempSetPoint(k)-InletWaterTemp(k)));
                 
                 OutletWaterFlowRate(k) = TotWaterCoolingCoilRate(k)./(Cp.*abs(OutletWaterTemp(k)-InletWaterTemp(k)).*RhoWater(InletWaterTemp(k)));
                 
                 SenWaterCoolingCoilRate(k) = TotWaterCoolingCoilRate(k);
                 if OutletWaterFlowRate(k)>0.0077
                     keyboard
                 end
                 OutletAirIter.temp=OutletAirTempSetPoint(k);
                 OutletAirIter.W = InletAirHumRat(k);
                 OutletAirIter.RH= PsychRHFuTdbW(OutletAirIter.temp,OutletAirIter.W);
                 OutletAirIter.H  = PsychHFuTdbW(OutletAirTempSetPoint(k),OutletAirIter.W);
                 OutletAirIter.Twb = PsychTwbFuTdbW(OutletAirTempSetPoint(k),OutletAirIter.W);
                 OutletAirIter.flowrate=InletAirFlowRate(k);
             else
                 %!If both mass flow rates are zero, set outputs to inputs and return
                 OutletWaterTemp(k) = InletWaterTemp(k);
                 OutletAirTemp(k)   = InletAirTemp(k);
                 OutletAirHumRat(k) = InletAirHumRat(k);
                 TotWaterCoolingCoilRate(k)=0.0;
                 SenWaterCoolingCoilRate(k)=0.0;
             end
             
         else%(AirDewPointTemp(k) <=(OutletAirTempSetPoint(k)+1.5))
             CpAir = PsychCpAirFuTdbW(InletAirTemp(k),InletAirHumRat(k));
             Cp =  PsychCpWater(InletWaterTemp(k));
             TotWaterCoolingCoilRate(k) =InletAirMassFlowRate(k).*CpAir.*abs(InletAirTemp(k)-OutletAirTempSetPoint(k));
             
             WaterCoilType='CoolingCoil';
             InletWaterMassFlowRate(k)=TotWaterCoolingCoilRate(k)/(4.*Cp);
             [UAExternalTotal,UAInternalTotal,UACoilTotal]=CalcVariableUA(...
                 InletAirMassFlowRate,InletAirTemp,InletWaterMassFlowRate,InletWaterTemp,...
                 DesAirMassFlowRate,DesInletAirTemp,DesWaterMassFlowRate,DesInletWaterTemp,WaterCoilType,UADesign );
             if(InletWaterMassFlowRate(k) > 0)
                 
                 LMTD=TotWaterCoolingCoilRate(k)/UACoilTotal(k);
                 OutletWaterTemp(k) = InletAirTemp(k)- (LMTD.*2-(OutletAirTempSetPoint(k)-InletWaterTemp(k)));
                 
                 OutletWaterFlowRate(k) = TotWaterCoolingCoilRate(k)./(Cp.*abs(OutletWaterTemp(k)-InletWaterTemp(k)).*RhoWater(InletWaterTemp(k)));
                 
                 SenWaterCoolingCoilRate(k) = TotWaterCoolingCoilRate(k);
                 
                 if OutletWaterFlowRate(k)>0.0077
                     OutletWaterFlowRate(k)=0.0077;
                 end
                 
                 OutletAirIter.temp=OutletAirTempSetPoint(k);
                 OutletAirIter.W = InletAirHumRat(k);
                 OutletAirIter.RH= PsychRHFuTdbW(OutletAirIter.temp,OutletAirIter.W);
                 OutletAirIter.H  = PsychHFuTdbW(OutletAirTempSetPoint(k),OutletAirIter.W);
                 OutletAirIter.Twb = PsychTwbFuTdbW(OutletAirTempSetPoint(k),OutletAirIter.W);
                 OutletAirIter.flowrate=InletAirFlowRate(k);
             else
                 %!If both mass flow rates are zero, set outputs to inputs and return
                 OutletWaterTemp(k) = InletWaterTemp(k);
                 OutletAirTemp(k)   = InletAirTemp(k);
                 OutletAirHumRat(k) = InletAirHumRat(k);
                 TotWaterCoolingCoilRate(k)=0.0;
                 SenWaterCoolingCoilRate(k)=0.0;
             end
             
%          else
%              CpAir = PsychCpAirFuTdbW(InletAirTemp(k),InletAirHumRat(k));
%              Cp =  PsychCpWater(InletWaterTemp(k));
%              %             UAeth=UAExternalTotal(k)./CpAir;
%              
%              
%              EnthAirInlet = PsychHFuTdbW(InletAirTemp(k),InletAirHumRat(k));
%              EnthSatAirInletWaterTemp = PsychHFuTdbRH(InletWaterTemp(k),1);
%              EnthAirOutlet = PsychHFuTdbRH(OutletAirTempSetPoint(k),0.9);
%              TotWaterCoolingCoilRate(k)=InletAirMassFlowRate.*(EnthAirInlet-EnthAirOutlet);
%              
%              WaterCoilType='CoolingCoil';
%              InletWaterMassFlowRate(k)=TotWaterCoolingCoilRate(k)/(7.*Cp);
%              [UAExternalTotal,UAInternalTotal,UACoilTotal]=CalcVariableUA(...
%                  InletAirMassFlowRate,InletAirTemp,InletWaterMassFlowRate,InletWaterTemp,...
%                  DesAirMassFlowRate,DesInletAirTemp,DesWaterMassFlowRate,DesInletWaterTemp,WaterCoilType,UADesign );
%              UAeth=UAExternalTotal(k)./CpAir;
%              HLMD = TotWaterCoolingCoilRate(k)./UAeth;
%              if(InletWaterMassFlowRate(k) > 0)
%                  %             fun=@FuLMHD;
%                  %             EnthSatAirOutletWaterTemp = fzero(fun,EnthAirInlet);
%                  if (HLMD*2)<((EnthAirOutlet-EnthSatAirInletWaterTemp)/2)
%                      EnthSatAirOutletWaterTemp= EnthAirInlet;
%                  else
%                      EnthSatAirOutletWaterTemp = EnthAirInlet-(HLMD.*2-(EnthAirOutlet-EnthSatAirInletWaterTemp));
%                  end                 
%                  
%                  OutletWaterTemp(k) = PsychTdbFuHRH(EnthSatAirOutletWaterTemp ,1);
%                  OutletWaterFlowRate(k) = TotWaterCoolingCoilRate(k)./(Cp.*abs(OutletWaterTemp(k)-InletWaterTemp(k)).*RhoWater(InletWaterTemp(k)));
%                  
%                  SenWaterCoolingCoilRate(k)= CpAir.*InletAirMassFlowRate(k).*abs(InletAirTemp(k)-OutletAirTempSetPoint(k));
%                  if OutletWaterFlowRate(k)>0.0077
%                      keyboard
%                  end
%                  OutletAirIter.temp=OutletAirTempSetPoint(k);
%                  OutletAirIter.RH=1;
%                  OutletAirIter.W = PsychWFuTdbRH(OutletAirTempSetPoint(k),1);
%                  OutletAirIter.H = EnthAirOutlet ;
%                  OutletAirIter.Twb = PsychTwbFuTdbW(OutletAirTempSetPoint(k),OutletAirIter.W);
%                  OutletAirIter.flowrate=InletAirFlowRate(k);
%              else
%                  %!If both mass flow rates are zero, set outputs to inputs and return
%                  OutletWaterTemp(k) = InletWaterTemp(k);
%                  OutletAirTemp(k)   = InletAirTemp(k);
%                  OutletAirHumRat(k) = InletAirHumRat(k);
%                  TotWaterCoolingCoilRate(k)=0.0;
%                  SenWaterCoolingCoilRate(k)=0.0;
%              end
%              
         end
         InletAirIter.temp=InletAirTemp(k);
         InletAirIter.flowrate=InletAirFlowRate(k);
         
         InletAirIter.W=InletAirHumRat(k);
         InletAirIter.DewPTemp=AirDewPointTemp(k);
         InletWaterIter.temp=InletWaterTemp(k);
         
         ScheduleIter=Schedule(k);
         
         
         OutletAirTemp(k)=OutletAirIter.temp;
         OutletAirRH(k)=OutletAirIter.RH;
         OutletAirHumRat(k)=OutletAirIter.W;
         OutletAirEnthalpy(k)=OutletAirIter.H;
         OutletAirWetBulbTemp(k)=OutletAirIter.Twb;
         OutletAirFlowRate(k)=OutletAirIter.flowrate;
         
         
     else
         %!If both mass flow rates are zero, set outputs to inputs and return
         OutletWaterTemp(k) = InletWaterTemp(k);
         OutletAirTemp(k)   = InletAirTemp(k);
         OutletAirHumRat(k) = InletAirHumRat(k);
         TotWaterCoolingCoilRate(k)=0.0;
         SenWaterCoolingCoilRate(k)=0.0;
     end
     k=k+1;
    
 end
AirDeltaP=AirResistance*InletAirMassFlowRate.^2;
WaterDeltaP=WaterResistance*(OutletWaterFlowRate.*RhoWater(InletWaterTemp)).^2;

OutletAir.temp=OutletAirTemp;
OutletAir.RH=OutletAirRH;
OutletAir.W=OutletAirHumRat;
OutletAir.H=OutletAirEnthalpy;
OutletAir.Twb=OutletAirWetBulbTemp;
OutletAir.flowrate=OutletAirFlowRate;
OutletAir.pressure_loss=AirDeltaP;

OutletWater.temp=OutletWaterTemp;
OutletWater.flowrate=OutletWaterFlowRate;
OutletWater.pressure_loss=WaterDeltaP*10;




end