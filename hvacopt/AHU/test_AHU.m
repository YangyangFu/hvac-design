
clear;
InletAir.temp=25;
InletAir.RH=0.55;
InletAir.W=PsychWFuTdbRH(InletAir.temp,InletAir.RH);
InletAir.DewPTemp=PsychTdpFuWP(InletAir.W);
InletAir.flowrate=2.764;

InletWaterCC.temp=7;
InletWaterCC.flowrate=2.2e-3;

InletWaterHC.temp=50;
InletWaterHC.flowrate=0.002;

AirSetPointTemp=13;

CoilUA.CC.UATotal=4.922523217207511e+03;
CoilUA.CC.UAExternal=6414.19691939161;
CoilUA.CC.UAInternal=2.116684983399230e+04;

CoilUA.HC.UATotal=4.922523217207511e+03;
CoilUA.HC.UAExternal=6414.19691939161;
CoilUA.HC.UAInternal=2.116684983399230e+04;

Schedule=1;


[OutletAirAHU,OutletWaterCC,OutletWaterHC,PowerAHU,TotHeatTransferRate,EffectivenessFan]=...
    AHU(InletAir,InletWaterCC,InletWaterHC,AirSetPointTemp,CoilUA,Schedule);