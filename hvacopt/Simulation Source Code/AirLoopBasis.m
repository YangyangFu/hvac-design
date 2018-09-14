function [AirSide,WaterSide,MixWaterFlowAHU,MixWaterTempAHU,EcoCostAirLoop]=...
    AirLoopBasis(BuildingInfo,AirOA,...
    DesignInfo,OperationInfo,OperationSchedule,EquipmentParameter,ModelSelection)

ZoneFloorNum=BuildingInfo.ZoneFloorNum;

FloorData=DesignInfo.FloorData;
DesignPressure=DesignInfo.DesignPressure;

WaterTempDifference=OperationInfo.WaterTempDifference;
OAFraction=OperationInfo.OAFraction;

AHUTempSetPoint=OperationSchedule.AHUCCTempSetPoint;
ChillerTempSetPoint=OperationSchedule.ChillerTempSetPoint;
BoilerTempSetPoint=OperationSchedule.BoilerTempSetPoint;
CTTempSetPoint=OperationSchedule.CTTempSetPoint;

%DesCoilUACell=EquipmentParameter.DesCoilUA;
FanDiameterCell=EquipmentParameter.FanDiameter;
ParameterAHUCell=EquipmentParameter.ParameterAHU;
ParameterVFDFanCell=EquipmentParameter.ParameterVFDFan;



