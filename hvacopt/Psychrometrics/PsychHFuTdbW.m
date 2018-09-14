function [H]=PsychHFuTdbW(Tdb,W)
%% Calculate enthalpy from dry bulb temperature and humidity ratio.

H=1000*(1.006*Tdb+W.*(2501+1.86*Tdb));