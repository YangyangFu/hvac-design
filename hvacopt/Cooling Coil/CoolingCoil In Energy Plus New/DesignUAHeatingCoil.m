function [UADesign,DesTotWaterCoilLoad]=DesignUAHeatingCoil...
    (DesInletAir,DesInletWater,DesOutletAir,HeatExchType,Parameter)


DesInletAirTemp=DesInletAir.temp;
DesInletAirHumRat=DesInletAir.W;


DesAirVolFlowRate=DesInletAir.flowrate;


DesOutletAirTemp=DesOutletAir.temp;


%! Now use SolveRegulaFalsi to "invert" the cooling coil model to obtain the UA given the specified design inlet and outlet conditions
%! Note that the UAs we have obtained so far are rough estimates that are the starting points for the the following iterative
%!   calulation of the actual UAs.

% Give an initial value to external UA 
RhoAir=RhoAirFuTdbWP(DesInletAirTemp,DesInletAirHumRat);
CpAir=PsychCpAirFuTdbW(DesInletAirTemp,DesInletAirHumRat);
UACoilExternal=DesAirVolFlowRate*RhoAir*CpAir;

DesTotWaterCoilLoad=DesAirVolFlowRate*RhoAir*CpAir*(DesInletAirTemp-DesOutletAirTemp);

UAInit=UACoilExternal;
fun=@DesUAEquation;
%options=optimoptions('fsolve','Algorithm','levenberg-marquardt');
[UACoilExternalDes,fval,exitflag]=fzero(fun,UAInit);
UACoilInternalDes=UACoilInternalIter;
UACoilTotalDes=UACoilTotalIter;



%! estimate the heat external transfer surface area using typical design over all U value
TotCoilOutsideSurfArea=EstimateHEXSurfaceArea(UACoilExternalDes,UACoilInternalDes);
%! calculate internal and external "UA per external surface area"
UACoilInternalPerUnitArea=UACoilInternalDes/ TotCoilOutsideSurfArea;
UAWetCoilExtPerUnitArea=UACoilExternalDes/TotCoilOutsideSurfArea;
%! approximate the dry UA as 1.0 times wet UA
UADryCoilExtPerUnitArea=UAWetCoilExtPerUnitArea;


UADesign.UAExternal= UACoilExternalDes;
UADesign.UAInternal=UACoilInternalDes;
UADesign.UATotal=UACoilTotalDes;
    
UADesign.UInternal=UACoilInternalPerUnitArea;
UADesign.UExternalWet=UAWetCoilExtPerUnitArea;
UADesign.UExternalDry=UADryCoilExtPerUnitArea;
    
    
    function Residuum=DesUAEquation(UA)
        
        
        UACoilExternalIter=UA;
        UACoilInternalIter=3.3*UACoilExternalIter;
        UACoilTotalIter = 1.0/(1.0/UACoilExternalIter+1.0/UACoilInternalIter);
        
        
        UADesignIter.UAExternal=UACoilExternalIter;
        UADesignIter.UAInternal=UACoilInternalIter;
        UADesignIter.UATotal=UACoilTotalIter;
        [~,~,TotWaterCoolingCoilRateIter]=...
            HeatingCoil(DesInletAir,DesInletWater,UADesignIter,...
            1,HeatExchType,DesInletAir,DesInletWater,Parameter);
        Residuum=(DesTotWaterCoilLoad-TotWaterCoolingCoilRateIter)/DesTotWaterCoilLoad;
        
    end  

end

