function [OutletAir,OutletFan,FanSpd]=FanVFD(InletAir,FanVolFlow,DeltaPressTot,FanWheelDia,Schedule,TempRise,parameter)
%% This model describes the fan with VFD, and can be used to simulate the part load condition.
% The FanVFD object is based upon combining: modified forms of fan, belt,
% motor, and variable-frequency-drive (VFD) element models (Stein and
% Hydeman 2004);
%% Description
%
%% Model equation
%
%
%          !
%          !       AUTHOR         Yangyang Fu, TongJi Unversity
%          !       DATE WRITTEN   Dec 2014
%          !       RE-ENGINEERED  na
%
%          ! PURPOSE OF THIS SUBROUTINE:
%          ! This subroutine simulates the component model fan.
%
%          ! METHODOLOGY EMPLOYED:
%          ! Calculate fan volumetric flow and corresponding fan static pressure rise,
%          !    using air-handling system characteristics and Sherman-Wray system curve model
%          ! Calculate fan air power using volumetric flow and fan static pressure rise
%          ! Calculate fan wheel efficiency using fan volumetric flow, fan static pressure rise,
%          !   fan characteristics, and Wray dimensionless fan static efficiency model
%          ! Calculate fan shaft power using fan air power and fan static efficiency
%          ! Calculate fan shaft speed and torque using Wray dimensionless fan airflow model
%          ! Calculate belt part-load efficiency using correlations and coefficients based on ACEEE data
%          ! Calculate belt input power using fan shaft power and belt efficiency
%          ! Calculate motor part-load efficiency using correlations and coefficients based on MotorMaster+ data
%          ! Calculate motor input power using belt input power and motor efficiency
%          ! Calculate VFD efficiency using correlations and coefficients based on DOE data
%          ! Calculate VFD input power using motor input power and VFD efficiency
%          ! Calculate combined efficiency of fan, belt, motor, and VFD
%          ! Calculate air temperature rise due to fan (and belt+motor if in airstream) power entering air-handler airflow
%          ! Calculate output node conditions
%
%          ! REFERENCES:
%          ! TBD
%
%
%  REAL(r64) MaxAirMassFlowRate ! Fan Max mass airflow [kg/s]
%  REAL(r64) MotInAirFrac       ! Fraction of fan power input to airstream
%
%  ! Local variables
%  REAL(r64) RhoAir             ! Air density [kg/m3]
%  REAL(r64) MassFlow           ! Fan mass airflow [kg/s]
%  REAL(r64) FanVolFlow         ! Fan volumetric airflow [m3/s]
%  REAL(r64) DuctStaticPress    ! Duct static pressure set point [Pa]
%  REAL(r64) DeltaPressTot      ! Total pressure rise across fan [N/m2 = Pa]
%  REAL(r64) FanOutletVelPress  ! Fan outlet velocity pressure [Pa]
%  REAL(r64) EulerNum           ! Fan Euler number [-]
%  REAL(r64) NormalizedEulerNum ! Normalized Fan Euler number [-]
%  REAL(r64) FanDimFlow         ! Fan dimensionless airflow [-]
%  REAL(r64) FanSpdRadS         ! Fan shaft rotational speed [rad/s]
%  REAL(r64) MotorSpeed         ! Motor shaft rotational speed [rpm]
%  REAL(r64) FanTrqRatio        ! Ratio of fan torque to max fan torque [-]
%  REAL(r64) BeltPLEff          ! Belt normalized (part-load) efficiency [-]
%  REAL(r64) MotorOutPwrRatio   ! Ratio of motor output power to max motor output power [-]
%  REAL(r64) MotorPLEff         ! Motor normalized (part-load) efficiency [-]
%  REAL(r64) VFDSpdRatio    = 0.d0 ! Ratio of motor speed to motor max speed [-]
%  REAL(r64) VFDOutPwrRatio = 0.d0 ! Ratio of VFD output power to max VFD output power [-]
%  REAL(r64) PowerLossToAir     ! Energy input to air stream (W)
%  REAL(r64) FanEnthalpyChange  ! Air enthalpy change due to fan, belt, and motor losses [kJ/kg]

