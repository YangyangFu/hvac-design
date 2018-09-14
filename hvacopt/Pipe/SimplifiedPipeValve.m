function [OutletFlowRate,OutletTemp,PressureLoss]=SimplifiedPipeValve...
(InletFlowRate,InletTemp,Parameter)


% InletFlowRate: inlet volume flow rate [m3/s]
% InletTemp:     inlet fluid temperature[¡æ]

if nargin<3
    Parameter.k=100;
    Parameter.MassFlowRateCritic=0.03;
end

MassFlowRateCritic=Parameter.MassFlowRateCritic;
k=Parameter.k;

row=size(InletTemp,1);
PressureLoss=zeros(row,1);


Rho = RhoWater( InletTemp );
InletMassFlowRate=InletFlowRate.*Rho;

i=1;
while i<=row
    if InletMassFlowRate(i,1)<=MassFlowRateCritic
        PressureLoss(i,1)=k*MassFlowRateCritic*InletMassFlowRate(i,1);
    else
        PressureLoss(i,1)=k*InletMassFlowRate(i,1).^2;
    end
    
    i=i+1;
end

OutletFlowRate=InletFlowRate;
OutletTemp=InletTemp;

end