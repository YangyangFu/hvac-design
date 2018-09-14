function [eff_motor_max]=MotorMaxEffCurve(curve_index,rated_motor_power,parameter)
% This model describes the relationship between the motor efficiency and
% input power .

%=====================================input===============================
% curve_index:               logical value, curve fitting or not;    [-]
% rated_motor_output:        a vector,maximum fan shaft input power; [hp]
% eff_motor_max:             a vector, maximum motor efficiency;     [--]
% parameter:                 a struct, describes the fitting curve;
%                         parameter.type: describes the efficiency class of belt.
%                                   1--------high efficiency, low loss;
%                                   2--------medium efficiency, medium
%                                   loss;
%                                   3--------low efficiency, high loss.
%  Efficiency |       a      |     b     |     c    | 
%     class   |              |           |          | 
%----------------------------------------------------
%    High     |  0.196205    | 3.653654  |  0.839926| 
%----------------------------------------------------
%    Medium   |  0.292280    | 3.368739  |  0.762471|  
%----------------------------------------------------
%    Low      |  0.395895    | 3.065240  |  0.674321| 
%----------------------------------------------------

%==============================output==================================
% eff_belt_max£»  a vector, maximum belt efficiency;  [--]

% Check for Input
if nargin<3
    parameter.type=1;
end


if (parameter.type==1)
    coefficient=[0.196205 3.653654 0.839926];
elseif (parameter.type==2)
    coefficient=[0.292280 3.368739 0.762471];
elseif (parameter.type==3)
    coefficient=[0.395895 3.065240 0.674321];
else
    coefficient=[0 0 0];
    warning('No such type belt');
end

if curve_index~=0
    % Initialization for the Input
    a=coefficient(1);
    b=coefficient(2);
    c=coefficient(3);
    
    % Predicted maximum motor efficiency by fitted curve
    x_motor_max=log(rated_motor_power);
    eff_motor_max=a*x_motor_max./(b+x_motor_max)+c;
       
else
    eff_motor_max=0.95;
end
end