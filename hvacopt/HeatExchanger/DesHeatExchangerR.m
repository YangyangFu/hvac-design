function [ColdSideOutlet,HotSideOutlet,HeatFlow,Effectiveness,EconomicCost]=DesHeatExchanger...
    (ColdSideInlet,HotSideInlet,HotSideOutletTemp,UADesign,ParallelNum,AvailSchedValue,HXTypeOf,parameter_HX,SizingParameter)
%%4 This model calculate the flowrate required in cold side through hot side
% inlet and outlet information;
%                  author: fengfan
%=====================INPUT===================
% ColdSideInlet:   a struct, describes the cold side inlet condition;
%                    ColdSideInlet.temp: a vector,describes the cold
%                    side inlet temperature;[C]
% HotSideInlet:    a struct, describes the hot side inlet condition;
%                    HotSideInlet.temp: a vector,describes the hot side
%                    inlet temperature;[C]
%                    HotSideInlet.flowrate: a vector, describes the hot
%                    side flowrate;[m3/s]
% HotSideOutletTemp: a vector, describes the required hot side outlet
%                    temperature; [C]
% UA:               a vector, specified by the user, describes the heat
%                   exchanger's ability of heat transfer;[W/K]
% AvailSchedValue:  a vector, describes available schedule provided for the
%                   heat exchanger by the user;[0,1]
% HXTypeOf:          an integer, describes the type of heat exchanger, which
%                   affects the effectiveness of such heat exchanger
%                   0-----ideal type;
%                   1-----Plate frame;
%                   2-----Parallel Flow;
%                   3-----Counter Flow;
%                  other value----no such type;
% parameter_HX:    a struct, describes the parameter required in this
%                  model;
%                 parameter_HX.resistance: a veactor,pressure loss coefficients in
%                 cold side and hot side respectively;
%====================Output=========================
% ColdSideOutlet:
% HotSideOutlet:
% HeatFlow:
% Effectiveness:
%%

%@@@@@@@ Check the Model Input
if nargin<8
    parameter_HX.resistance=[4.5 4.5];
    parameter_HX.nominal=[0.0975 0.0975];% nominal flowrate in each parallel of this heat exchanger;
    parameter_HX.UAParameter=[0.2675 0.2675]; % m,n
end

%% @@@@@@@@ Initialize the Input
RatedFlowRate=parameter_HX.nominal(1,1);
m=parameter_HX.UAParameter(1);  % UA correction coefficient
n=parameter_HX.UAParameter(2);

ColdSideResis=parameter_HX.resistance(1);
HotSideResis=parameter_HX.resistance(2);

ColdSideNomFlowPerParallel=parameter_HX.nominal(1);
HotSideNomFlowPerParallel=parameter_HX.nominal(2);

ColdSideInletTemp=ColdSideInlet.temp;
HotSideInletTemp=HotSideInlet.temp;

ColdFluidCp = PsychCpWater(ColdSideInletTemp);
HotFluidCp = PsychCpWater(HotSideInletTemp);

ColdInletdensity =RhoWater(ColdSideInletTemp);
HotInletDensity = RhoWater(HotSideInletTemp);

HotSideFlowRate=HotSideInlet.flowrate;

DesignPressure=SizingParameter.DesignPressure;
ParallelNumMax=SizingParameter.NumONMax;

MinParallelMassFlowrate=0.2*ColdSideNomFlowPerParallel*ColdInletdensity;
MaxParallelMassFlowrate=1.2*ColdSideNomFlowPerParallel*ColdInletdensity;

%@@@@@@@@@ Initialize the local variables
row=size(HotSideFlowRate,1);

[ColdSideFlowRate,ColdSideOutletTemp,ColdSideDeltaP,HotSideDeltaP]=deal(zeros(row,1));
[UA,ParaHotSideFlowRate,ParaHotMassFlowRate,ParaColdMassFlowRate,HotCapRate]=deal(zeros(row,1));


[HeatFlow,Effectiveness,ParaHeatTransRate] = deal(zeros(row,1));

