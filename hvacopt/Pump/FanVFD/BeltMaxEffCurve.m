function [eff_belt_max]=BeltMaxEffCurve(curve_index,rated_belt_power,parameter)
% This model describes the relationship between the motor efficiency and
% input power .

%=====================================input===============================
% curve_index:      logical value, curve fitting or not;    [-]
% H_fan_max:        a vector,maximum fan shaft input power; [hp]
% eff_motor_max:    a vector, maximum motor efficiency;     [--]
% parameter:        a struct, describes the fitting curve;  
%                   parameter.type: describes the efficiency class of belt.
%                                   1--------high efficiency, low loss;
%                                   2--------medium efficiency, medium
%                                   loss;
%                                   3--------low efficiency, high loss.
%  Efficiency |   Motor rated|  Maximum  |  a_motor |  b_mptor   |   c_motor  |
%     class   |   output(hp) | efficiency|          |            |            |
%------------------------------------------------------------------------------
%    High     |   -6.502e-2  | 2.475e-2  | -6.841e-3|  9.383e-4  |  -5.168e-5 |
%------------------------------------------------------------------------------
%    Medium   |  -9.504e-2   | 3.415e-2  | -8.897e-3|  1.159e-3  |  -6.132e-5 |
%------------------------------------------------------------------------------
%    Low      |   -1.422e-1  | 5.112e-2  | -1.353e-2|  1.814e-3  |  -9.909e-5 |
%-------------------------------------------------------------------------------

%==============================output==================================
% eff_belt_max£»  a vector, maximum belt efficiency;  [--]

% Check for Input
if nargin<3
    parameter.type=1;
end


if (parameter.type==1)
    coefficient=[-6.502e-2 2.475e-2 -6.841e-3 9.383e-4 -5.168e-5];
elseif (parameter.type==2)
    coefficient=[-9.504e-2 3.415e-2 -8.897e-3 1.159e-3 -6.132e-5];
elseif (parameter.type==3)
    coefficient=[-1.422e-1 5.112e-2 -1.353e-2 1.814e-3 -9.909e-5];
else
    coefficient=[0 0 0 0 0];
    warning('No such type belt');
end

if curve_index~=0
    % Initialization for the Input
    a=coefficient(1);
    b=coefficient(2);
    c=coefficient(3);
    d=coefficient(4);
    e=coefficient(5);
    
    % Predicted belt efficiency by fitted curve
    x_belt_max=log(rated_belt_power);
    y=a+b.*x_belt_max+c.*x_belt_max.^2+d.*x_belt_max.^3+e.*x_belt_max.^4;
    eff_belt_max=exp(y);
    
else
    eff_belt_max=0.95;
end
end