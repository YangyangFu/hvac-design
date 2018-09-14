function [eff_belt]=PLBeltEffReg3Curve(curve_index,x_belt,parameter)
% This function describes the relationship between the Belt efficiency and
% Belt fraction load in region 3, where x_belt>1.

%================input===============
% curve_index: logical value, curve fitting or not;
% x_belt:      a vector,fraction of full-load torque for the belt, which is
%              typically called "belt load"
% eff_belt_max: maximum belt efficiency

%===============output==============
% eff_belt£»  belt efficiency at part load

% Check for Input
if nargin<4
    parameter.coefficient=[1.037778 0.010307 -0.026815];
end

if curve_index~=0
    % Initialization for the Input
    a_belt=parameter.coefficient(1);
    b_belt=parameter.coefficient(2);
    c_belt=parameter.coefficient(3);
    
    % Predicted belt efficiency by fitted curve
    eff_belt=a_belt.*x_belt./(b_belt+x_belt)+c_belt.*x_belt;
    
else    
    eff_belt=1;
end
end