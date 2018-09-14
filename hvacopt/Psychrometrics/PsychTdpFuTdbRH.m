function Tdp=PsychTdpFuTdbRH(Tdb,RH)
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

% dew-point temperature: Tdp,[¡æ]£¬equation 39
c7=6.54;
c8=14.526;
c9=0.7389;
c10=0.09486;
c11=0.4569;
a=log(pv/1000);
Tdp=c7+c8*a+c9*a.^2+c10*a.^3+c11*(pv/1000).^0.1984;