%!=======================================================================================
% Check the INPUT
if nargin<7
    parameter.ManuDataMaxEff=[1499 12 0.919];
    parameter.FanMaxDimFlow =0.1;     %! Maximum dimensionless flow from maufacturer's table.
    parameter.PulleyDiaRatio=1;        %! The ratio between pulley motor diameter and pulley fan diameter;
    parameter.MaxAirMassFlowRate=100;  %! Maximum massflow rate;[kg/s]
    parameter.MotInAirFrac=1;          %! Motor in Air Fraction, used in temperature rise model.
    parameter.MotorRatedOutPwr=30000;  %! Motor rated power;[w]
    parameter.SizeFactor=1.1;          %! Motor power size factor ;
    parameter.RhoAir=1.29;             %! Air density;[kg/m3]
    parameter.CurveIndex=[1 1 1 1 1 1 1 1 1 1 1]'; %! Curve index for calling fitted curve.
    parameter.BeltType=2;              %! Medium loss belt is used by default;
    parameter.MotorType=2;             %! Medium efficienct motor is used by default;
end

% Start the program
PLFanEffNormCurveIndex=parameter.CurveIndex(1);
PLFanEffStallCurveIndex=parameter.CurveIndex(2);
DimFlowNormCurveIndex=parameter.CurveIndex(3);
DimFlowStallCurveIndex=parameter.CurveIndex(4);
PLBeltEffReg1CurveIndex=parameter.CurveIndex(5);
PLBeltEffReg2CurveIndex=parameter.CurveIndex(6);
PLBeltEffReg3CurveIndex=parameter.CurveIndex(7);
PLMotorEffCurveIndex=parameter.CurveIndex(8);
VFDEffCurveIndex=parameter.CurveIndex(9);
BeltMaxEffCurveIndex=parameter.CurveIndex(10);
MotorMaxEffCurveIndex=parameter.CurveIndex(11);

BeltType=parameter.BeltType;
MotorType=parameter.MotorType;

FanDeltaPressMaxEff=parameter.ManuDataMaxEff(1);                           %[Pa]
FanVolFlowMaxEff=parameter.ManuDataMaxEff(2);                              %[m3/s]
FanMaxEff=parameter.ManuDataMaxEff(3);                                     %! Maximum fan efficiency from manufacturer's data.


FanMaxDimFlow=parameter.FanMaxDimFlow;
PulleyDiaRatio=parameter.PulleyDiaRatio;
MaxAirMassFlowRate=parameter.MaxAirMassFlowRate;
MotInAirFrac=parameter.MotInAirFrac;
MotorRatedOutPwr=parameter.MotorRatedOutPwr;
SizeFactor=parameter.SizeFactor;

BeltTorqueTrans=0.167;  % Default value for V-belt;
MotorMaxOutPwr=MotorRatedOutPwr*SizeFactor;
BeltMaxOutPwr=MotorMaxOutPwr;
VFDMaxOutPwr=MotorMaxOutPwr;   % [w]

% Initialization for the INPUT

InletAirTemp=InletAir.temp;
InletAirRH=InletAir.RH;
InletAirHumRat=PsychWFuTdbRH(InletAirTemp,InletAirRH);       % [kg/kg(a)]
InletAirEnthalpy=PsychHFuTdbW(InletAirTemp,InletAirHumRat);  % [ J/kg(a)]

RhoAir=RhoAirFuTdbWP(InletAirTemp,InletAirHumRat);                                                   %! Air density;[kg/m3]
EuMaxEff=FanDeltaPressMaxEff*FanWheelDia.^4./(RhoAir.*FanVolFlowMaxEff.^2); %! Eu number at maximum efficiency from manufacturer's data.

MassFlow = FanVolFlow.* RhoAir;
MassFlow = min(MassFlow,MaxAirMassFlowRate);
FanOutletArea=pi*FanWheelDia.^2/4;

row=size(FanVolFlow,1);

