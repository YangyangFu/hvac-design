function [OutletPump,PumpSpd,PumpPower,TotalEff,PumpHeadPa]=PumpVFDForSpd...
    (InletPump,PumpHeadPa, PumpVolFlow,NumON,Schedule,TempRise, parameter)
% PUMPVFDFORSPD
% This model calculates VFD speed from given head and flowrate.It use the
% PumpVFD model for iteration.
%============================INPUT=====================================
% InletPump:      a struct,inlet condition including temperature etc.
% PumpSpd:        a vector,pump speed ; [rpm];
% PumpVolFlow:    a vector,pump volume flowrate;[m3/s];
% parameter:      a struct, describing the coefficients required and
%                 nominal information
%===========================OUTPUT=====================================
% PumpPower:      a vector, pump power; [w];
% PumpHead:       a vector, pump head;  [pa];
% TotalEff:       a vector, total efficiency; [-]



%% check the INPUT
if nargin<7
    parameter(1).coefficient=[0 -1844 17.62 21.9];      % Q range: [0 4500] [L/min]; H range: [0 22] [m];
    parameter(2).coefficient=[0 -288.8 31.62 0.001234];
    parameter(3).coefficient=[0.96950 -9.4625];
    parameter(4).coefficient=[0.50870 1.28300 -1.42000 0.58340];
    parameter(1).nominal=[0.075 17 1450];     % nominal speed;[rpm]
    parameter(1).water=998.2;      % water density; [kg/m3]
    parameter(2).water=9.8;        % gravity acceleration;[m/s2]
    parameter(3).water=4200;       % specific heat capacity;[J/(kg.K)]
    parameter(1).MotInWaterFrac=1;
    parameter(1).SizeFactor=0.5;   % Minimum Speed ratio;
    parameter(2).SizeFactor=1.2;   % Maximum speed ratio;
end


%% Initialize INPUT
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
nominal=parameter.nominal;
RatedSpd=nominal(1,3); %[rpm];
% Water Characteristics
RhoWater=parameter(1).water;
g=parameter(2).water;
CpWater=parameter(3).water;
% Power Loss
MotInWaterFrac=parameter(1).MotInWaterFrac;
% Inlet Condition
InletTemp=InletPump.temp;

NumON=NumON.*Schedule;

%% Initialize local variables
PumpHeadM=PumpHeadPa./(RhoWater*g);
MinSpdRatio=parameter(1).SizeFactor;
MinSpd=MinSpdRatio*RatedSpd;

MaxSpdRatio=parameter(2).SizeFactor;
MaxSpd=MaxSpdRatio*RatedSpd;

row=size(PumpVolFlow,1);

NormalSpd=zeros(row,1);
PumpEff=zeros(row,1);
PumpShaftPower=zeros(row,1);
MotorEff=zeros(row,1);
MotorInputPower=zeros(row,1);
VFDEff=zeros(row,1);
PowerLossToWater=zeros(row,1);
DeltaTemp=zeros(row,1);
PumpEffRatedSpd=zeros(row,1);

%% Initialize OUTPUT
PumpSpd=zeros(row,1);
OutletTemp=zeros(row,1);
OutletVolFlow=zeros(row,1);
TotalEff=zeros(row,1);
PumpPower=zeros(row,1);

%% Simulate the model

k=1;
while k<=row
    %  !Determine the Fan Schedule for the Time step
    if(((NumON(k))~=0.0 ) || PumpVolFlow(k)>0.0)
       
        % water flow in each pump
        PumpVolFlow(k)=PumpVolFlow(k)./NumON(k);
        
        % Initial Value for Iteration;
        PumpSpdInit=RatedSpd;
        PumpHead=PumpHeadM(k);
        % Equation handle
        FUN=@SpeedEquation;
        % Iteration algorithm
        PumpSpdIndex=fsolve(FUN,PumpSpdInit);
        PumpSpdIndex=min(max(MinSpd,PumpSpdIndex),MaxSpd);
        
        PumpSpd(k,1)=PumpSpdIndex;
        NormalSpd(k,1)=PumpSpd(k,1)./RatedSpd;
        
        PumpHeadM(k)=a1*PumpVolFlow(k).^3./NormalSpd(k,1)+a2*PumpVolFlow(k).^2+a3*(NormalSpd(k,1))*PumpVolFlow(k)+a4*(NormalSpd(k,1)).^2;
        PumpHeadPa(k)=PumpHeadM(k)*(RhoWater*g);
        
        % wheel efficiency;
        PumpEffRatedSpd(k)=b1*(PumpVolFlow(k)/NormalSpd(k)).^3+b2*(PumpVolFlow(k)./NormalSpd(k)).^2.+b3*(PumpVolFlow(k)./NormalSpd(k))+b4;
        PumpEff(k)=PumpEffRatedSpd(k)*(0.816+0.403*NormalSpd(k)-0.218*(NormalSpd(k)).^2);
        % Shaft power
        PumpShaftPower(k)=PumpVolFlow(k).*PumpHeadPa(k)./PumpEff(k);
        
        % Motor efficiency
        MotorEff(k)=c1*(1-exp(c2*NormalSpd(k)));
        MotorInputPower(k)=PumpShaftPower(k)./MotorEff(k);
        
        % VFD efficiency
        VFDEff(k)=d1+d2*NormalSpd(k)+d3*NormalSpd(k).^2+d4*NormalSpd(k).^3;
        % Total efficiency
        TotalEff(k)=PumpEff(k).*MotorEff(k).*VFDEff(k);
        % Power required
        PumpPower(k)=PumpVolFlow(k).*PumpHeadPa(k)./(TotalEff(k));  %[w]
        
        % Total power of pump parallels
        PumpPower(k)=NumON(k).*PumpPower(k);
        
        % Temperature rise model
        if (TempRise~=0)
            PowerLossToWater(k)=PumpShaftPower(k) + (MotorInputPower(k) - PumpShaftPower(k)) .* MotInWaterFrac; %![W]
            DeltaTemp(k)=PowerLossToWater(k)./(RhoWater.*PumpVolFlow(k).*CpWater);   %! [¡æ]
            OutletTemp(k)=InletTemp(k)+DeltaTemp(k);
            OutletVolFlow(k)=NumON(k).*PumpVolFlow(k);
        else
            OutletTemp(k)=InletTemp(k);
            OutletVolFlow(k)=NumON(k).*PumpVolFlow(k);
        end
    else
        PumpSpd(k)=0;       
        OutletTemp(k)=0;
        OutletVolFlow(k)=0;
        TotalEff(k)=0;
        PumpPower(k)=0;
    end   
    
    k=k+1;
end


%% Update the model
OutletPump.Temp=OutletTemp;
OutletPump.VolFlow=OutletVolFlow;

% Iteration equation for pump speed
    function y=SpeedEquation(PumpSpdIndex)
        % Nomalized Speed
        NormalSpdIndex=PumpSpdIndex./RatedSpd; %[---]
        % Pump head vesus speed and flowrate
        y=a1*PumpVolFlow(k).^3./NormalSpdIndex+a2*PumpVolFlow(k).^2+a3*(NormalSpdIndex)*PumpVolFlow(k)+a4*(NormalSpdIndex).^2-PumpHead;%[m]
    end
end