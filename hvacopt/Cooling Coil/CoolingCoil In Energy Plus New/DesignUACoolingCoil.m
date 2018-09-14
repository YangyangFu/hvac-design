function [UADesign,DesOutletWaterTemp,DesTotWaterCoilLoad]=DesignUACoolingCoil...
    (DesInletAir,DesInletWater,DesOutletAir,HeatExchType,Parameter)


DesInletAirTemp=DesInletAir.temp;
DesInletAirHumRat=DesInletAir.W;
DesAirVolFlowRate=DesInletAir.flowrate;

DesInletWaterTemp=DesInletWater.temp;
MaxWaterVolFlowRate=DesInletWater.flowrate;

DesOutletAirTemp=DesOutletAir.temp;
DesOutletAirHumRat=DesOutletAir.W;

NoExitCondReset = 0;
SmallNo=1e-9;

[CBFTooLarge,BelowInletWaterTemp,DesOutletWaterTemp,DesTotWaterCoilLoad,DesOutletAirEnth,UACoilExternal,~,~]=...
    ByFactorEquation(DesInletAirTemp,DesInletAirHumRat,DesOutletAirTemp,DesOutletAirHumRat,DesAirVolFlowRate,...
    DesInletWaterTemp,MaxWaterVolFlowRate);


if ( CBFTooLarge || BelowInletWaterTemp)
    %! reset outlet conditions to 90% relative humidity at the same outlet enthalpy
    TOutNew = PsychTdbFuHRH(DesOutletAirEnth,0.90);
    WOutNew  = PsychWFuTdbH(TOutNew,DesOutletAirEnth);
    if (WOutNew >= DesInletAirHumRat)
        NoExitCondReset =1;
    end
    
    if (  (~BelowInletWaterTemp) &&(~ CBFTooLarge) )
        return;  %! coil UA calcs OK
    else
        warning ('In calculating the design coil UA for Coil:Cooling:Water ')
        
        if(BelowInletWaterTemp)
            warning ('the apparatus dew-point is below the coil design inlet water temperature;');
        end
        if (CBFTooLarge)
            warning ('the coil bypass factor is unrealistically large;')
        end
        if ( ~ NoExitCondReset)
            warning ('the coil outlet design conditions will be changed to correct the problem.')
        end
        
        if ( ~ NoExitCondReset)
            DesOutletAirHumRat = WOutNew;
            DesOutletAirTemp = TOutNew;
            
            [~,~,DesOutletWaterTemp,DesTotWaterCoilLoad,~,UACoilExternal,~,~]=...
                ByFactorEquation(DesInletAirTemp,DesInletAirHumRat,DesOutletAirTemp,DesOutletAirHumRat,DesAirVolFlowRate,...
                DesInletWaterTemp,MaxWaterVolFlowRate);
        end
    end
end


%! Now use SolveRegulaFalsi to "invert" the cooling coil model to obtain the UA given the specified design inlet and outlet conditions
%! Note that the UAs we have obtained so far are rough estimates that are the starting points for the the following iterative
%!   calulation of the actual UAs.
UAInit=UACoilExternal+1000;
fun=@DesUAEquation;
%options=optimoptions('fsolve','Algorithm','levenberg-marquardt');
UACoilExternalDes=fzero(fun,UAInit);
UACoilInternalDes=UACoilInternalIter;
UACoilTotalDes=UACoilTotalIter;
DesOutletWaterTemp=OutletWaterIter.temp;

%! estimate the heat external transfer surface area using typical design over all U value
TotCoilOutsideSurfArea=EstimateHEXSurfaceArea(UACoilExternalDes,UACoilInternalDes);
%! calculate internal and external "UA per external surface area"
UACoilInternalPerUnitArea=UACoilInternalDes/ TotCoilOutsideSurfArea;
UAWetExtPerUnitArea=UACoilExternalDes/TotCoilOutsideSurfArea;
%! approximate the dry UA as 1.0 times wet UA
UADryExtPerUnitArea=UAWetExtPerUnitArea;


UADesign.UAExternal= UACoilExternalDes;
UADesign.UAInternal=UACoilInternalDes;
UADesign.UATotal=UACoilTotalDes;
    
