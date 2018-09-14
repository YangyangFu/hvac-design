function [UACoilExternal,UACoilInternal,UACoilTotal]=CalcVariableUA(...
    InletAirMassFlowRate,InletAirTemp,InletWaterMassFlowRate,InletWaterTemp,...
    DesAirMassFlowRate,DesInletAirTemp,DesWaterMassFlowRate,DesInletWaterTemp,WaterCoilType,UADesign )

%! Calculate the variable UA during operating period!
%!FUNCTION AUGUMENT DEFINITIONS
% InletAirMassFlowRate:    ;;; Coil inlet air mass flow;[kg/s]
% InletAirTemp             ::: Coil inlet air temperature;[¡æ]
% InletWaterMassFlowRate   ::: Coil inlet water mass flow;[kg/s]
% InletWaterTemp           ::: Coil inlet water temperature;[¡æ]
% DesAirMassFlowRate       ::: Coil design air mass flow;[m3/s]
% DesInletAirTemp          ::: Coil design inlet air temperature;[¡æ]
% DesWaterMassFlowRate     ::: Coil design inlet water mass flow;[kg/s]
% DesInletWaterTemp        ::: Coil inlet water temperature;[¡æ]
% WaterCoilType            ::: String;
%                             'HeatingCoil'-----Heating the air;
%                             'CoolingCoil'-----Cooling the air;
% UADesign:    Struct array::: Coil Design UA;
%                    UADesign.UATotal   :::   a number, design total UA;[W/K];
%                    UADesign.UAExternal:::   a number, design external UA;[W/K]
%                    UADesign.UAInternal:::   a number, design internal UA;[W/K]


%! Do the following initializations (every time step): This should be the info from
%! the previous components outlets or the node data in this section.
%!First set the conditions for the air into the coil model

UACoilDesign=UADesign.UATotal;
UACoilExternalDes=UADesign.UAExternal;
UACoilInternalDes=UADesign.UAInternal;

RatioAirSideToWaterSideConvect=0.3;

row=size(InletAirTemp,1);

UACoilExternal=zeros(row,1);
UACoilInternal=zeros(row,1);
UACoilTotal=zeros(row,1);

LiquidSideNominalConvect = UACoilDesign ...
    * (RatioAirSideToWaterSideConvect + 1)/RatioAirSideToWaterSideConvect;
AirSideNominalConvect = RatioAirSideToWaterSideConvect* LiquidSideNominalConvect;

k=1;
while k<=row
    
    switch WaterCoilType
        case ('HeatingCoil')    %!update Coil UA based on inlet mass flows and temps
            
            x_a = 1.0 + 4.769e-3*(InletAirTemp(k) - DesInletAirTemp);
            
            UACoilExternal(k)  = x_a * ((InletAirMassFlowRate(k)/DesAirMassFlowRate).^0.80)...
                * AirSideNominalConvect;
            
            WaterConvSensitivity = 0.0140 / (1.0 + 0.0140*DesInletWaterTemp);
            x_w = 1.0 + WaterConvSensitivity *(InletWaterTemp(k) - DesInletWaterTemp);
            
            UACoilInternal(k) =  x_w * ((InletWaterMassFlowRate(k)/DesWaterMassFlowRate).^0.85)...
                * LiquidSideNominalConvect;
            
            if ((UACoilExternal(k) > 0.0) && (UACoilInternal(k) > 0.0))
                UACoilTotal(k) =1.0 / ( (1.0/UACoilInternal(k)) + (1.0 / UACoilExternal(k)) );
            else
                %! use nominal UA since variable UA cannot be calculated
                UACoilTotal(k) = UACoilDesign;
            end
            
            
            %!update Coil UA based on inlet mass flows and temps
        case ('CoolingCoil')
            
            x_a = 1.0 + 4.769e-3*(InletAirTemp(k) - DesInletAirTemp);
            
            UACoilExternal(k)  = x_a *   ...
                ((InletAirMassFlowRate(k)/DesAirMassFlowRate).^0.80)...
                * UACoilExternalDes;
            
            WaterConvSensitivity = 0.014 / (1.0 + 0.014*DesInletWaterTemp);
            x_w = 1.0 + WaterConvSensitivity *(InletWaterTemp(k) - DesInletWaterTemp);
            
            UACoilInternal(k) =  x_w *  ...
                ((InletWaterMassFlowRate(k)/DesWaterMassFlowRate).^1) ...%0.85
                * UACoilInternalDes;
            
            if (UACoilInternal(k) > 0.0 && UACoilExternal(k) > 0.0)
                UACoilTotal = 1.0/(1.0/UACoilExternal(k)+1.0/UACoilInternal(k));
            else
                UACoilInternal(k) = UACoilInternalDes;
                UACoilExternal(k) = UACoilExternalDes;
                UACoilTotal(k) = 1.0/(1.0/UACoilExternal(k)+1.0/UACoilInternal(k));
            end
            
    end
    k=k+1;
end

end