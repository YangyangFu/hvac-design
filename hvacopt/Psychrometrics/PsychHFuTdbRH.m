function [ h ] = PsychHFuTdbRH( Tdb,RH )
%PSYCHHFUTDBRH 
%  
%% calculate enthalpy, obsolute humidity, Wet-bulb temperature and dew point temperature from dry-bulb temperature and relative humidity.[ASHARE handbook 2009]

%% discription
%===============input==============
% Tdb: dry-bulb temperature,[¡æ]
% RH; relative humidity
% barom_pressure: barometirc pressure,[Pa]


%==============output==============
% ps: saturation pressure, [Pa];
% pv: partial pressure of water vapor,[Pa]
% W: humidity ratio at Tdb and RH,[kg/kg(da)]
% Ws:humidity ratio at saturation at temperature Tdb,[kg/kg(da)]
% miu: degree of saturation
% v: specific volume of moist mixture,[m3/kg(da)]
% h: enthalpy of moist mixture;[J/(kg.K)]
% Tdp: dew-point temperature;
%% equations
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

% enthalpy of a mixture of perfect gas: h[J/kg(da)];equation 32;
h=1000*(1.006*Tdb+W.*(2501+1.86*Tdb));

end

