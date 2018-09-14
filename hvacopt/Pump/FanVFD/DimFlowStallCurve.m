function [dim_flow]=DimFlowStallCurve(curve_index,x_fan,parameter)
%This model describes the relationship between dimentionless flow phi and
%normalized Eu number in stall region(x_fan>0) of a generic backward-curved
%plenum fan.
%
% ============input=================
% x_fan=log10(Eu./Eu_max);

% Check for input
if nargin<3
    parameter.coefficient= [0.000608 0.586366 0.021775 -0.063218 0.072827];
end

if curve_index~=0
    % initilization for coefficient;
    a_spd=parameter.coefficient(1);
    b_spd=parameter.coefficient(2);
    c_spd=parameter.coefficient(3);
    d_spd=parameter.coefficient(4);
    e_spd=parameter.coefficient(5);
    
    dim_flow=a_spd+b_spd./(1+(exp((c_spd-x_fan)./d_spd)).^e_spd);
    
    
else
    row=size(x_fan,1);
    dim_flow=ones(row,1);
end
end