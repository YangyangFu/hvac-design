function [eff_VFD_dim]=VFDEffCurve(curve_index,x_VFD,parameter)
% This model describes the relationship between the motor efficiency and
% input power .

%=====================================input===============================
% curve_index:      logical value, curve fitting or not;
% x_motor:          a vector,fraction of full-load output power for the motor, which is
%                   typically called "motor load"
% eff_motor_max:    a vector, maximum motor efficiency
% parameter:        a struct, describes the fitting curve
%                   parameter.HP: describes the output horse power of the motor.
%
% |   VFD rated  |  a_VFD   |  b_VFD     |   c_VFD    |
% |   output(hp) |          |            |            |
%------------------------------------------------------
% |       3      |  0.978856|  0.034247  |   -0.007862|
%------------------------------------------------------
% |       5      |  0.977485|  0.028413  |  -0.002733 |
%------------------------------------------------------
% |       10     |  0.978715|  0.022227  |   0.001941 |
%------------------------------------------------------
% |       20     |  1.137209|  0.050236  |  -0.089150 |
%------------------------------------------------------
% |       30     |  0.984973|  0.017545  |  -0.000475 |
%------------------------------------------------------
% |       50     |  0.987910|  0.018376  |  -0.001692 |
%------------------------------------------------------
% |       60     |  0.971904|  0.014537  |   0.011849 |
%------------------------------------------------------
% |       75     |  0.991874|  0.017897  |  -0.001301 |
%------------------------------------------------------
% |       100    |  0.982384|  0.012598  |   0.001405 |
%------------------------------------------------------
% |       200    |  0.984476|  0.009828  |  -0.004560 |
%------------------------------------------------------
%==============================output=========================
% eff_VFD£»  a vector, motor efficiency at part load

% Check for Input
if nargin<3
    parameter.HP=5;
end


if ((parameter.HP>=1)&&(parameter.HP<5))
    coefficient=[0.978856 0.034247 -0.007862];
elseif ((parameter.HP>=5)&&(parameter.HP<10))
    coefficient=[0.977485 0.028413 -0.002733];
elseif ((parameter.HP>=10)&&(parameter.HP<20))
    coefficient=[0.978715 0.022227 0.001941];
elseif ((parameter.HP>=20)&&(parameter.HP<30))
    coefficient=[0.984973 0.017545 -0.000475];
elseif ((parameter.HP>=30)&&(parameter.HP<50))
    coefficient=[0.987405 0.015536 -0.005937];
elseif ((parameter.HP>=50)&&(parameter.HP<60))
    coefficient=[0.987910 0.018376 -0.001692];
elseif ((parameter.HP>=60)&&(parameter.HP<75))
    coefficient=[0.971904 0.014537 0.011849];
elseif ((parameter.HP>=75)&&(parameter.HP<100))
    coefficient=[0.991874 0.017897 -0.001301];
elseif ((parameter.HP>=100)&&(parameter.HP<200))
    coefficient=[0.982384 0.012598 0.001405];
elseif (parameter.HP>=200)
    coefficient=[0.984476 0.009828 -0.004560];
    
end

if curve_index~=0
    % Initialization for the Input
    a_VFD=coefficient(1);
    b_VFD=coefficient(2);
    c_VFD=coefficient(3);
    
    % Predicted belt efficiency by fitted curve
    eff_VFD_dim=a_VFD*x_VFD./(b_VFD+x_VFD)+c_VFD*x_VFD;
    
else
    eff_VFD_dim=1;
end
end