function [W]=PsychWFuTdbH(Tdb,h)
%% Calculate humidity ratio from enthalpy and dry bulb temperature.

W=(h/1000-1.006*Tdb)./(2501+1.86*Tdb);
end
