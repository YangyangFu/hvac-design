function [eff_fan_dim] = PLFanEffNormCurve(curve_index,x_fan,parameter)
%This model describes the relationship between fan static efficiency and
%normalized Eu number in non-stall region(x_fan<0) of a generic backward-curved
%plenum fan.
%
%================================input==============================
% x_fan:        a vector, describes log10(Eu./Eu_max);  [-]
% parameter:    a struct, describes the parameter needed in this model;
%               parameter.coefficent: coefficients for fan static
%               efficiency model;[-]
%===============================output===============================

% Check input of this function
if nargin<3
    parameter.coefficient= [-2.732094 2.273014 0.196344 5.267518];
end

if curve_index~=0
    % initilization for coefficient;
    a_fan=parameter.coefficient(1);
    b_fan=parameter.coefficient(2);
    c_fan=parameter.coefficient(3);
    d_fan=parameter.coefficient(4);
    
    
    Z1=(x_fan-a_fan)./b_fan;
    Z2=(exp(c_fan*x_fan).*d_fan.*x_fan-a_fan)./b_fan;
    Z3=-a_fan/b_fan;
    
    % fan efficiency predicted by Wray dimensionless fan static efficiency model
    eff_fan_dim=(exp(-0.5*Z1.^2)./exp(-0.5*Z2.^2)).*eta_fan_equation(Z2)./eta_fan_equation(Z3);
    
    
else
    row=size(x_fan,1);
    eff_fan_dim=ones(row,1);
end

end

function y=eta_fan_equation(x)

y=exp(-0.5*x.^2).*(1+x./abs(x).*erf(abs(x)/sqrt(2)));

end
