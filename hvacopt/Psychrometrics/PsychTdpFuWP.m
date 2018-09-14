function Tdp=PsychTdpFuWP(W,barom_pressure)
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
if nargin<2
    barom_pressure=101325;        
end
%
pv=W*barom_pressure./(1+W)./0.621945;
% dew-point temperature: Tdp,[¡æ]£¬equation 39
c7=6.54;
c8=14.526;
c9=0.7389;
c10=0.09486;
c11=0.4569;
a=log(pv/1000);
Tdp=c7+c8*a+c9*a.^2+c10*a.^3+c11*(pv/1000).^0.1984;
% wet-bulb temperature: Twb,[¡æ],equation 35;!!!!!!!! iterations are needed.


end

