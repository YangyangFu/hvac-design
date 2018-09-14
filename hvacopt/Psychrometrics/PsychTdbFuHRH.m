function [Tdb]=PsychTdbFuHRH(H,RH,barom_pressure)
%% Calculates dry-bulb temperature from enthalpy and relative humidity.
if nargin<3
    barom_pressure=101325;        
end
tolRel=0.000001;
YTarget=H;
X_old=25;
Y_old=PsychHFuTdbW(X_old,PsychWFuTdbRH(X_old,RH,barom_pressure));

X_new=X_old+1;
X=X_new+0.4;
while abs((X_new-X)./X)>tolRel
     X=X_new;
     Y=PsychHFuTdbW(X,PsychWFuTdbRH(X,RH,barom_pressure));
    slope=(Y-Y_old)./(X-X_old);
    X_new=X-(Y-YTarget)./slope;
    
    if abs(Y-YTarget)<abs(Y_old-YTarget)
        Y_old=Y;
        X_old=X;
    end
end

Tdb=X_new;