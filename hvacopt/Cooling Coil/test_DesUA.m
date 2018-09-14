clear;

AirInlet.temp=24.5;
AirInlet.Twb=18.3;
AirInlet.flowrate=62880/3600;

AirOutlet.temp=13.5;
AirOutlet.Twb=12.8;

WaterInlet.temp=6;

WaterOutlet.temp=12;

HeatTrans=408300;

FlowType=2;


[CoilUAForDesign, AirOutIter,WaterOutIter ,HeatTransIter] = DesUA( AirInlet,AirOutlet, WaterInlet,WaterOutlet,HeatTrans,FlowType);