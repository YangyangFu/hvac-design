function [eff_belt]=PLBeltEffReg1Curve(curve_index,x_belt,parameter)
% This function describes the relationship between the Belt efficiency and
% Belt fraction load in region 1 for V-Belt, where 0<=x_belt<x_belt_trans.



% Check for Input
if nargin<4
    parameter.coefficient=[0.920797 0.026269 0.151594];
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