function [ColdSideOutlet,HotSideOutlet,HeatTransRate,Effectiveness,EconomicCost]=HeatExchanger...
    (ColdSideInlet,HotSideInlet,UADes,ParallelNum,AvailSchedValue,HXTypeOf,parameter_HX,SizingParameter)

%          !       AUTHOR         Fu Yangyang
%          !       DATE WRITTEN   August 2014
%          !       MODIFIED       na
%         !       RE-ENGINEERED  na
%
%          ! PURPOSE OF THIS SUBROUTINE:
%          ! This calculates the total heat transfer rate between the
%          ! two loop fluids streams. This heat transfer rate is used
%          ! in the update routine to calc the node temps.
%
%          ! METHODOLOGY EMPLOYED:
%          ! NTU-effectiveness heat exchanger model. Effectiveness is
%          ! calculated from the user supplied UA value. If 'Ideal' mode
%          ! has been set, effectiveness is set to 1.0.
%
%          ! REFERENCES:
%          ! na
%          ! SUBROUTINE LOCAL VARIABLE DECLARATIONS:
%  REAL(r64)    :: PlantFluidCp        ! Specific heat of Plant side fluid
%  REAL(r64)    :: PlantCapRate        ! Capacity rate (mdot*Cp) of Plant side fluid
%  REAL(r64)    :: PlantInletTemp      ! Plant side inlet temperature
%  REAL(r64)    :: CondFluidCp         ! Specific heat of condenser side fluid
%  REAL(r64)    :: PlantInletdensity   ! density on plant side
%  REAL(r64)    :: CondInletDensity    ! density on cond side
%  REAL(r64)    :: CondCapRate         ! Capacity rate (mdot*Cp) of condenser side fluid
%  REAL(r64)    :: CondInletTemp       ! condenser side inlet temperature
%  REAL(r64)    :: MinCapRate          ! minimum capacity rate
%  REAL(r64)    :: CapRatio            ! capacity ratio (min/max)
%  REAL(r64)    :: Effectiveness       ! heat exchanger effectiveness
%  REAL(r64)    :: NTU                 ! dimensionless NTU calculated from UA

if nargin<7
    parameter_HX.resistance=[4.5 4.5];
    parameter_HX.nominal=[0.0975 0.0975];% nominal flowrate in each parallel of this heat exchanger;
    parameter_HX.UAParameter=[0.2675 0.2675]; % m,n
end
if nargin<8
    SizingParameter.DesignPressure=1e6;%Pa
    SizingParameter.NumONMax=2;
end

%% Initialize the Input

ColdSideResis=parameter_HX.resistance(1);
HotSideResis=parameter_HX.resistance(2);

ColdSideNomFlowPerParallel=parameter_HX.nominal(1);
HotSideNomFlowPerParallel=parameter_HX.nominal(2);

ColdInletTemp=ColdSideInlet.temp;
ColdSideFlowRate=ColdSideInlet.flowrate;

HotInletTemp=HotSideInlet.temp;
HotSideFlowRate=HotSideInlet.flowrate;

row=size(ColdInletTemp,1);

ColdInletdensity =RhoWater(ColdInletTemp);
HotInletDensity = RhoWater(HotInletTemp);

m=parameter_HX.UAParameter(1);
n=parameter_HX.UAParameter(2);

DesignPressure=SizingParameter.DesignPressure;
ParallelNumMax=SizingParameter.NumONMax;
% flowrate in each parallel HX;
ParaColdSideFlowRate=ColdSideFlowRate./max(0.01,ParallelNum);
ParaHotSideFlowRate=HotSideFlowRate./max(0.01,ParallelNum);


ParaColdSideFlowRate=max(ParaColdSideFlowRate,0.2*ColdSideNomFlowPerParallel);
ParaHotSideFlowRate=max(ParaHotSideFlowRate,0.2*HotSideNomFlowPerParallel);

    
% if we didn't return, then we should try to turn on and run, first
%  calculate desired flows
ParaColdMassFlowRate = ParaColdSideFlowRate.*ColdInletdensity.*AvailSchedValue;
ParaHotMassFlowRate =  ParaHotSideFlowRate .* HotInletDensity.*AvailSchedValue;

%@@@@@@@@ Initialize the local variables for heat exchanger calculation

ColdFluidCp   = PsychCpWater(ColdInletTemp);
ColdCapRate = ColdFluidCp * ParaColdMassFlowRate;
HotFluidCp    = PsychCpWater(HotInletTemp);
HotCapRate  = HotFluidCp .* ParaHotMassFlowRate;
MinCapRate = min(HotCapRate, ColdCapRate);


ParaHeatTransRate=zeros(row,1);
Effectiveness=zeros(row,1);
NTU=zeros(row,1);
CapRatio=zeros(row,1);

%% Physical Model Equation
% UA value under part load condition
UA=UADes*(ParaColdSideFlowRate./ColdSideNomFlowPerParallel).^m.*(ParaHotSideFlowRate./HotSideNomFlowPerParallel).^n;

%%