% Initialization for the LOCAL VARIABLES
FanOutletVelPress=zeros(row,1);
DeltaPress=zeros(row,1);
EulerNum=zeros(row,1);
NormalizedEulerNum=zeros(row,1);
FanWheelEff=zeros(row,1);
FanDimFlow=zeros(row,1);
FanSpdRadS=zeros(row,1);
FanTrq=zeros(row,1);
FanTrqRatio=zeros(row,1);
BeltPLEff=zeros(row,1);
BeltEff=zeros(row,1);
MotorOutPwrRatio=zeros(row,1);
MotorPLEff=zeros(row,1);
MotEff=zeros(row,1);
VFDOutPwrRatio=zeros(row,1);
VFDEff=zeros(row,1);
FanEnthalpyChange=zeros(row,1);

% Initialization for the OUTPUT
FanAirPower=zeros(row,1);
FanShaftPower=zeros(row,1);
FanSpd=zeros(row,1);
MotorSpeed=zeros(row,1);
BeltInputPower=zeros(row,1);
MotorInputPower=zeros(row,1);
VFDInputPower=zeros(row,1);
FanPower=zeros(row,1);
FanEff=zeros(row,1);
PowerLossToAir=zeros(row,1);
OutletAirEnthalpy=zeros(row,1);
OutletAirHumRat=zeros(row,1);
OutletAirVolFlowRate=zeros(row,1);
OutletAirTemp=zeros(row,1);
OutletAirRH=zeros(row,1);