UADesign.UInternal=UACoilInternalPerUnitArea;
UADesign.UExternalWet=UAWetExtPerUnitArea;
UADesign.UExternalDry=UADryExtPerUnitArea;
    
    
    function Residuum=DesUAEquation(UA)
        
        
        UACoilExternalIter=UA;
        UACoilInternalIter=3.3*UACoilExternalIter;
        UACoilTotalIter = 1.0/(1.0/UACoilExternalIter+1.0/UACoilInternalIter);
        AnalysisMode='SimpleAnalysis';
        
        UADesignIter.UAExternal=UACoilExternalIter;
        UADesignIter.UAInternal=UACoilInternalIter;
        UADesignIter.UATotal=UACoilTotalIter;
        [~,OutletWaterIter,TotWaterCoolingCoilRateIter,~]=...
            CoolingCoil(DesInletAir,DesInletWater,UADesignIter,...
            1,HeatExchType,AnalysisMode,DesInletAir,DesInletWater,Parameter);
        Residuum=(DesTotWaterCoilLoad-TotWaterCoolingCoilRateIter)/DesTotWaterCoilLoad;
        
    end



    function [CBFTooLarge,BelowInletWaterTemp,DesOutletWaterTemp,DesTotWaterCoilLoad,DesOutletAirEnth,UACoilExternal,UACoilInternal,UACoilTotal]=...
            ByFactorEquation(DesInletAirTemp,DesInletAirHumRat,DesOutletAirTemp,DesOutletAirHumRat,DesAirVolFlowRate,...
            DesInletWaterTemp,MaxWaterVolFlowRate)
        
        StdBaroPress=101325;
        CBFTooLarge=0;
        BelowInletWaterTemp=0;
        %! Volume flow rate being converted to mass flow rate for water
        RhoAir=RhoAirFuTdbWP(DesInletAirTemp,DesInletAirHumRat);
        DesAirMassFlowRate  = RhoAir *DesAirVolFlowRate;
        
        %! Enthalpy of Air at Inlet design conditions
        DesInletAirEnth=PsychHFuTdbW(DesInletAirTemp,DesInletAirHumRat);
        
        %! Enthalpy of Air at outlet at design conditions
        DesOutletAirEnth=PsychHFuTdbW(DesOutletAirTemp,DesOutletAirHumRat);
        
        %! Enthalpy of Water at Inlet design conditions
        DesSatEnthAtWaterInTemp =PsychHFuTdbRH(DesInletWaterTemp,1);
        
        %! Total Coil Load from Inlet and Outlet Air States.
        DesTotWaterCoilLoad=DesAirMassFlowRate*(DesInletAirEnth-DesOutletAirEnth);
        
        %! Enthalpy of Water at Intlet design conditions
        Cp  =  PsychCpWater(DesInletWaterTemp);
        MaxWaterMassFlowRate = RhoWater(DesInletWaterTemp) * MaxWaterVolFlowRate;
        DesOutletWaterTemp = DesInletWaterTemp ...
            + DesTotWaterCoilLoad / (MaxWaterMassFlowRate * Cp);
        
        DesSatEnthAtWaterOutTemp = PsychHFuTdbRH(DesOutletWaterTemp,1);
        
        if (DesOutletAirHumRat < DesInletAirHumRat)
            
            %! Calculations for BYPASS FACTOR at design conditions
            %! Calculate "slope" of temperature vs. humidity ratio between entering and leaving states
            SlopeTempVsHumRatio=(DesInletAirTemp-DesOutletAirTemp)/...
                max((DesInletAirHumRat-DesOutletAirHumRat),SmallNo);
            
            %! Initialize iteration parameters
            DesAirTempApparatusDewPtInit = PsychTdpFuWP(DesOutletAirHumRat);
            
            %! Iterating to calculate Apparatus Dew Point Temperature at Design Conditions
            fun=@DesAirTempApparatusDewPtEquation;
            DesAirTempApparatusDewPt=fzero(fun,DesAirTempApparatusDewPtInit);
            
            
            %! Air enthalpy at apparatus dew point at design conditions
            DesAirApparatusDewPtEnth = PsychHFuTdbW(DesAirTempApparatusDewPt,DesAirHumRatApparatusDewPt);
            
            %! Calculate bypass factor from enthalpies calculated above.
            DesByPassFactor = (DesOutletAirEnth-DesAirApparatusDewPtEnth)/(DesInletAirEnth-DesAirApparatusDewPtEnth);
            
            %! Check for bypass factor for unsuitable value. Note that bypass factor is never used in the coil calculation
            if((DesByPassFactor > 0.50) || (DesByPassFactor < 0.0))
                CBFTooLarge = 1;
            end
            
            if (DesSatEnthAtWaterOutTemp > DesInletAirEnth)
                warning ('In calculating the design coil UA for Cooling Coil');
                warning ('the outlet chilled water design enthalpy is greater than the inlet air design enthalpy.');
                warning ('To correct this condition the design chilled water flow rate will be increased');
                EnthCorrFrac = (DesSatEnthAtWaterOutTemp - DesInletAirEnth) / (DesSatEnthAtWaterOutTemp - DesSatEnthAtWaterInTemp);
                MaxWaterVolFlowRate = (1.0 + 2.0 * EnthCorrFrac) * MaxWaterVolFlowRate;
                
                MaxWaterMassFlowRate = RhoWater(DesInletWaterTemp) * MaxWaterVolFlowRate;
                DesOutletWaterTemp = DesInletWaterTemp ...
                    + DesTotWaterCoilLoad / (MaxWaterMassFlowRate * Cp);
                DesSatEnthAtWaterOutTemp = PsychHFuTdbW(DesOutletWaterTemp,...
                    PsychWFuTdpPb(DesOutletWaterTemp,StdBaroPress));
            end
            
            %! Determine air-side coefficient, UACoilExternal, assuming that the
            %! surface temperature is at the apparatus dewpoint temperature
            if (DesAirApparatusDewPtEnth < DesSatEnthAtWaterInTemp )
                BelowInletWaterTemp = 1;
            end
            if ((DesInletAirEnth - DesSatEnthAtWaterOutTemp) > SmallNo && (DesOutletAirEnth - DesSatEnthAtWaterInTemp) > SmallNo)
                LogMeanEnthDiff = ((DesInletAirEnth - DesSatEnthAtWaterOutTemp) - (DesOutletAirEnth - DesSatEnthAtWaterInTemp)) /...
                    log((DesInletAirEnth - DesSatEnthAtWaterOutTemp)/(DesOutletAirEnth - DesSatEnthAtWaterInTemp));
            else
                LogMeanEnthDiff = 2000.0; %! UA will be 1/2 the design coil load
            end
            DesUACoilExternalEnth =DesTotWaterCoilLoad/LogMeanEnthDiff;
            UACoilExternal = DesUACoilExternalEnth *  ...
                PsychCpAirFuTdbW(DesInletAirTemp,DesInletAirHumRat);
            
            
            
            UACoilInternal = UACoilExternal*3.30;
            %! Overall heat transfer coefficient
            UACoilTotal = 1.0/(1.0/UACoilExternal+1.0/UACoilInternal);
            
            
        else %! dry coil
            
            if (DesOutletWaterTemp > DesInletAirTemp)
                warning ('In calculating the design coil UA for Coil:Cooling:Water');
                warning ('the outlet chilled water design temperature is greater than the inlet air design temperature.')
                warning ('To correct this condition the design chilled water flow rate will be increased from ')
                TempCorrFrac = (DesOutletWaterTemp - DesInletAirTemp) / ...
                    (DesOutletWaterTemp - DesInletWaterTemp);
                MaxWaterVolFlowRate = (1.0 + 2.0 * TempCorrFrac) * MaxWaterVolFlowRate;
                
                MaxWaterMassFlowRate = RhoWater(DesInletWaterTemp) * MaxWaterVolFlowRate;
                DesOutletWaterTemp = DesInletWaterTemp ...
                    + DesTotWaterCoilLoad / (MaxWaterMassFlowRate * Cp);
            end
            
            if((DesInletAirTemp - DesOutletWaterTemp) > SmallNo) &&((DesOutletAirTemp - DesInletWaterTemp) > SmallNo)
                LogMeanTempDiff = ((DesInletAirTemp - DesOutletWaterTemp) - (DesOutletAirTemp - DesInletWaterTemp)) / ...
                    log((DesInletAirTemp - DesOutletWaterTemp) / (DesOutletAirTemp - DesInletWaterTemp));
                UACoilExternal = DesTotWaterCoilLoad / LogMeanTempDiff;
            else
                UACoilExternal = DesTotWaterCoilLoad / 2.0; %! make the UA large
            end
            UACoilInternal = UACoilExternal*3.30;
            %! Overall heat transfer coefficient
            UACoilTotal = 1.0/(1.0/UACoilExternal+1.0/UACoilInternal);
        end
        
        function error=DesAirTempApparatusDewPtEquation(DesAirTempApparatusDewPt)
            %! Calculate apparatus dewpoint and compare with predicted value
            %! using entering conditions and SlopeTempVsHumRatio
            DesAirHumRatApparatusDewPt=  PsychWFuTdbRH(DesAirTempApparatusDewPt,1);
            
            %! Initial Estimate for apparatus Dew Point Temperature
            TempApparatusDewPtEstimate = DesInletAirTemp - SlopeTempVsHumRatio* ...
                (DesInletAirHumRat-DesAirHumRatApparatusDewPt);
            
            %! Iterating to calculate Apparatus Dew Point Temperature at Design Condition
            error = DesAirTempApparatusDewPt-TempApparatusDewPtEstimate;
        end
    end


end

