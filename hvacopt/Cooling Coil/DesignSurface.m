function [OutletAir,OutletWater,SurfaceArea,TotHeatTransferRate]=DesignSurface...
    (InletAir,InletWater,TempSetPoint,OutletWaterTemp,Schedule,DesInformation,Parameter,DesignInletAir,DesignInletWater)

fun=@DesignSurfaceEquation;
options=optimoptions('fsolve','TolFun',1e-3);
SurfaceArea=fsolve(fun,500,options);

    function y=DesignSurfaceEquation(SurfaceArea)
[OutletAir,OutletWater,TotHeatTransferRate]=SimpleDesignCoolingCoilLMTD(...
    InletAir,InletWater,TempSetPoint,SurfaceArea,Schedule,DesInformation,Parameter,DesignInletAir,DesignInletWater);
y=OutletWaterTemp-OutletWater.temp;
    end

end