%% Step 1:
row=size(FloorData{1,1}{1,1}(:,1),1);
InletWaterCC.temp=ChillerTempSetPoint.*ones(row,1);
InletWaterHC.temp=BoilerTempSetPoint.*ones(row,1);
AHUTempSetPoint=AHUTempSetPoint.*ones(row,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 判断有几种典型层
ZoneFloorTypeInitial=FloorData{1,2};
ZoneFloorTypeIndex(1)=1;
for ii=1:ZoneFloorNum
    if ZoneFloorTypeInitial~=FloorData{ii,2}
        ZoneFloorTypeIndex(end+1)=ii;
        ZoneFloorTypeInitial=FloorData{ii,2};
    end
end
%% Step 2. Calculate the supply air flowrate

% Initialize the output from zone calculation
SupplyAirFlowRateZone=cell(ZoneFloorNum,1);
SupplyAirFlowRateFloor=cell(ZoneFloorNum,1);



for ii=1:size(ZoneFloorTypeIndex,2)
    Sum=zeros(row,1);
    for k=1:5
        %@@@@@ Calculate the flowrate required in each zone
        ZoneAir=struct('temp',FloorData{ZoneFloorTypeIndex(ii),1}{1,k}(:,4),'RH',FloorData{ZoneFloorTypeIndex(ii),1}{1,k}(:,5));
        %air_zone=struct();
        %air_zone.temp=FloorData{j,1}{1,k}(:,4);
        %air_zone.RH=FloorData{j,1}{1,k}(:,5);
        [air_supply,flowrate_zone]=Zone( FloorData{ZoneFloorTypeIndex(ii),1}{1,k}(:,1) ,FloorData{ZoneFloorTypeIndex(ii),1}{1,k}(:,2),...
            FloorData{ZoneFloorTypeIndex(ii),1}{1,k}(:,3),ZoneAir);
        SupplyAirFlowRateZone{ZoneFloorTypeIndex(ii),1}{1,k}=flowrate_zone;
        
        %@@@@@ Calculate the flowrate required in each floor, because only
        %one AHU is adopted in each floor when simulating.
        Sum=Sum+flowrate_zone;
    end
    SupplyAirFlowRateFloor{ZoneFloorTypeIndex(ii),1}=Sum;
end



%% Step 3. Calculate the outlet condition of AHUs
parameter_mixingbox.density=1.29;
parameter_mixingbox.barom_pressure=101325;
parameter_mixingbox.resistance=[5e5 5e5 5e5];

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%@@@@@@@Initialize the output@@@@@@
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
AirOutletMixTempZone=zeros(row,5);
AirOutletMixFlowZone=zeros(row,5);
AirOutletMixWZone=zeros(row,5);

AirOutletAHUFloor=cell(ZoneFloorNum,1);
WaterFlowOutletCC=cell(ZoneFloorNum,1);
WaterTempOutletCC=cell(ZoneFloorNum,1);
WaterDeltaPOutletCC=cell(ZoneFloorNum,1);
WaterFlowOutletHC=cell(ZoneFloorNum,1);
WaterTempOutletHC=cell(ZoneFloorNum,1);
WaterDeltaPOutletHC=cell(ZoneFloorNum,1);
PowerAHUCell=cell(ZoneFloorNum,1);
HeatAHU=cell(ZoneFloorNum,1);
EfficiencyAHU_FAN=cell(ZoneFloorNum,1);
DesCoilUACell=cell(ZoneFloorNum,1);
EconomicCostAHUCell=cell(ZoneFloorNum,1);

AirInletAHUTemp=zeros(row,1);
AirInletAHUW=zeros(row,1);

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%   AHUs in Vertical Zone 1
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
for ii=1:size(ZoneFloorTypeIndex,2)
    m=1;
    while m<=5 % 5 zones in each floor
        % Mix OA and reture air in each zone
        air_zone.temp=FloorData{ZoneFloorTypeIndex(ii),1}{1,m}(:,4);
        air_zone.RH=FloorData{ZoneFloorTypeIndex(ii),1}{1,m}(:,5);
        [AirOutletMix]=MixingBox(AirOA,air_zone,OAFraction,SupplyAirFlowRateZone{ZoneFloorTypeIndex(ii),1}{1,m},parameter_mixingbox);
        AirOutletMixTempZone(:,m)=AirOutletMix.temp;
        AirOutletMixFlowZone(:,m)=AirOutletMix.flowrate;
        AirOutletMixWZone(:,m)=AirOutletMix.W;% humidity ratio;
        m=m+1;
    end
    %Calculate the total flowrate and temperature before AHU
    k=1;
    while k<=row
        if SupplyAirFlowRateFloor{ZoneFloorTypeIndex(ii),1}(k,1)~=0
            AirInletAHUTemp(k,1)=sum(AirOutletMixTempZone(k,:).*...
                AirOutletMixFlowZone(k,:),2)./SupplyAirFlowRateFloor{ZoneFloorTypeIndex(ii),1}(k,1);
            AirInletAHUW(k,1)=sum(AirOutletMixWZone(k,:).*AirOutletMixFlowZone(k,:),2)...
                ./SupplyAirFlowRateFloor{ZoneFloorTypeIndex(ii),1}(k,1);
        else
            AirInletAHUTemp(k,1)=0;
            AirInletAHUW(k,1)=0;
        end
        k=k+1;
    end
    
  Schedule=logical(SupplyAirFlowRateFloor{ZoneFloorTypeIndex(ii),1}) ; 
    
    %********************************************************
    %*************  Sizing the AHU **************************
    %********************************************************
    % Size the AHU first based on calculated airflow and predefined design parameters;
    % Since we assure that only one AHU sevices one floor, the total
    % airflowrate in that floor is used as sizing parameter;
    AHUModel=lower(ModelSelection.AHU);
    
    switch AHUModel
        case 'standardahu'
            
            SortedAirFlowRate=sort(SupplyAirFlowRateFloor{ZoneFloorTypeIndex(ii),1},'descend');
            if SortedAirFlowRate(21)==0
                
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesCoolingCoil.DesInletAirCC.flowrate=1e-8;% less than 20 hours are dissatisfied in this design;
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesHeatingCoil.DesInletAirHC.flowrate=1e-8;
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(2).DesCoolingCoil.DesInletWaterCC.flowrate=1e-8;
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(3).DesCoolingCoil.ParameterCC.WaterResis=20e3;
                ParameterVFDFanCell{ZoneFloorTypeIndex(ii),1}.ManuDataMaxEff(1,2)=1e-8;
                
                DesCoilUA.CC=1e4;
                DesCoilUA.HC=1e4;
                DesCoilUACell{ZoneFloorTypeIndex(ii),1}=DesCoilUA;
                
            else
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesCoolingCoil.DesInletAirCC.flowrate=SortedAirFlowRate(21);% less than 20 hours are dissatisfied in this design;
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesHeatingCoil.DesInletAirHC.flowrate=SortedAirFlowRate(21);
                
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesCoolingCoil.DesInletAirCC=PsychInfo(ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesCoolingCoil.DesInletAirCC);
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(4).DesCoolingCoil.DesOutletAirCC=PsychInfo(ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(4).DesCoolingCoil.DesOutletAirCC);
                % size the water flowrate
                DesInletAirCC=ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesCoolingCoil.DesInletAirCC;
                DesOutletAirCC=ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(4).DesCoolingCoil.DesOutletAirCC;
                %DesOutletAirCC.temp=AHUTempSetPoint(1);
                %DesOutletAirCC.Twb=PsychTwbFuTdbW(DesOutletAirCC.temp,PsychWFuTdbRH(DesOutletAirCC.temp,0.9573));
                %DesOutletAirCC=PsychInfo(DesOutletAirCC);
                
                DesInletWaterCC=ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(2).DesCoolingCoil.DesInletWaterCC;
                DesignWaterFlowCC=...
                    SortedAirFlowRate(21)*RhoAirFuTdbWP(DesInletAirCC.temp,DesInletAirCC.W)*(DesInletAirCC.H-DesOutletAirCC.H)./...
                    (6*RhoWater(DesInletWaterCC.temp)*PsychCpWater(DesInletWaterCC.temp));
                DesInletWaterCC.flowrate=DesignWaterFlowCC;
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(3).DesCoolingCoil.ParameterCC.WaterResis=20*1e3./(RhoWater(DesInletWaterCC.temp)*DesignWaterFlowCC).^2;
                
                ParameterVFDFanCell{ZoneFloorTypeIndex(ii),1}.ManuDataMaxEff(1,2)=SortedAirFlowRate(21);
                
                % sizing cooling coil
                [UADesignCC,DesOutletWaterTempCC,DesLoadCC]=DesignUACoolingCoil...
                    (ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesCoolingCoil.DesInletAirCC,DesInletWaterCC,...
                    DesOutletAirCC,ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).HeatExchType,...
                    ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(3).DesCoolingCoil.ParameterCC);
                
                % sizing heating coil
                %[UADesignHC,DesLoadHC]=DesignUAHeatingCoil...
                %    (ParameterAHUCell{n,1}(1).DesHeatingCoil.DesInletAirHC,ParameterAHUCell{n,1}(2).DesHeatingCoil.DesInletWaterHC,...
                %    ParameterAHUCell{n,1}(4).DesHeatingCoil.DesOutletAirHC,ParameterAHUCell{n,1}(2).HeatExchType,ParameterAHUCell{n,1}(3).DesHeatingCoil.ParameterHC);
                
                DesCoilUA.CC=UADesignCC;
                DesCoilUA.HC=UADesignCC;
                DesCoilUACell{ZoneFloorTypeIndex(ii),1}=DesCoilUA;
            end
            %  Calculate the AHUs
            AirInletAHU.temp=AirInletAHUTemp;
            AirInletAHU.W=AirInletAHUW;
            AirInletAHU.RH=PsychRHFuTdbW(AirInletAHUTemp,AirInletAHUW);
            [AirInletAHU] = PsychInfo( AirInletAHU );
            AirInletAHU.flowrate=SupplyAirFlowRateFloor{ZoneFloorTypeIndex(ii),1};%[m3/s]
            
            
            
            FanDiameter=FanDiameterCell{ZoneFloorTypeIndex(ii),1};
            
            ParameterAHU=ParameterAHUCell{ZoneFloorTypeIndex(ii),1};
            
            ParameterVFDFan=ParameterVFDFanCell{ZoneFloorTypeIndex(ii),1};
            
            SizingParameter.DesignPressure=DesignPressure;
            
            %[AirOutletAHU,WaterOutletCC,WaterOutletHC,PowerAHU,TotHeatAHU,EffectivenessFanAHU]=...
            %AHUWithSimpleCoil(AirInletAHU,InletWaterCC,InletWaterHC,AHUTempSetPoint,...
            %WaterTempDifference,Schedule,FanDiameter,ParameterAHU,ParameterVFDFan);
            
            
            [AirOutletAHU,WaterOutletCC,WaterOutletHC,PowerAHU,TotHeatAHU,EffectivenessFanAHU,EconomicCostAHU]=...
                AHU(AirInletAHU,InletWaterCC,InletWaterHC,AHUTempSetPoint,DesCoilUA,...
                Schedule,FanDiameter,ParameterAHU,ParameterVFDFan,SizingParameter);
            
        case 'lmtdahu'
            %*****************************************
            %******   Sizing the AHU *****************
            %*****************************************
            SortedAirFlowRate=sort(SupplyAirFlowRateFloor{ZoneFloorTypeIndex(ii),1},'descend');
            if SortedAirFlowRate(21)==0
                
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesCoolingCoil.DesInletAirCC.flowrate=1e-8;% less than 20 hours are dissatisfied in this design;
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesHeatingCoil.DesInletAirHC.flowrate=1e-8;
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(2).DesCoolingCoil.DesInletWaterCC.flowrate=1e-8;
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(3).DesCoolingCoil.ParameterCC.WaterResis=20e3;
                ParameterVFDFanCell{ZoneFloorTypeIndex(ii),1}.ManuDataMaxEff(1,2)=1e-8;
                
                DesSurfaceArea=750;
                
            else
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesCoolingCoil.DesInletAirCC.flowrate=SortedAirFlowRate(21);% less than 20 hours are dissatisfied in this design;
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesHeatingCoil.DesInletAirHC.flowrate=SortedAirFlowRate(21);
                
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesCoolingCoil.DesInletAirCC=PsychInfo(ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesCoolingCoil.DesInletAirCC);
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(4).DesCoolingCoil.DesOutletAirCC=PsychInfo(ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(4).DesCoolingCoil.DesOutletAirCC);
                % size the water flowrate
                DesInletAirCC=ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesCoolingCoil.DesInletAirCC;
                DesOutletAirCC=ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(4).DesCoolingCoil.DesOutletAirCC;
                %DesOutletAirCC.temp=AHUTempSetPoint(1);
                %DesOutletAirCC.Twb=PsychTwbFuTdbW(DesOutletAirCC.temp,PsychWFuTdbRH(DesOutletAirCC.temp,0.9573));
                %DesOutletAirCC=PsychInfo(DesOutletAirCC);
                
                DesInletWaterCC=ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(2).DesCoolingCoil.DesInletWaterCC;
                DesignWaterFlowCC=...
                   SortedAirFlowRate(21)*RhoAirFuTdbWP(DesInletAirCC.temp,DesInletAirCC.W)*(DesInletAirCC.H-DesOutletAirCC.H)./...
                    (6*RhoWater(DesInletWaterCC.temp)*PsychCpWater(DesInletWaterCC.temp));
                DesInletWaterCC.flowrate=DesignWaterFlowCC;
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(3).DesCoolingCoil.ParameterCC.WaterResis=20*1e3./(RhoWater(DesInletWaterCC.temp)*DesignWaterFlowCC).^2;
                
                ParameterVFDFanCell{ZoneFloorTypeIndex(ii),1}.ManuDataMaxEff(1,2)=SortedAirFlowRate(21);
                
                
                DesOutletWaterTemp=DesInletWaterCC.temp+6;%WaterTempDifference.CC;
                DesOutletWaterTemp=min(DesOutletWaterTemp,DesOutletAirCC.temp);
                DesInformationCC=ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(5).DesCoolingCoil.DesInformationCC;
                DesInformationCC.AirFlowrate=DesInletAirCC.flowrate;
                DesInformationCC.WaterFlowrate=DesignWaterFlowCC;
                ParameterCC=ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(3).DesCoolingCoil.ParameterCC;
                
                [OutletAir,OutletWater,DesSurfaceArea,TotHeatTransferRate]=DesignSurfaceLMTD...
                    (DesInletAirCC,DesInletWaterCC,DesOutletAirCC.temp,DesOutletWaterTemp,1,DesInformationCC,ParameterCC);
                
                
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(5).DesCoolingCoil.DesInformationCC=DesInformationCC;
                
                
                % sizing heating coil
                %[UADesignHC,DesLoadHC]=DesignUAHeatingCoil...
                %    (ParameterAHUCell{n,1}(1).DesHeatingCoil.DesInletAirHC,ParameterAHUCell{n,1}(2).DesHeatingCoil.DesInletWaterHC,...
                %    ParameterAHUCell{n,1}(4).DesHeatingCoil.DesOutletAirHC,ParameterAHUCell{n,1}(2).HeatExchType,ParameterAHUCell{n,1}(3).DesHeatingCoil.ParameterHC);
                

            end
            %  Calculate the AHUs
            AirInletAHU.temp=AirInletAHUTemp;
            AirInletAHU.W=AirInletAHUW;
            AirInletAHU.RH=PsychRHFuTdbW(AirInletAHUTemp,AirInletAHUW);
            [AirInletAHU] = PsychInfo( AirInletAHU );
            AirInletAHU.flowrate=SupplyAirFlowRateFloor{ZoneFloorTypeIndex(ii),1};%[m3/s]
            
            
            
            FanDiameter=FanDiameterCell{ZoneFloorTypeIndex(ii),1};
            
            ParameterAHU=ParameterAHUCell{ZoneFloorTypeIndex(ii),1};
            
            ParameterVFDFan=ParameterVFDFanCell{ZoneFloorTypeIndex(ii),1};
            
            SizingParameter.DesignPressure=DesignPressure;
            
            %[AirOutletAHU,WaterOutletCC,WaterOutletHC,PowerAHU,TotHeatAHU,EffectivenessFanAHU,EconomicCostAHU]=...
            %    AHU(AirInletAHU,InletWaterCC,InletWaterHC,AHUTempSetPoint,DesCoilUA,...
            %    Schedule,FanDiameter,ParameterAHU,ParameterVFDFan,SizingParameter);
            
            [AirOutletAHU,WaterOutletCC,WaterOutletHC,PowerAHU,TotHeatAHU,EffectivenessFanAHU,EconomicCostAHU]=...
                AHUWithLMTDCoil(AirInletAHU,InletWaterCC,InletWaterHC,AHUTempSetPoint,DesSurfaceArea,Schedule,...
                FanDiameter,ParameterAHU,ParameterVFDFan,SizingParameter);
            
        case 'simpleahu'
            %*****************************************
            %******   Sizing the AHU *****************
            %*****************************************
            SortedAirFlowRate=sort(SupplyAirFlowRateFloor{ZoneFloorTypeIndex(ii),1},'descend');
            if SortedAirFlowRate(21)==0
                
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesCoolingCoil.DesInletAirCC.flowrate=1e-8;% less than 20 hours are dissatisfied in this design;
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesHeatingCoil.DesInletAirHC.flowrate=1e-8;
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(2).DesCoolingCoil.DesInletWaterCC.flowrate=1e-8;
                ParameterVFDFanCell{ZoneFloorTypeIndex(ii),1}.ManuDataMaxEff(1,2)=1e-8;
                
            else
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesCoolingCoil.DesInletAirCC.flowrate=SortedAirFlowRate(21);% less than 20 hours are dissatisfied in this design;
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesHeatingCoil.DesInletAirHC.flowrate=SortedAirFlowRate(21);
                
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesCoolingCoil.DesInletAirCC=PsychInfo(ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesCoolingCoil.DesInletAirCC);
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(4).DesCoolingCoil.DesOutletAirCC=PsychInfo(ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(4).DesCoolingCoil.DesOutletAirCC);
                % size the water flowrate
                DesInletAirCC=ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(1).DesCoolingCoil.DesInletAirCC;
                DesOutletAirCC=ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(4).DesCoolingCoil.DesOutletAirCC;
                
                
                DesInletWaterCC=ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(2).DesCoolingCoil.DesInletWaterCC;
                DesignWaterFlowCC=...
                    SortedAirFlowRate(21)*RhoAirFuTdbWP(DesInletAirCC.temp,DesInletAirCC.W)*(DesInletAirCC.H-DesOutletAirCC.H)./...
                    (6*RhoWater(DesInletWaterCC.temp)*PsychCpWater(DesInletWaterCC.temp));
                DesInletWaterCC.flowrate=DesignWaterFlowCC;
                ParameterAHUCell{ZoneFloorTypeIndex(ii),1}(3).DesCoolingCoil.ParameterCC.WaterResis=20*1e3./(RhoWater(DesInletWaterCC.temp)*DesignWaterFlowCC).^2;
                
                ParameterVFDFanCell{ZoneFloorTypeIndex(ii),1}.ManuDataMaxEff(1,2)=SortedAirFlowRate(21);
                
            end
            
            
            %  Calculate the AHUs
            AirInletAHU.temp=AirInletAHUTemp;
            AirInletAHU.W=AirInletAHUW;
            AirInletAHU.RH=PsychRHFuTdbW(AirInletAHUTemp,AirInletAHUW);
            [AirInletAHU] = PsychInfo( AirInletAHU );
            AirInletAHU.flowrate=SupplyAirFlowRateFloor{ZoneFloorTypeIndex(ii),1};%[m3/s]
            
            
            FanDiameter=FanDiameterCell{ZoneFloorTypeIndex(ii),1};
            
            ParameterAHU=ParameterAHUCell{ZoneFloorTypeIndex(ii),1};
            
            ParameterVFDFan=ParameterVFDFanCell{ZoneFloorTypeIndex(ii),1};
            
            SizingParameter.DesignPressure=DesignPressure;
            
            [AirOutletAHU,WaterOutletCC,WaterOutletHC,PowerAHU,TotHeatAHU,EffectivenessFanAHU,EconomicCostAHU]=...
                AHUWithSimpleCoil(AirInletAHU,InletWaterCC,InletWaterHC,AHUTempSetPoint,...
                WaterTempDifference,Schedule,FanDiameter,ParameterAHU,ParameterVFDFan,SizingParameter);
            
        otherwise
            error('No such AHU Model in library');
            
    end
    
    
    % Store the AHU outlet information
    
    n=ZoneFloorTypeIndex(ii);
    if ii==size(ZoneFloorTypeIndex,2)
        nEnd=ZoneFloorNum;
    else
        nEnd=ZoneFloorTypeIndex(ii+1)-1;
    end
    while n<=nEnd
        % AIR SIDE
        AirOutletAHUFloor{n,1}=AirOutletAHU;
        
        % Water side
        WaterFlowOutletCC{n,1}=WaterOutletCC.flowrate;
        WaterTempOutletCC{n,1}=WaterOutletCC.temp;
        WaterDeltaPOutletCC{n,1}=WaterOutletCC.pressure_loss;
        
        WaterFlowOutletHC{n,1}=WaterOutletHC.flowrate;
        WaterTempOutletHC{n,1}=WaterOutletHC.temp;
        WaterDeltaPOutletHC{n,1}=WaterOutletHC.pressure_loss;
        
        PowerAHUCell{n,1}=PowerAHU;
        HeatAHU{n,1}=TotHeatAHU;
        EfficiencyAHU_FAN{n,1}=EffectivenessFanAHU;
        EconomicCostAHUCell{n,1}=EconomicCostAHU;
        n=n+1;
    end
    