k=1;
while k<=row
    %!If there is no flow rate on either the condenser or plant side, try
    %to turn off heat exchanger and return
    if (HotCapRate(k)<=1e-5 || ColdCapRate(k)<=1e-5)
        ParaHeatTransRate(k) = 0.0;
        ParaHotMassFlowRate(k) = 0.0;
        ParaColdMassFlowRate(k) = 0.0;
        Effectiveness(k)=0;
        
        %  ! calc effectiveness - 1.0 if in ideal mode
    elseif(HXTypeOf == 1) % Plate Frame
        %! assume cross flow, both mixed
        NTU(k) = UA(k)./MinCapRate(k);
        if(HotCapRate(k) >=1e10 || ColdCapRate(k) >= 1e10)
            CapRatio(k) = 0.0;
            if (NTU(k) <= 10)
                Effectiveness(k) = 1.0-exp(-NTU(k));
                Effectiveness(k) = min(1.0,Effectiveness(k));
            else
                Effectiveness(k) = 1.0;
            end
        else
            CapRatio(k) = MinCapRate(k)/max(HotCapRate(k), ColdCapRate(k));
            Effectiveness(k) = 1.0 - exp((NTU(k).^0.22./CapRatio(k)) .* ...
                (exp(-CapRatio(k).*NTU(k).^0.78) - 1.0));
            Effectiveness(k) = min(1.0,Effectiveness(k));
        end
    elseif(HXTypeOf == 2) % ParallelFlow
        %! assume cross flow, both mixed
        NTU(k) = UA(k)./MinCapRate(k);
        if(HotCapRate(k) >=1e10 || ColdCapRate(k) >= 1e10)
            CapRatio(k) = 0.0;
            Effectiveness(k) = 1.0-exp(-NTU(k));
            Effectiveness(k) = min(1.0,Effectiveness(k));
        else
            CapRatio(k) = MinCapRate(k)/max(HotCapRate(k), ColdCapRate(k));
            Effectiveness(k) = (1.0-exp(-NTU(k).*(1.0+CapRatio(k))))./(1.0+CapRatio(k));
            Effectiveness(k) = min(1.0,Effectiveness(k));
        end
    elseif(HXTypeOf ==3) %CounterFlow
        %! assume cross flow, both mixed
        NTU(k) = UA(k)./MinCapRate(k);
        if(HotCapRate(k) >=1e10 || ColdCapRate(k) >= 1e10)
            CapRatio(k) = 0.0;
            Effectiveness(k) = 1.0-exp(-NTU);
            Effectiveness (k)= min(1.0,Effectiveness(k));
        else
            CapRatio(k) = MinCapRate(k)/max(HotCapRate(k), ColdCapRate(k));
            Effectiveness(k) = (1.0-exp(-NTU(k).*(1.0-CapRatio(k))))./(1.0-CapRatio(k).*exp(-NTU(k).*(1.0-CapRatio(k))));
            Effectiveness(k) = min(1.00,Effectiveness(k));
        end
    elseif(HXTypeOf == 0) % Ideal mode
        %! must be in ideal mode
        Effectiveness(k) = 1.0;
    else
        Effectiveness(k)=0;
        error('Need specify the type of heat exchanger');
    end
    k=k+1;
end
%! overall heat transfer rate
%! convention is +ve rate is rejected from plant side to condenser side
ParaHeatTransRate = Effectiveness*MinCapRate*(HotInletTemp-ColdInletTemp);

%! Outlet Temperature
ColdOutletTemp=ParaHeatTransRate./ColdCapRate+ColdInletTemp;
HotOutletTemp=HotInletTemp-ParaHeatTransRate./HotCapRate;

%!Pressure Drop
ColdSideDeltaP=ColdSideResis.*ParaColdMassFlowRate.^2;
HotSideDeltaP=HotSideResis.*ParaHotMassFlowRate.^2;

%% Economic Moel 
% Capitial Cost model
% Data from the RMeans Construction Data indicate that the capitial cost of
% Plate Heat Exchanger is function of its rated water flowrate
CapitalCostUSDBaseline=34800*(-66.756*ColdSideNomFlowPerParallel.^2+37.664*ColdSideNomFlowPerParallel...
    +0.0622);% x[0.02~0.13]
if DesignPressure==1.0*1e6
    CapitalCostUSD=CapitalCostUSDBaseline;
elseif DesignPressure==1.6*1e6
    CapitalCostUSD=CapitalCostUSDBaseline*(1+0.05);
elseif DesignPressure==2.0*1e6
    CapitalCostUSD=CapitalCostUSDBaseline*(1+0.11);
elseif DesignPressure==2.5*1e6
    CapitalCostUSD=CapitalCostUSDBaseline*(1+0.16);
elseif DesignPressure>2.5*1e6
    CapitalCostUSD=CapitalCostUSDBaseline*(1+0.26);
end


%% MODEL OUTPUT
%! Overall heat flow ,of course;
HeatTransRate=ParaHeatTransRate.*ParallelNum;

ColdSideOutlet.temp=ColdOutletTemp;
ColdSideOutlet.flowrate=ColdSideFlowRate;
ColdSideOutlet.pressure_loss=ColdSideDeltaP;

HotSideOutlet.temp=HotOutletTemp;
HotSideOutlet.flowrate=HotSideFlowRate;
HotSideOutlet.pressure_loss=HotSideDeltaP;

% Economic cost
EconomicCost.CapCost=CapitalCostUSD*ParallelNumMax;

end