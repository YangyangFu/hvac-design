function [ AirIn ] = PsychInfo( AirIn )
%PSYCHINFO Calculates all the Psychmetric information of air from given dry
%bulb temperature and relative humidity.
names=fieldnames(AirIn);
if (strcmp(names(1),'temp')&&strcmp(names(2),'RH'))||(strcmp(names(1),'RH')&&strcmp(names(2),'temp'))
    
    AirIn.W=PsychWFuTdbRH(AirIn.temp,AirIn.RH);
    AirIn.DewPTemp=PsychTdpFuWP(AirIn.W);
    AirIn.H=PsychHFuTdbW(AirIn.temp,AirIn.W);
    AirIn.Twb=PsychTwbFuTdbW(AirIn.temp,AirIn.W);
    
elseif (strcmp(names(1),'temp')&&strcmp(names(2),'Twb'))||(strcmp(names(1),'Twb')&&strcmp(names(2),'temp'))
    
    AirIn.RH=PsychRHFuTdbTwb(AirIn.temp,AirIn.Twb);
    AirIn.W=PsychWFuTdbRH(AirIn.temp,AirIn.RH);
    AirIn.DewPTemp=PsychTdpFuWP(AirIn.W);
    AirIn.H=PsychHFuTdbW(AirIn.temp,AirIn.W);
elseif (strcmp(names(1),'temp')&&strcmp(names(2),'W'))||(strcmp(names(1),'W')&&strcmp(names(2),'temp'))
    
    AirIn.RH=PsychRHFuTdbW(AirIn.temp,AirIn.W);
    AirIn.DewPTemp=PsychTdpFuWP(AirIn.W);
    AirIn.H=PsychHFuTdbW(AirIn.temp,AirIn.W);
    AirIn.Twb=PsychTwbFuTdbW(AirIn.temp,AirIn.W);
else
    error ('No comparable struct name in PsychInfo,please check your input instruct');
end

end