end

%% Step 4. AHU outlet condition
%@@@@@ AHU混合后流量及温度
% AHU出水混合后流量

MixWaterFlowAHU=zeros(row,1);
n=1;
while n<=ZoneFloorNum
    MixWaterFlowAHU=MixWaterFlowAHU+WaterFlowOutletCC{n,1};   % 分区1(低区) AHU出水混合后流量；
    n=n+1;
end

% AHU混合后水温
n=1;
FlowandTempCell=cell(ZoneFloorNum,1);
FlowandTemp=zeros(row,1);
while n<=ZoneFloorNum
    FlowandTempCell{n,1}=WaterTempOutletCC{n,1}.*WaterFlowOutletCC{n,1};
    FlowandTemp=FlowandTemp+FlowandTempCell{n,1};
    n=n+1;
end

MixWaterTempAHU=zeros(row,1); % AHU出水混合后温度；[C]
ind=find(MixWaterFlowAHU~=0);
MixWaterTempAHU(ind)=FlowandTemp(ind,1)./MixWaterFlowAHU(ind,1);


%% Update the output
AirSide.AirOutlet=AirOutletAHUFloor;
AirSide.PowerAHU=PowerAHUCell;
AirSide.FanEffAHU=EfficiencyAHU_FAN;
AirSide.TotalHeatTransfer=HeatAHU;

WaterSide.WaterFlowOutletCC=WaterFlowOutletCC;
WaterSide.WaterTempOutletCC=WaterTempOutletCC;
WaterSide.WaterDeltaPOutletCC=WaterDeltaPOutletCC;
WaterSide.WaterFlowOutletHC=WaterFlowOutletHC;
WaterSide.WaterTempOutletHC=WaterTempOutletHC;
WaterSide.WaterDeltaPOutletHC=WaterDeltaPOutletHC;

EcoCostAirLoop=EconomicCostAHUCell;
end