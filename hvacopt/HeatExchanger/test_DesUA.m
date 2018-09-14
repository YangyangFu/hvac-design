
ColdSideInlet.temp=[6;6];
HotSideInlet.temp=[12.5;14];
HotSideInlet.flowrate=[0.04;0.04];

HotSideOutletTemp=[7;7];

DesColdSideInlet.flowrate=0.0588;
DesColdSideInlet.temp=6;

DesHotSideInlet.flowrate=0.0588;
DesHotSideInlet.temp=13;

HeatExType=3;

HeatExParallelNum=1;

Schedule=[1;1];

HeatExParameter.resistance=[4.208,4.208];
HeatExParameter.nominal=[DesColdSideInlet.flowrate,DesHotSideInlet.flowrate];
HeatExParameter.UAParameter=[0.5, 0.5];
HeatExParameter.DesignTempDiff=6;

HeatExSizingParameter.DesignPressure=1e6;
HeatExSizingParameter.NumONMax=1;


HeatExDesignUA=DesUAExch(DesColdSideInlet,DesHotSideInlet,...
    HeatExType,HeatExParameter,HeatExSizingParameter);

[ColdSideOutlet,HotSideOutlet,HeatFlow,Effectiveness,EconomicCost]=DesHeatExchanger...
    (ColdSideInlet,HotSideInlet,HotSideOutletTemp,HeatExDesignUA,HeatExParallelNum,Schedule,HeatExType,HeatExParameter,HeatExSizingParameter);
