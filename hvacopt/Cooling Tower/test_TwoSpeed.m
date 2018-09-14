clear;
InletAir.Twb=28.7;

row=size(InletAir.Twb,1);

InletAir.RH=0.6*ones(row,1);
InletAir.temp=PsychTdbFuHRH(PsychTdbRH(InletAir.Twb,1),InletAir.RH);

InletWater.temp=37*ones(row,1);

InletWater.flowrate=0.158*ones(row,1);

TempSetPoint=32*ones(row,1);

NumParallelON=1*ones(row,1);

NumCell=4;

[OutletWater, CTFanPower,PressureDrop,Qactual,FanCyclingRatio, SpeedSelected] = ...
    TwoSpeedCoolTower( InletAir,InletWater,TempSetPoint,NumParallelON,NumCell );