function [W]=PsychWFuTdbRH(Tdb,RH,barom_pressure)
%% Calculate humidity ratio from dry-bulb temperature and relative humidity.

if nargin<3
    barom_pressure=101325;        
end
% obsolute temperature, T_obsolute [K]
T_obsolute=Tdb+273.15;
% saturation pressure:ps[Pa],equation 6
c1=6.5459673;
c2=-5.8002206*10^3;
c3=1.3914993;
c4=-4.8640239*10^(-2);
c5=4.1764768*10^(-5);
c6=-1.4452093*10^(-8);

ps=exp(c2./T_obsolute+c3+c4*T_obsolute+c5*T_obsolute.^2+c6*T_obsolute.^3+c1*log(T_obsolute));

% partial pressure of water vapor:pv equation 24
pv=RH.*ps;

% humidity ratio:W,equation 22
W=0.621945*pv./(barom_pressure-pv);