function [signal]=PController(CV,SP,parameter_PController)
%% application
% this model describes the proportional control process through proportional controller.

%% description
% =========================input=========================
% CV:  control variable;
% SP:  set point of controlo variable;
% parameter_PController: a struct, which contains
%                        parameter_PController.k: proportional gain;

% =========================output=========================
% signal£º proportional signal produced in proportional controller;
%% equation
if nargin<3
    parameter_PController.k=0.05;
end

k=parameter_PController.k;

 error=CV-SP;
 miu=-k*error+0.5;
 
 signal=min(max(0,miu),1);