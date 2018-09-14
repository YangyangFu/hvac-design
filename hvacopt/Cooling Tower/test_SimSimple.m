%% test_SimSimpleTower

InletAir.temp=[21:1:30]';
row=size(InletAir.Tdb,1);

InletAir.RH=0.6*ones(row,1);

[InletAir.H,InletAir.W]=PsychTdbRH(InletAir.Tdb,InletAir.RH);

InletAir.Twb=PsychTwbFuTdbW(InletAir.Tdb,InletAir.W);

InletAir.flowrate=100*ones(row,1);

InletWater.temp=35*ones(row,1);

InletWater.flowrate=0.112*ones(row,1);
UAdesign=10000;

[OutletWaterTemp,Qactual]=SimSimpleTower(InletAir,InletWater,UAdesign);