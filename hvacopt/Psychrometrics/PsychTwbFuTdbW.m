function [WetBulb]=PsychTwbFuTdbW(Tdb,WDes)

%% Function to calculate wet-bulb temperature from dry-bulb and humidity ratio.

RH_max=1;
HfgRef=2501000;
CpVap=1805;
CpWat=4186;
CpAir=1006;
tolRel=0.000001;

W_sat=PsychWFuTdbRH(Tdb,RH_max);
Twb_old=Tdb;
W_old=W_sat;
Twb_new=Twb_old-1;
Twb=Twb_new-0.5;

while abs((Twb_new-Twb)./Twb)>tolRel
    Twb=Twb_new;
    W_init=PsychWFuTdbRH(Twb,RH_max);
    W=((HfgRef-(CpWat-CpVap).*Twb).*W_init-CpAir.*(Tdb-Twb))./(HfgRef+CpVap.*Tdb-CpWat.*Twb);
    slope=(W-W_old)./(Twb-Twb_old);
    
    Twb_new=Twb-(W-WDes)./slope;
    if abs(W-WDes)<abs(W_old-WDes)
        W_old=W;
        Twb_old=Twb;
    end
end
WetBulb=Twb;
