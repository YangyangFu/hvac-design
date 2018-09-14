
function  [UA,CTFanPower,Qactual]=test_SingleSpeed
clear;
InletAir.Twb=28;

row=size(InletAir.Twb,1);


InletAir.temp=31.5;%PsychTdbFuHRH(PsychTdbRH(InletAir.Twb,1),InletAir.RH);
InletAir.RH=PsychRHFuTdbTwb(InletAir.temp,InletAir.Twb);%0.6*ones(row,1);

InletWater.temp=37*ones(row,1);

InletWater.flowrate=75/3600*ones(row,1);

TempSetPoint=32*ones(row,1);

NumParallelON=1*ones(row,1);

NumCell=1;

UAInit=1e3;
fun=@Equation;

UA=fsolve(fun,UAInit);

function y=Equation(UA)
ParameterCTSmall.NomFlow=[50000/3600 75/3600];
ParameterCTSmall.FreeConv=[0.1 0.1*UA];
ParameterCTSmall.FracWaterFlow=[0.4 1.2];
ParameterCTSmall.FanON=[5500 UA];
ParameterCTSmall.Resis=5;

[OutletWater, CTFanPower,PressureDrop,Qactual,FanCyclingRatio, SpeedSelected] = ...
SingleSpeedCoolTower( InletAir,InletWater,TempSetPoint,NumParallelON,NumCell,ParameterCTSmall );

%y=CTFanPower-5500;

y=OutletWater.temp-32;
%y=Qactual-3281800;%3306522;

end
end