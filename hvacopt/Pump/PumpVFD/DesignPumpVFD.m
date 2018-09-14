function [OutletPump, PumpPower,PumpHeadPa,TotalEff,EconomicCost] = DesignPumpVFD...
    ( InletPump,PumpSpd, PumpVolFlow,NumON,Schedule,TempRise,OperationParameter,SizingParameter )
%PUMPVFD
% The performance of the variable speed pump is modeled using a series of
% polynomial approximations. They are comprised of polynomials representing
% head versus flow and speed, and efficiency versus flow and speed
% respectively. The head and efficiency characteristics are based on the
% manufacturers¡¯ data at the full speed operation and extended to the
% variable speed operation using the pump affinity laws (Bahnfleth and
% Peyer 2001, Bahnfleth et al. 2006). The motor efficiency (¦Çm) is modeled,
% which is a function of the fraction of the nameplate brake horsepower
% (Bernier and Bourret 1999). The VFD efficiency is modeled, which is a
% function of the fraction of the nominal speed (Bernier and Bourret 1999).
% The power input (Wpu,in) to a pump-motor-VFD set can be finally computed.
% The coefficients in these polynomials can be easily regressed using the
% pump performance data, the motor efficiency curve and VFD efficiency
% curve provided by the manufacturers.
% Description
%============================INPUT==================================
% InletPump:      a struct,inlet condition including temperature etc.
%                 InletPump.Temp: inlet temperature; [¡æ]
% PumpSpd:        a vector,pump speed ; [rpm];
% PumpVolFlow:    a vector,pump volume flowrate;[m3/s];
% parameter:      a struct, describing the coefficients required and
%                 nominal information
%===========================OUTPUT===================================
% PumpPower:      a vector, pump power; [w];
% PumpHeadPa:     a vector, pump head;  [pa];
% TotalEff:       a vector, total efficiency; [-]

%% CHECK INPUT
if nargin<7
    OperationParameter(1).coefficient=[-0.5121 0.3998 -0.1779 1.2704];     
    OperationParameter(2).coefficient=[-0.6061 0.0388 1.5378 0.0102];
    OperationParameter(3).coefficient=[0.96950 -9.4625];
    OperationParameter(4).coefficient=[0.50870 1.28300 -1.42000 0.58340];
    OperationParameter(1).nominal=[0.12 19 1450 0.809722];      % Q range: [0 4500] [L/min]; H range: [0 22] [m]; RatedPower:15kw
    OperationParameter(1).MotInWaterFrac=1;
    OperationParameter(1).SizeFactor=0.7;   % Minimum Speed ratio;
    OperationParameter(2).SizeFactor=1.2;   % Maximum speed ratio;
    OperationParameter(1).IsVFD=1;% Wether have VFDs? 1-yes; 0-no!
end

if nargin<8    
   SizingParameter.DesignPressure=1.0*1e6;
   SizingParameter.NumONMax=2;    
end


%% Initialization for INPUT
% Coefficients
a=OperationParameter(1).coefficient;
b=OperationParameter(2).coefficient;
c=OperationParameter(3).coefficient;
d=OperationParameter(4).coefficient;
% Pump head vesus speed and flowrate
a1=a(1);
a2=a(2);
a3=a(3);
a4=a(4);
% Wheel efficiency
b1=b(1);
b2=b(2);
b3=b(3);
b4=b(4);

% Motor efficiency
c1=c(1);
c2=c(2);
% VFD efficiency
d1=d(1);
d2=d(2);
d3=d(3);
d4=d(4);
% Nominal information
RatedSpd=OperationParameter(1).nominal(1,3); %[rpm];
RatedFlowRate=OperationParameter(1).nominal(1,1);
RatedHead=OperationParameter(1).nominal(1,2);
RatedEff=OperationParameter(1).nominal(1,4);
RatedPower=RatedFlowRate*1000*9.8*RatedHead/RatedEff;

% Power Loss
MotInWaterFrac=OperationParameter(1).MotInWaterFrac;

% Is VFD pump?
IsVFD=OperationParameter(1).IsVFD;
if IsVFD>1
    IsVFD=1;
end

% Sizing Paramter
DesignPressure=SizingParameter.DesignPressure;
NumONMax=SizingParameter.NumONMax;


% Inlet Condition
InletTemp=InletPump.temp;
% Water Characteristics
WaterRho=RhoWater(InletTemp);
CpWater=PsychCpWater(InletTemp);
g=9.8;

NumON=NumON.*Schedule;

%% Initialize the Local variables
% Nomalized Speed
MinSpdRatio=OperationParameter(1).SizeFactor;
MinSpd=MinSpdRatio*RatedSpd;
MaxSpdRatio=OperationParameter(2).SizeFactor;
MaxSpd=MaxSpdRatio*RatedSpd;
PumpSpd=min(max(MinSpd,PumpSpd),MaxSpd);
NormalSpd=PumpSpd./RatedSpd; %[Normalized Speed]

row=size(PumpVolFlow,1);

PumpEffRatedSpd=zeros(row,1);
PumpShaftPower=zeros(row,1);
MotorEff=zeros(row,1);
MotorInputPower=zeros(row,1);
VFDEff=zeros(row,1);
PowerLossToWater=zeros(row,1);
DeltaTemp=zeros(row,1);
PumpHeadMRatedSpd=zeros(row,1);

PumpEff=zeros(row,1);
PumpHeadPa=zeros(row,1);

PumpVolFlowPerParallel=zeros(row,1);
PumpVolFlowRatedSpd=zeros(row,1);