k=1;
while k<=row
    %  !Determine the Fan Schedule for the Time step
    if(((Schedule(k))>0.0 ) && MassFlow(k)>0.0)
        %!Fan is operating - calculate fan pressure rise, component efficiencies and power, and also air enthalpy rise
        
        %! Calculate fan static pressure rise using fan volumetric flow, std air density, air-handling system characteristics,
        %  and Sherman-Wray system curve model (assumes static pressure surrounding air distribution system is zero)
        
        FanOutletVelPress(k) = 0.5 .* RhoAir(k) .* (FanVolFlow(k) /FanOutletArea).^2; %!Fan outlet velocity pressure [Pa]
        %!Outlet velocity pressure cannot exceed total pressure rise
        FanOutletVelPress(k) = min(FanOutletVelPress(k), DeltaPressTot(k));
        DeltaPress(k) = DeltaPressTot(k) - FanOutletVelPress(k) ;%Fan static pressure rise [Pa]
        
        
        %! Calculate fan static air power using volumetric flow and fan static pressure rise
        FanAirPower(k) = FanVolFlow(k) .* DeltaPress(k) ;%![W]
       
        
        
        %! Calculate fan wheel efficiency using fan volumetric flow, fan static pressure rise,fan characteristics, and Wray dimensionless fan static efficiency model
        EulerNum(k) = (DeltaPress(k) * FanWheelDia.^4) / (RhoAir(k) * FanVolFlow(k).^2) ;%![-]
        NormalizedEulerNum(k) = log10(EulerNum(k)./ EuMaxEff(k));
        if (NormalizedEulerNum(k)  <= 0)
            FanWheelEff(k) = PLFanEffNormCurve(PLFanEffNormCurveIndex,NormalizedEulerNum(k));
        else
            FanWheelEff(k) = PLFanEffStallCurve(PLFanEffStallCurveIndex,NormalizedEulerNum(k));
        end
        FanWheelEff(k) = FanWheelEff(k) * FanMaxEff; %! [-]
        FanWheelEff(k) = max(FanWheelEff(k),0.01); %!Minimum efficiency is 1% to avoid numerical errors
        
        %! Calculate fan shaft power using fan static air power and fan static efficiency
        FanShaftPower(k) = FanAirPower(k) / FanWheelEff(k); %![W]
        
        %! Calculate fan shaft speed, fan torque, and motor speed using Wray dimensionless fan airflow model
        if (NormalizedEulerNum(k) <=0 )
            FanDimFlow(k) = DimFlowNormCurve(DimFlowNormCurveIndex,NormalizedEulerNum(k));  %![-]
        else
            FanDimFlow(k) = DimFlowStallCurve(DimFlowStallCurveIndex,NormalizedEulerNum(k)); %![-]
        end
        FanSpdRadS(k) = FanVolFlow(k) ./ (FanDimFlow(k) * FanMaxDimFlow *FanWheelDia.^3); %![rad/s]
        FanTrq(k) = FanShaftPower(k) / FanSpdRadS(k);  %![N-m]
        FanSpd(k) =  FanSpdRadS(k) * 30/pi; %![rpm, conversion factor is 30/PI]
        MotorSpeed(k) = FanSpd(k) * PulleyDiaRatio; %![rpm]
        
        %! Calculate belt part-load drive efficiency using correlations and coefficients based on ACEEE data
        % Direct-drive is represented using curve coefficients such that "belt" max eff and PL eff = 1.0
        BeltMaxTorque=9.545*BeltMaxOutPwr/FanSpd(k);
        FanTrqRatio(k) = FanTrq(k) / BeltMaxTorque; %![-]
        if (FanTrqRatio(k) <=BeltTorqueTrans)&&(PLBeltEffReg1CurveIndex~= 0)
            BeltPLEff(k) = PLBeltEffReg1Curve(PLBeltEffReg1CurveIndex,FanTrqRatio(k)); %![-]
        elseif ((FanTrqRatio(k) > BeltTorqueTrans)&&(FanTrqRatio(k) <= 1.0) && (PLBeltEffReg2CurveIndex ~= 0))
            BeltPLEff(k) =PLBeltEffReg2Curve(PLBeltEffReg2CurveIndex,FanTrqRatio(k));% ![-]
        elseif ((FanTrqRatio(k) > 1.0)&&(PLBeltEffReg3CurveIndex ~= 0))
            BeltPLEff(k) = PLBeltEffReg3Curve(PLBeltEffReg3CurveIndex,FanTrqRatio(k)); %![-]
        else
            BeltPLEff(k) = 1.0; % !Direct drive or no curve specified - use constant efficiency
        end
        %! Assume that maximum fan shaft power is motor maximum out power.
        RatedBeltPower=0.0013596*MotorMaxOutPwr;%![hp, conversion factor is 0.0013596]
        %! Calculate the belt maximum efficiency from fitted curve.
        ParameterBelt.type=BeltType;
        BeltMaxEff=BeltMaxEffCurve(BeltMaxEffCurveIndex,RatedBeltPower,ParameterBelt);
        BeltEff(k) = BeltMaxEff * BeltPLEff(k); %![-]
        BeltEff(k) = max(BeltEff(k),0.01);    %!Minimum efficiency is 1% to avoid numerical errors
        
        %! Calculate belt input power using fan shaft power and belt efficiency
        BeltInputPower(k) = FanShaftPower(k)./BeltEff(k); %![W]
        
        %! Calculate motor part-load efficiency using correlations and coefficients based on MotorMaster+ data
        MotorOutPwrRatio(k) = BeltInputPower(k) / MotorMaxOutPwr; %![-]
        
        %! Motor size determine its maximum efficiency
        ParameterMotorOutput.HP=0.0013596*MotorRatedOutPwr;%![hp, conversion factor is 0.0013596]
        
        if (PLMotorEffCurveIndex ~= 0)
            MotorPLEff(k) = PLMotorEffCurve(PLMotorEffCurveIndex,MotorOutPwrRatio(k),ParameterMotorOutput); % ![-]           
        else
            MotorPLEff(k) = 1.0; %!No curve specified - use constant efficiency
        end
        
        RatedMotorPower=0.0013596*MotorMaxOutPwr;%![hp, conversion factor is 0.0013596]
        
        %! Assume that a medium efficient motor is chosen.
        ParameterMotor.type=MotorType;
        MotorMaxEff=MotorMaxEffCurve(MotorMaxEffCurveIndex,RatedMotorPower, ParameterMotor);
        MotEff(k) = MotorMaxEff * MotorPLEff(k); %![-]
        MotEff(k) = max(MotEff(k),0.01);  %!Minimum efficiency is 1% to avoid numerical errors.
        
        %! Calculate motor input power using belt input power and motor efficiency
        MotorInputPower(k) = BeltInputPower(k) / MotEff(k); %![W]
        
        %! Calculate VFD efficiency using correlations and coefficients based on VFD type
        ParameterVFD.HP=0.0013596*MotorRatedOutPwr;
        if (VFDEffCurveIndex ~= 0)
            VFDOutPwrRatio(k) = MotorInputPower(k) ./ VFDMaxOutPwr; %![-]
            VFDEff(k) = VFDEffCurve(VFDEffCurveIndex,VFDOutPwrRatio(k),ParameterVFD); %![-]
        else
            %! No curve specified - use constant efficiency
            
            VFDEff(k) = 0.97;
        end
        
        VFDEff(k) = max(VFDEff(k),0.01); %!Minimum efficiency is 1% to avoid numerical errors
        
        %! Calculate VFD input power using motor input power and VFD efficiency
        VFDInputPower(k) = MotorInputPower(k) ./ VFDEff(k); %![W]
        FanPower(k) =VFDInputPower(k); %![W]
        
        %! Calculate combined fan system efficiency: includes fan, belt, motor, and VFD
        %! Equivalent to Fan(FanNum)%FanAirPower / Fan(FanNum)%FanPower
        FanEff(k) = FanWheelEff(k) .* BeltEff(k) .*MotEff(k) .* VFDEff(k);
        
        %! Calculate air enthalpy and temperature rise from power entering air stream from fan wheel, belt, and motor
        %! Assumes MotInAirFrac applies to belt and motor but NOT to VFD
        %! Use temperature rise model
        if (TempRise~=0)
            PowerLossToAir(k) = FanShaftPower(k)...
                + (MotorInputPower(k) - FanShaftPower(k)) .* MotInAirFrac; %![W]
            FanEnthalpyChange(k) = PowerLossToAir(k) / MassFlow(k); %![J/kg]
            OutletAirEnthalpy(k) = InletAirEnthalpy(k) + FanEnthalpyChange(k); %![J/kg]
            
            %! This fan does not change the moisture or mass flow across the component
            OutletAirHumRat(k)       = InletAirHumRat(k); %![-]
            OutletAirVolFlowRate(k) = FanVolFlow(k); %![m3/s]
            OutletAirTemp(k) = PsychTdbFuHW(OutletAirEnthalpy(k),OutletAirHumRat(k));
            OutletAirRH(k)=PsychRHFuTdbW(OutletAirTemp(k),OutletAirHumRat(k));
        else
            PowerLossToAir(k) = 0.0;
            OutletAirEnthalpy(k) = InletAirEnthalpy(k);
            OutletAirHumRat(k) = InletAirHumRat(k);
            OutletAirVolFlowRate(k) = FanVolFlow(k);
            OutletAirTemp(k) = InletAirTemp(k);
            OutletAirRH(k)=InletAirRH(k);
        end
    else
        % Fan is OFF and not operating -- no power consumed and zero mass flow rate
        FanPower(k) = 0.0;
        FanShaftPower(k) = 0.0;
        PowerLossToAir(k) = 0.0;
        OutletAirVolFlowRate(k) = 0.0;
        OutletAirHumRat(k) = InletAirHumRat(k);
        OutletAirEnthalpy(k) = InletAirEnthalpy(k);
        OutletAirTemp(k) = InletAirTemp(k);
        OutletAirRH(k)=InletAirRH(k);
        
        DeltaPress(k) = 0.0;
        FanAirPower(k) = 0.0;
        FanWheelEff(k) = 0.0;
        FanSpd(k) = 0.0;
        FanTrq(k) = 0.0;
        BeltEff(k) = 0.0;
        BeltInputPower(k) = 0.0;
        MotEff(k) = 0.0;
        MotorInputPower(k) = 0.0;
        MotorSpeed=0.0;
        VFDEff(k) = 0.0;
        VFDInputPower(k) = 0.0;
        FanEff(k) = 0.0;
    end
    k=k+1;
end

% Update the output of this model
OutletAir.temp=OutletAirTemp;
OutletAir.RH=OutletAirRH;
OutletAir.humidity=OutletAirHumRat;
OutletAir.enthalpy=OutletAirEnthalpy;

OutletFan.flow=OutletAirVolFlowRate;
OutletFan.FanPower=FanPower;
OutletFan.efficiency=FanEff;
OutletFan.MotorSpeed=MotorSpeed;

end