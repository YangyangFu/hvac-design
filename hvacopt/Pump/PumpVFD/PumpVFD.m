function [OutletPump, PumpPower,PumpHeadPa,TotalEff] = PumpVFD...
    ( InletPump,PumpSpd, PumpVolFlow,NumON,Schedule,TempRise, parameter )
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
    parameter(1).coefficient=[0 -1844 17.62 21.9];      % Q range: [0 4500] [L/min]; H range: [0 22] [m]; RatedPower:15kw
    parameter(2).coefficient=[0 -288.8 31.62 0.001234];
    parameter(3).coefficient=[0.96950 -9.4625];
    parameter(4).coefficient=[0.50870 1.28300 -1.42000 0.58340];
    parameter(1).nominal=[0.07 15 1450 15000];     % nominal speed;[rpm]
    parameter(1).water=998.2;      % water density; [kg/m3]
    parameter(2).water=9.8;        % gravity acceleration;[m/s2]
    parameter(3).water=4200;       % specific heat capacity;[J/(kg.K)]
    parameter(1).MotInWaterFrac=1;
    parameter(1).SizeFactor=0.7;   % Minimum Speed ratio;
    parameter(2).SizeFactor=1.2;   % Maximum speed ratio;
end

%% Initialization for INPUT
% Coefficients
a=parameter(1).coefficient;
b=parameter(2).coefficient;
c=parameter(3).coefficient;
d=parameter(4).coefficient;
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
RatedSpd=parameter(1).nominal(1,3); %[rpm];
% Water Characteristics
RhoWater=parameter(1).water;
g=parameter(2).water;
CpWater=parameter(3).water;
% Power Loss
MotInWaterFrac=parameter(1).MotInWaterFrac;
% Inlet Condition
InletTemp=InletPump.temp;

NumON=NumON.*Schedule;

%% Initialize the Local variables
% Nomalized Speed
MinSpdRatio=parameter(1).SizeFactor;
MinSpd=MinSpdRatio*RatedSpd;
MaxSpdRatio=parameter(2).SizeFactor;
MaxSpd=MaxSpdRatio*RatedSpd;
PumpSpd=min(max(MinSpd,PumpSpd),MaxSpd);
NormalSpd=PumpSpd./RatedSpd; %[---]

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


k=1;
while k<=row
    %  !Determine the Fan Schedule for the Time step
    if(((NumON(k))~=0.0 ) || PumpVolFlow(k)>0.0)
        
        PumpVolFlowPerParallel(k)=PumpVolFlow(k)/NumON(k);
        
        PumpVolFlowRatedSpd(k)=PumpVolFlowPerParallel(k)/NormalSpd(k);
        % Pump head vesus speed and flowrate
        PumpHeadMRatedSpd(k)=a1*PumpVolFlowRatedSpd(k).^3+a2*PumpVolFlowRatedSpd(k).^2+a3*PumpVolFlowRatedSpd(k)+a4;%[m]
        PumpHeadPaRatedSpd(k)=RhoWater*g.*PumpHeadMRatedSpd(k);% [Pa]
        PumpHeadPa(k)=PumpHeadPaRatedSpd(k)*NormalSpd(k).^2;
        
        % wheel efficiency;
        PumpEffRatedSpd(k)=b1*PumpVolFlowRatedSpd(k).^3+b2*PumpVolFlowRatedSpd(k).^2+b3*PumpVolFlowRatedSpd(k)+b4;
        PumpEff(k)=PumpEffRatedSpd(k)*(0.816+0.403*NormalSpd(k)-0.218*(NormalSpd(k)).^2);
        % PumpEff(k)=PumpEffRatedSpd(k)  NOT USED;
        % Shaft power
        PumpShaftPower(k)=PumpVolFlowPerParallel(k).*PumpHeadPa(k)./PumpEff(k);
        
        % Motor efficiency
        MotorEff(k)=c1*(1-exp(c2*NormalSpd(k)));
        MotorInputPower(k)=PumpShaftPower(k)./MotorEff(k);
        
        % VFD efficiency
        VFDEff(k)=d1+d2*NormalSpd(k)+d3*NormalSpd(k).^2+d4*NormalSpd(k).^3;
        % Total efficiency
        TotalEff(k)=PumpEff(k).*MotorEff(k).*VFDEff(k);
        % Power required
        PumpPower(k)=PumpVolFlowPerParallel(k).*PumpHeadPa(k)./TotalEff(k);  %[w]
       
        if (TempRise~=0)
            PowerLossToWater(k)=PumpShaftPower(k) + (MotorInputPower(k) - PumpShaftPower(k)) .* MotInWaterFrac; %![W]
            DeltaTemp(k)=PowerLossToWater(k)./(RhoWater.*PumpVolFlowPerParallel(k).*CpWater);   %! [¡æ]
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

%% Update the model
OutletPump.temp=OutletTemp;
OutletPump.flowrate=OutletVolFlowPerParallel.*NumON;

end