%% Initialize OUTPUT
OutletTemp=zeros(row,1);
OutletVolFlowPerParallel=zeros(row,1);
TotalEff=zeros(row,1);
PumpPower=zeros(row,1);
PumpHeadPaRatedSpd=zeros(row,1);


%% Simulate the VFD pump

% first, since the curve fit coefficients are for dimensionless cure, it
% has to be transformed for adopted model's purpose. That is,
a1_Trans=a1*RatedHead./(RatedFlowRate^3);
a2_Trans=a2*RatedHead./(RatedFlowRate^2);
a3_Trans=a3*RatedHead./(RatedFlowRate^1);
a4_Trans=a4*RatedHead./(RatedFlowRate^0);

b1_Trans=b1*RatedEff./(RatedFlowRate^3);
b2_Trans=b2*RatedEff./(RatedFlowRate^2);
b3_Trans=b3*RatedEff./(RatedFlowRate^1);
b4_Trans=b4*RatedEff./(RatedFlowRate^0);

k=1;
while k<=row
    %  !Determine the Fan Schedule for the Time step
    if(((NumON(k))~=0.0 ) || PumpVolFlow(k)>0.0)
        
        PumpVolFlowPerParallel(k)=PumpVolFlow(k)/NumON(k);
        PumpVolFlowPerParallel(k)=max(PumpVolFlowPerParallel(k),0.2*RatedFlowRate);
        
        PumpVolFlowRatedSpd(k)=PumpVolFlowPerParallel(k)/NormalSpd(k);
        
        % Pump head vesus speed and flowrate
        PumpHeadMRatedSpd(k)=a1_Trans*PumpVolFlowRatedSpd(k).^3+a2_Trans*PumpVolFlowRatedSpd(k).^2+a3_Trans*PumpVolFlowRatedSpd(k)+a4_Trans;%[m]
        PumpHeadPaRatedSpd(k)=WaterRho(k)*g.*PumpHeadMRatedSpd(k);% [Pa]
        PumpHeadPa(k)=PumpHeadPaRatedSpd(k)*NormalSpd(k).^2;
        
        % wheel efficiency;
        PumpEffRatedSpd(k)=b1_Trans*PumpVolFlowRatedSpd(k).^3+b2_Trans*PumpVolFlowRatedSpd(k).^2+b3_Trans*PumpVolFlowRatedSpd(k)+b4_Trans;
        PumpEff(k)=PumpEffRatedSpd(k)*(0.816+0.403*NormalSpd(k)-0.218*(NormalSpd(k)).^2);
        % PumpEff(k)=PumpEffRatedSpd(k)  NOT USED;
        % Shaft power
        PumpShaftPower(k)=PumpVolFlowPerParallel(k).*PumpHeadPa(k)./PumpEff(k);
        
        % Motor efficiency
        MotorEff(k)=c1*(1-exp(c2*NormalSpd(k)));
        MotorInputPower(k)=PumpShaftPower(k)./MotorEff(k);
        
        if IsVFD==1
        % VFD efficiency
        VFDEff(k)=d1+d2*NormalSpd(k)+d3*NormalSpd(k).^2+d4*NormalSpd(k).^3;
        else
          VFDEff(k)=1;
        end
        % Total efficiency
        TotalEff(k)=PumpEff(k).*MotorEff(k).*VFDEff(k);
        % Power required
        PumpPower(k)=PumpVolFlowPerParallel(k).*PumpHeadPa(k)./TotalEff(k);  %[w]
       
        if (TempRise~=0)
            PowerLossToWater(k)=PumpShaftPower(k) + (MotorInputPower(k) - PumpShaftPower(k)) .* MotInWaterFrac; %![W]
            DeltaTemp(k)=PowerLossToWater(k)./(WaterRho(k).*PumpVolFlowPerParallel(k).*CpWater(k));   %! [¡æ]
            OutletTemp(k)=InletTemp(k)+DeltaTemp(k);
            OutletVolFlowPerParallel(k)=PumpVolFlowPerParallel(k);
        else
            OutletTemp(k)=InletTemp(k);
            OutletVolFlowPerParallel(k)=PumpVolFlowPerParallel(k);
        end
    else
        PumpVolFlowPerParallel(k)=0;
        OutletTemp(k)=0;
        OutletVolFlowPerParallel(k)=0;
        TotalEff(k)=0;
        PumpPower(k)=0;
    end
    k=k+1;
end

  % Pump Parallels
PumpPower=PumpPower.*NumON;

%% Economic Equation
% Capitial Cost model
% Data from the RMeans Construction Data indicate that the capitial cost of
% Pump is function of its rated water flowrate
RatedFlowRate=min(RatedFlowRate,0.2);
CapitalCostUSDPump=3700*(0*RatedFlowRate.^3-14.888*RatedFlowRate.^2+10.759*RatedFlowRate+...
    1.0582); % x=[0.002~0.1]
% Data from the RMeans Construction Data indicate that the capitial cost of
% VFD is function of its rated horsepower
RatedPowerHP=RatedPower/0.7456998716e3;
CapitalCostUSDVFD=0*RatedPowerHP.^2+123.32*RatedPowerHP+2931.5;

CapitalCostUSDBaseline=CapitalCostUSDPump+CapitalCostUSDVFD*IsVFD;

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


%% Update the model
OutletPump.temp=OutletTemp;
OutletPump.flowrate=OutletVolFlowPerParallel.*NumON;

% Economic cost
EconomicCost.CapCost=CapitalCostUSD*NumONMax;
end

