function [ColdSideOutlet,HotSideOutlet,HeatFlow,Effectiveness,EconomicCost]=DesHeatExchanger...
    (ColdSideInlet,HotSideInlet,HotSideOutletTemp,UADesign,ParallelNum,AvailSchedValue,HXTypeOf,parameter_HX,SizingParameter)
%%4 This model calculate the flowrate required in cold side through hot side
% inlet and outlet information;
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

%@@@@@@@@ Initialize the Input
RatedFlowRate=parameter_HX.nominal(1,1);

ColdSideInletTemp=ColdSideInlet.temp;

HotSideInletTemp=HotSideInlet.temp;
HotSideFlowRate=HotSideInlet.flowrate;

%@@@@@@@@@ Initialize the local variables
row=size(HotSideFlowRate,1);
ColdSideFlowRate=zeros(row,1);
ColdSideOutletTemp=zeros(row,1);
% DeltaP
ColdSideDeltaP=zeros(row,1);
HotSideDeltaP=zeros(row,1);

HeatFlow=zeros(row,1);
Effectiveness=zeros(row,1);

ColdSideFlowRate_init=zeros(row,1);

k=1;
while k<=row
    
    if HotSideFlowRate(k)~=0
        HotSideFlowRate(k)=max(HotSideFlowRate(k),0.2*RatedFlowRate);
        fun=@HXEquation;
        
        ColdSideFlowRate_init(k)=HotSideFlowRate(k);
        
        if (ColdSideFlowRate_init(k)<1e-10)||isnan(ColdSideFlowRate_init(k))||isinf(ColdSideFlowRate_init(k))
            ColdSideFlowRate_init(k)=RatedFlowRate;
        end
        
        options=optimoptions('fsolve','Algorithm','levenberg-marquardt');
        [ColdSideFlowRate(k),~,exitflag]=fsolve(fun,ColdSideFlowRate_init(k),options);
        
        if exitflag>0
            ColdSideFlowRate(k)=max(ColdSideFlowRate(k),0.2*RatedFlowRate);
            ColdSideOutletTemp(k)=ColdOutlet.temp;
            ColdSideDeltaP(k)=ColdOutlet.pressure_loss;
            
            HotSideDeltaP(k)=HotOutlet.pressure_loss;
            HotSideOutletTemp(k)=HotOutlet.temp;
            
            HeatFlow(k)=HeatTransRate;
            Effectiveness(k)=Eff;
        else
            ColdSideFlowRate(k)=RatedFlowRate;
            ColdSideOutletTemp(k)=ColdSideInletTemp(k)+6;
            ColdSideDeltaP(k)=parameter_HX.resistance(1,1)*(RatedFlowRate.*RhoWater(ColdSideInletTemp(k))).^2;
            
            HotSideDeltaP(k)=parameter_HX.resistance(1,2)*(RatedFlowRate.*RhoWater(HotSideInletTemp(k))).^2;
            HotSideOutletTemp(k)=ColdSideInletTemp(k)+1;
            
            HeatFlow(k)=RatedFlowRate*RhoWater(ColdSideInletTemp(k))*PsychCpWater(ColdSideInletTemp(k))*6;
            Effectiveness(k)=1;
        end

    else
        ColdSideFlowRate(k)=0;
        ColdSideOutletTemp(k)=0;
        ColdSideDeltaP(k)=0;
        
        HotSideDeltaP(k)=0;
        HotSideOutletTemp(k)=HotSideInletTemp(k);
        
        HeatFlow(k)=0;
        Effectiveness(k)=0;
    end    
    
    k=k+1;
end

%@@@@@@@@ Model OUTPUT
ColdSideOutlet.temp=ColdSideOutletTemp;
ColdSideOutlet.flowrate=ColdSideFlowRate;
ColdSideOutlet.pressure_loss=ColdSideDeltaP;

HotSideOutlet.temp=HotSideOutletTemp;
HotSideOutlet.flowrate=HotSideFlowRate;
HotSideOutlet.pressure_loss=HotSideDeltaP;



    function y=HXEquation(ColdSideFlowRate)
        
        ColdSideInlet.temp=ColdSideInletTemp(k);
        ColdSideInlet.flowrate=ColdSideFlowRate;
        HotSideInlet.temp=HotSideInletTemp(k);
        HotSideInlet.flowrate=HotSideFlowRate(k);
        
        [ColdOutlet,HotOutlet,HeatTransRate,Eff,EconomicCost]=HeatExchanger...% e-NTU
            (ColdSideInlet,HotSideInlet,UADesign,ParallelNum(k),AvailSchedValue(k),HXTypeOf,parameter_HX,SizingParameter);
        y=HotOutlet.temp-HotSideOutletTemp(k);
    end

end