i=1;
while i<=row
    if HotSideFlowRate(i)~=0
        HotSideFlowRate(i)=max(HotSideFlowRate(i),0.2*RatedFlowRate);
        ParaHotSideFlowRate(i) =HotSideFlowRate(i)./max(0.01,ParallelNum(i));
        ParaHotSideFlowRate(i)=max(ParaHotSideFlowRate(i),0.2*HotSideNomFlowPerParallel);
        
        ParaHotMassFlowRate(i) =  ParaHotSideFlowRate(i) .* HotInletDensity(i).*AvailSchedValue(i);
        
        HotCapRate(i)  = HotFluidCp(i) .* ParaHotMassFlowRate(i);
        ParaHeatTransRate(i) = HotCapRate(i).*(HotSideInletTemp(i)-HotSideOutletTemp(i));
        % UA correction
        UA(i)=UADesign*(ParaHotSideFlowRate(i)./HotSideNomFlowPerParallel).^(m+n);
        %用LMTD的方法，UA correction更改(linear mean Temperature difference)
        LMTD(i) = ParaHeatTransRate(i)./UA(i);
        t1=HotSideOutletTemp(i)-ColdSideInletTemp(i);
        
        c1=[0.001891,-0.04092,0.5711,0.4314-LMTD(i)./t1]; % the fitting coefficients in polynomial equations
        
        r=roots(c1);
        
        if anyreal(r)
            [~,realOne]=anyreal(r);
            realIndex= realOne==1;
            realValue=r(realIndex);
            
            ind=find(realValue<=10 & realValue>=0);
            
            if isempty(ind)
                x=1;
                
            else
                x=realValue(ind);
            end
            
            
            ColdSideOutletTemp(i)=HotSideInletTemp(i)-t1*x;
            
            % Then the massflow rate on water side.
            ParaColdMassFlowRate(i,:)=ParaHeatTransRate(i)./ColdFluidCp(i)./(ColdSideOutletTemp(i)-ColdSideInletTemp(i)); % Kg/s
            
            ParaColdMassFlowRate(i,:)=min(max(ParaColdMassFlowRate(i,:),MinParallelMassFlowrate(i)),MaxParallelMassFlowrate(i));
            
            ColdSideOutletTemp(i)=ParaHeatTransRate(i)./(ColdFluidCp(i)*ParaColdMassFlowRate(i,:))+ColdSideInletTemp(i);
            
            %!Pressure Drop
            ColdSideDeltaP(i)=ColdSideResis.*ParaColdMassFlowRate(i).^2;
            HotSideDeltaP(i)=HotSideResis.*ParaHotMassFlowRate(i).^2;
            
            HeatFlow(i)=ParaHeatTransRate(i)*ParallelNum(i);
            ColdSideFlowRate(i)=ParaColdMassFlowRate(i,:)./ColdInletdensity(i)*ParallelNum(i);
            
            
        else
            ColdSideFlowRate(i)=0;
            ColdSideOutletTemp(i)=0;
            ColdSideDeltaP(i)=0;
            
            HotSideDeltaP(i)=0;
            HotSideOutletTemp(i)=HotSideInletTemp(i);
            
            HeatFlow(i)=0;
            Effectiveness(i)=0;
        end
        
    else
        ColdSideFlowRate(i)=0;
        ColdSideOutletTemp(i)=0;
        ColdSideDeltaP(i)=0;
        
        HotSideDeltaP(i)=0;
        HotSideOutletTemp(i)=HotSideInletTemp(i);
        
        HeatFlow(i)=0;
        Effectiveness(i)=0;
    end
    i=i+1;
end



%% Economic Moel
% Capitial Cost model
% Data from the RMeans Construction Data indicate that the capitial cost of
% Plate Heat Exchanger is function of its rated water flowrate
CapitalCostUSDBaseline=34800*(-66.756*ColdSideNomFlowPerParallel.^2+37.664*ColdSideNomFlowPerParallel...
    +0.0622);% x[0.02~0.13]
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
%% @@@@@@@@ Model OUTPUT
ColdSideOutlet.temp = ColdSideOutletTemp;
ColdSideOutlet.flowrate = ColdSideFlowRate;
ColdSideOutlet.pressure_loss=ColdSideDeltaP;

HotSideOutlet.temp=HotSideOutletTemp;
HotSideOutlet.flowrate=HotSideFlowRate;
HotSideOutlet.pressure_loss=HotSideDeltaP;

% Economic cost
EconomicCost.CapCost=CapitalCostUSD*ParallelNumMax;
end