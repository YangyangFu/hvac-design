function [UA,HeatTransRate]=DesUAExch(DesColdSideInlet,DesHotSideInlet,...
    HETypeOf,ParameterHE,SizingParameter)

AvailSchedValue=1;
ParallelNum=1;

DesColdSideFlowRate=DesColdSideInlet.flowrate;    
DesColdSideInletTemp=DesColdSideInlet.temp;
DesTempDiff=ParameterHE.DesignTempDiff;

DesHeatFlow=DesColdSideFlowRate*RhoWater(DesColdSideInletTemp)*PsychCpWater...
    (DesColdSideInletTemp)*DesTempDiff;
fun=@UADesEquation;
Init=DesHeatFlow./6;
options=optimoptions('fsolve','Algorithm','levenberg-marquardt');
UA=fsolve(fun,Init,options);



function error=UADesEquation(UADes)

ParameterHE.nominal=[DesColdSideFlowRate,DesColdSideFlowRate];
[~,~,HeatTransRate,Effectiveness]=HeatExchanger...
    (DesColdSideInlet,DesHotSideInlet,UADes,ParallelNum,AvailSchedValue,HETypeOf,ParameterHE,SizingParameter);


error=HeatTransRate-DesHeatFlow;
end
end