function [eff_belt]=PLBeltEffReg2Curve(curve_index,x_belt,parameter)
% This function describes the relationship between the Belt efficiency and
% Belt fraction load in region 2, where x_belt_trans<=x_belt<=1.

%================input===============
% curve_index: logical value, curve fitting or not;
% x_belt:      a vector,fraction of full-load torque for the belt, which is
%              typically called "belt load"
% eff_belt_max: maximum belt efficiency

%===============output==============
% eff_belt£»  belt efficiency at part load

% Check for Input
if nargin<4
    parameter.coefficient=[1.011965 -0.339038 -3.436260];
end

if curve_index~=0
    % Initialization for the Input
    a_belt=parameter.coefficient(1);
    b_belt=parameter.coefficient(2);
    c_belt=parameter.coefficient(3);
    
    % Predicted belt efficiency by fitted curve
    eff_belt=a_belt+b_belt.*exp(c_belt.*x_belt);
    
else
    eff_belt=1;
end
end