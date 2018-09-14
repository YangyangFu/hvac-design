function [ Tdb ] = PsychTdbFuHW( h,W )
%PSYCHTDBFUHW Calculate dry bulb temperature from enthalpy and humidity
%ratio
%   此处显示详细说明


Tdb=(h/1000-2501*W)./(1.006+1.86*W);


end

