function [eff_motor_dim]=PLMotorEffCurve(curve_index,x_motor,parameter)
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
%  Poles |   Motor rated|  Maximum  |  a_motor |  b_mptor   |   c_motor  |
%        |   output(hp) | efficiency|          |            |            |
%-------------------------------------------------------------------------
%    8   |       1      |    0.6675 |  1.096694|  0.097126  |   0.002011 |
%-------------------------------------------------------------------------
%    4   |       1      |    0.7787 |  1.092165|  0.082060  |  -0.007200 |
%-------------------------------------------------------------------------
%    4   |       5      |    0.8400 |  1.223684|  0.084670  |  -0.135186 |
%-------------------------------------------------------------------------
%    4   |       10     |    0.8745 |  1.146258|  0.045766  |  -0.110367 |
%-------------------------------------------------------------------------
%    4   |       25     |    0.8991 |  1.137209|  0.050236  |  -0.089150 |
%------------------------------------------------------------------------
%    4   |       50     |    0.9129 |  1.088803|  0.029753  |  -0.064058 |
%-------------------------------------------------------------------------
%    4   |       75     |    0.9259 |  1.077140|  0.029005  |  -0.049350 |
%-------------------------------------------------------------------------
%    4   |       100    |    0.9499 |  1.035294|  0.012948  |  -0.024708 |
%-------------------------------------------------------------------------
%    4   |       125    |    0.9527 |  1.030968|  0.010696  |  -0.023514 |
%-------------------------------------------------------------------------
%==============================output==================================
% eff_motor£»  a vector, motor efficiency at part load

% Check for Input
if nargin<3
    parameter.HP=5;
end


if ((parameter.HP>=1)&&(parameter.HP<5))
    coefficient=[1.092165 0.082060 -0.007200];
elseif ((parameter.HP>=5)&&(parameter.HP<10))
    coefficient=[1.223684 0.084670 -0.135186];
elseif ((parameter.HP>=10)&&(parameter.HP<25))
    coefficient=[1.146258 0.045766 -0.110367];
elseif ((parameter.HP>=25)&&(parameter.HP<50))
    coefficient=[1.137209 0.050236 -0.089150];
elseif ((parameter.HP>=50)&&(parameter.HP<75))
    coefficient=[1.088803 0.029753 -0.064058];
elseif ((parameter.HP>=75)&&(parameter.HP<100))
    coefficient=[1.077140 0.029005 -0.049350];
elseif ((parameter.HP>=100)&&(parameter.HP<125))
    coefficient=[1.035294 0.012948 -0.024708];
elseif ((parameter.HP>=125))
    coefficient=[1.030968 0.010696 -0.023514];
end

if curve_index~=0
    % Initialization for the Input
    a_motor=coefficient(1);
    b_motor=coefficient(2);
    c_motor=coefficient(3);
    
    % Predicted belt efficiency by fitted curve
    eff_motor_dim=(a_motor*x_motor./(b_motor+x_motor)+c_motor*x_motor);    
else
    row=size(x_motor,1);
    eff_motor_dim=ones(row,1);
    
end
end