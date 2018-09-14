clear;



FanVolFlow=[11.93944444 13.48 15.02055556 16.56111111 18.10166667 19.64222222 21.18277778]';
row=size(FanVolFlow,1);
InletAir.temp=25*ones(row,1);
InletAir.RH=0.5*ones(row,1);
DeltaPressTot=[2333  2286  2210  2106  1964  1784 1585]';

FanWheelDia=1.25;
    
SchedPtr=ones(row,1);
TempRise=1;

    parameter.ManuDataMaxEff=[2106 16.561 0.915];
    parameter.FanMaxDimFlow =0.153355;     %! Maximum dimensionless flow from maufacturer's table.
    parameter.PulleyDiaRatio=1.08;        %! The ratio between pulley motor diameter and pulley fan diameter;
    parameter.MaxAirMassFlowRate=100;  %! Maximum massflow rate;[kg/s]
    parameter.MotInAirFrac=1;          %! Motor in Air Fraction, used in temperature rise model.
    parameter.MotorRatedOutPwr=45000;  %! Motor rated power;[w]
    parameter.SizeFactor=1.1;          %! Motor power size factor ;
    parameter.RhoAir=1.29;             %! Air density;[kg/m3]
    parameter.CurveIndex=[1 1 1 1 1 1 1 1 1 1 1]'; %! Curve index for calling fitted curve.
    parameter.BeltType=3;              %! Medium loss belt is used by default;
    parameter.MotorType=3;             %! Medium efficienct motor is used by default;
    
[OutletAir,OutletFan,FanSpd]=FanVFD(InletAir,FanVolFlow,DeltaPressTot,FanWheelDia,SchedPtr,TempRise,parameter);

RealPower=1000*[38.1 
40.8 
42.9 
44.7 
46.1 
46.7 
46.7 
];

PredictedPower=OutletFan.FanPower;


%% PLOT

figure1 = figure('Name','VFD Fan');

% 创建 axes
axes1 = axes('Parent',figure1);
box(axes1,'on');
hold(axes1,'all');

% 使用 bar 的矩阵输入创建多行
AX=plotyy(FanVolFlow,OutletFan.efficiency,FanVolFlow,OutletFan.FanPower);

% 创建 xlabel
xlabel('flowrate (m3/s)');

% 创建 ylabel
ylabel(AX(1),'efficiency');
ylabel(AX(2),'Power (W)');

% 创建 title
title('VFD Fan');

% 创建 legend
legend(axes1,'show');
