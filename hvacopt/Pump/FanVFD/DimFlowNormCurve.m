function [dim_flow]=DimFlowNormCurve(curve_index,x_fan,parameter)
%This model describes the relationship between dimentionless flow phi and
%normalized Eu number in non-stall region(x_fan<0) of a generic backward-curved
%plenum fan.
%
% ============input=================
% x_fan=log10(Eu./Eu_max);

% Check for input
if nargin<4
    parameter.coefficient= [-0.551396 1.551467 -0.442200 -0.414006 0.234867];
end

% curve specified OR not
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