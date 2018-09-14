function [OutletPump,PumpSpd,PumpPower,TotalEff,PumpHeadPa,EconomicCost]=DesignPumpVFDForSpd...
    (InletPump,PumpHeadPa, PumpVolFlow,NumON,Schedule,TempRise,Parameter,SizingParameter)
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
    Parameter(1).coefficient=[-0.5121 0.3998 -0.1779 1.2704];
    Parameter(2).coefficient=[-0.6061 0.0388 1.5378 0.0102];
    Parameter(3).coefficient=[0.96950 -9.4625];
    Parameter(4).coefficient=[0.50870 1.28300 -1.42000 0.58340];
    Parameter(1).nominal=[0.12 19 1450 0.809722];      % Q range: [0 4500] [L/min]; H range: [0 22] [m]; RatedPower:15kw
    Parameter(1).MotInWaterFrac=1;
    Parameter(1).SizeFactor=0.7;   % Minimum Speed ratio;
    Parameter(2).SizeFactor=1.2;   % Maximum speed ratio;
    Parameter(1).IsVFD=1;% Wether have VFDs? 1-yes; 0-no!
end

if nargin<8
    SizingParameter.DesignPressure=1.0*1e6;
    SizingParameter.NumONMax=2;
end


%% Initialize INPUT
% Coefficients
a=Parameter(1).coefficient;
b=Parameter(2).coefficient;
c=Parameter(3).coefficient;
d=Parameter(4).coefficient;
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
RatedSpd=Parameter(1).nominal(1,3); %[rpm];
RatedFlowRate=Parameter(1).nominal(1,1);
RatedHead=Parameter(1).nominal(1,2);
RatedEff=Parameter(1).nominal(1,4);
RatedPower=RatedFlowRate*1000*9.8*RatedHead/RatedEff;

% Is VFD pump?
IsVFD=Parameter(1).IsVFD;
if IsVFD>1
    IsVFD=1;
end

% Sizing Paramter
DesignPressure=SizingParameter.DesignPressure;
NumONMax=SizingParameter.NumONMax;


% Power Loss
MotInWaterFrac=Parameter(1).MotInWaterFrac;
% Inlet Condition
InletTemp=InletPump.temp;

% Water Characteristics
WaterRho=RhoWater(InletTemp);
CpWater=PsychCpWater(InletTemp);
g=9.8;

NumON=NumON.*Schedule;

%% Initialize local variables
PumpHeadM=PumpHeadPa./(WaterRho*g);
MinSpdRatio=Parameter(1).SizeFactor;
MinSpd=MinSpdRatio*RatedSpd;

MaxSpdRatio=Parameter(2).SizeFactor;
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
    if(((NumON(k))~=0.0 ) && PumpVolFlow(k)>0.0)
        
        % water flow in each pump
        PumpVolFlow(k)=PumpVolFlow(k)./NumON(k);
        PumpVolFlow(k)=max(PumpVolFlow(k),0.2*RatedFlowRate);
        
        % Initial Value for Iteration;
%         PumpSpdInit=RatedSpd;
        PumpHead=PumpHeadM(k);
        PolyCoeff=[a4_Trans,a3_Trans*PumpVolFlow(k),(a2_Trans*PumpVolFlow(k).^2-PumpHead),a1_Trans*PumpVolFlow(k).^3];
        Root=roots(PolyCoeff);
        count=0;
        for ii=1:3
            if (isreal(Root(ii))&&Root(ii)>0.2)
                count=count+1;
                if (Root(ii)<1.2)
                    NormalSpdIndex=Root(ii);
                else
                    NormalSpdIndex=1.2;
                end
            else
                NormalSpdIndex=0.2;
            end
        end
        if count>1
            keyboard;
        end
        PumpSpdIndex = NormalSpdIndex*RatedSpd;
%         
        
        % Equation handle
%         FUN=@SpeedEquation;
%         % Iteration algorithm
%         [PumpSpdIndex,~,exitflag]=fzero(FUN,PumpSpdInit);
%         
%         
%         if exitflag>0
%             PumpSpdIndex=min(max(MinSpd,PumpSpdIndex),MaxSpd);
%         else
%             PumpSpdIndex=MaxSpd;
%         end
    
        %%
        PumpSpd(k,1)=PumpSpdIndex;
        NormalSpd(k,1)=PumpSpd(k,1)./RatedSpd;
        
        PumpHeadM(k)=a1_Trans*PumpVolFlow(k).^3./NormalSpd(k,1)+a2_Trans*PumpVolFlow(k).^2+a3_Trans*(NormalSpd(k,1))*PumpVolFlow(k)+a4_Trans*(NormalSpd(k,1)).^2;
        PumpHeadPa(k)=PumpHeadM(k)*(WaterRho(k)*g);
        
        % wheel efficiency;
        PumpEffRatedSpd(k)=b1_Trans*(PumpVolFlow(k)/NormalSpd(k)).^3+b2_Trans*(PumpVolFlow(k)./NormalSpd(k)).^2.+b3_Trans*(PumpVolFlow(k)./NormalSpd(k))+b4_Trans;
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
            DeltaTemp(k)=PowerLossToWater(k)./(WaterRho(k).*PumpVolFlow(k).*CpWater(k));   %! [¡æ]
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
    CapitalCostUSD=CapitalCostUSDBaseline*(1+0.10);
elseif DesignPressure==2.5*1e6
    CapitalCostUSD=CapitalCostUSDBaseline*(1+0.15);
elseif DesignPressure>2.5*1e6
    CapitalCostUSD=CapitalCostUSDBaseline*(1+0.20);
end

%% Update the model
OutletPump.Temp=OutletTemp;
OutletPump.VolFlow=OutletVolFlow;

% Economic cost
EconomicCost.CapCost=CapitalCostUSD*NumONMax;

% Iteration equation for pump speed
%     function y=SpeedEquation(PumpSpdIndex)
%         % Nomalized Speed
%         NormalSpdIndex=PumpSpdIndex./RatedSpd; %[---]
%         % Pump head vesus speed and flowrate
%         y=a1_Trans*PumpVolFlow(k).^3./NormalSpdIndex+a2_Trans*PumpVolFlow(k).^2+a3_Trans*(NormalSpdIndex)*PumpVolFlow(k)+a4_Trans*(NormalSpdIndex).^2-PumpHead;%[m]
%     end
  
end