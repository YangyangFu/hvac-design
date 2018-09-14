function [ TW2D,TW2W ] = CoolingCoilTransys
%C-----------------------------------------------------------------------------------------------------------------------
%C  THIS ROUTINE DETERMINES THE THERMAL PERFORMANCE OF A COOLING COIL  *
%C  USING AN EFFECTIVENESS MODEL AS DESCRIBED IN "METHODOLOGIES FOR    *
%C  THE DESIGN AND CONTROL OF CHILLED WATER SYSTEMS", PHD THESIS,      *
%C  SOLAR ENERGY LABORATORY, UNIVERSITY OF WISCONSIN, J.E. BRAUN, 1988 *
%C****************************  PARAMETERS  ****************************
%C
%C    MODE   = SIMPLE OR DETAILED CALCULATIONS
%C    IU     = UNITS: 1-SI, 2-ENGLISH%
%C    NROWS  = NUMBER OF ROWS OF TUBES
%C    NTUBES = NUMBER TUBES PER ROW
%C    LT     = LENGTH OF TUBES IN EACH ROW
%C    WD     = WIDTH OF DUCT PERPENDICULAR TO THE TUBES
%C    DO     = TUBE OUTER DIAMETER
%C    DI     = TUBE INNER DIAMETER
%C    KT     = TUBE THERMAL CONDUCTIVITY
%C    FT     = FIN THICKNESS
%C    FS     = FIN SPACING
%C    NFINS  = NUMBER OF FINS ON ONE TUBE
%C    KF     = FIN THERMAL CONDUCTIVITY
%C    FMODE  = CONTINUOUS FLAT PLATE OR ANNULAR FINS
%C    ADIST  = DISTANCE BETWEEN TUBE CENTERS ACROSS ROW
%C    DE     = DIAMETER OF ANNULAR FIN
%C    CDIST  = DISTANCE BETWEEN TUBE ROW CENTERLINES (FLOW DIRECTION)
%C-----------------------------------------------------------------------------------------------------------------------
%! Copyright ?2004 Solar Energy Laboratory, University of Wisconsin-Madison. All rights reserved.

%C-----------------------------------------------------------------------------------------------------------------------

%C-----------------------------------------------------------------------------------------------------------------------
%C-----------------------------------------------------------------------------------------------------------------------
%C  EMODE DETERMINES HOW ERRORS ARE HANDLED FROM CALLS TO THE PSYCH
%C  SUBROUTINE. IF EMODE IS: 0 - NO ERROR MESSAGES WILL BE PRINTED,
%C  1 - ERROR MESSAGES WILL BE PRINTED ONLY ONCE PER SIMULATION,
%C  2 - ERROR MESSAGES WILL BE PRINTED EVERY TIMESTEMP THAT THEY OCCUR.
%C
%      DATA EMODE/1/
%C
%C*********************** STATEMENT FUNCTIONS **************************
%C
%C-- ROUND-OFF REAL NUMBERS TO NEAREST INTEGER
%C
%      ROUND(RNUM) = JFIX(RNUM + SIGN(0.5,RNUM))
%C
%C-- UNIT CONVERSIONS FOR TEMPERATURE AND ENTHALPY
%C
%C   TEMPERATURE:  SI TO ENGLISH (IU=2), SI TO SI (IU=1)
%C   ENTHALPY:     ENGLISH TO SI (IU=2), SI TO SI (IU=1)
%C   TEMPERATURE:  ENGLISH TO ENGLISH (IU=2), SI TO ENGLISH (IU = 1)

%C-- CORRELATION FOR SATURATION TEMPERATURE IN TERMS OF SATURATION
%C   ENTHALPY: CORRELATION IS IN SI UNITS AND IS GOOD FROM 9.473 KJ/KG
%C   TO 355.137 KJ/KG (0 C TO 55 C).
%C   (CORRELATION IS FOR A TOTAL SYSTEM PRESSURE OF 1 ATMOSPHERE)
%C
%      TSAT     = -5.79013 + 6.64030e-01.*HS - 5.07802e-03*HS.^2 + ...
%                   2.80381e-05.*HS.^3 - 9.47051e-08*HS.^4 +...
%                   1.72758e-10.*HS.^5 - 1.29547e-13.*HS.^6;
%C
%C
%C-- CORRELATION FOR KINEMATIC WATER VISCOSITY IN TERMS OF TEMPERATURE:
%C   CORRELATION IS IN ENGLISH UNITS (LBM/FT-HR AND DEG. F) AND
%C   IS GOOD FROM 32 F TO 200 F.
%C
%      MHUW(T) = MCONV(IU)*(7.67201 - 1.39290E-01*T + 1.23322E-03*T**2
%     .         - 5.32425E-06*T**3 + 8.87455E-09*T**4)
%C
%C-- CORRELATION FOR PRANTL NUMBER OF WATER IN TERMS OF TEMPERATURE:
%C   TEMPERATURE IS IN ENGLISH UNITS (DEG. F) AND THE CORRELATION IS
%C   GOOD FROM 32 F TO 200 F.
%C
%      PRW(T)  = 2.73327E01 - 6.30480E-01*T + 7.56704E-03*T**2 -
%     .          5.04074E-05*T**3 + 1.74546E-07*T**4 - 2.43923E-10*T**5
%
%C-----------------------------------------------------------------------------------------------------------------------

parameter.PAR=[1,30,30,0.5,1.22,0.025,0.02,377,0.01,0.1,25,230,2,0.05,0.35]';


%C-----------------------------------------------------------------------------------------------------------------------
%C       READ IN THE VALUES OF THE PARAMETERS IN SEQUENTIAL ORDER
PAR=parameter.PAR;

% Simple or detailed calculations
MODE=round(PAR(1));
%IF(MODE.NE.1 .AND. MODE.NE.2) CALL TYPECK(-4,INFO,0,0,0)
% Number of rows
NROWS  = round(PAR(2));
% Number of tubes
NTUBES = round(PAR(3));
% Length of tubes in each row
LT     = PAR(4);
% WIDTH OF DUCT PERPENDICULAR TO THE TUBES
WD     = PAR(5);
% Tube outer diameter
DO     = PAR(6);
% Tube inner diameter
DI     = PAR(7);
% TUBE THERMAL CONDUCTIVITY(kJ/hr.m.K)
KT     = PAR(8);
% Fin thickness
FT     = PAR(9);
% Fin spacing
FS     = PAR(10);
% Number of Fins on one tube
NFINS  = round(PAR(11));
% Fin thermal conductivity(kJ/hr.m.K)
KF     = PAR(12);
% Continuous flat plate or annular fins
FMODE=round(PAR(13));
% Distance between tube centers across row
ADIST  = PAR(14);
% Diameter of annular fin
if (FMODE == 2) 
    DE = ADIST;
end
% Distance between tube row centerlines(flow direction)
CDIST  = PAR(15);

%C** COIL AREAS **
%C
%C   RI & RO - INSIDE AND OUTSIDE TUBE RADIUS
%C        RE - ANNULAR FIN RADIUS OF EQUIVALENT RADIUS FOR
%C             CONTINUOUS FLAT FINS
%C        FH - FIN HEIGHT
%C   AI & AO - INSIDE AND OUTSIDE COIL SURFACE AREAS
%C    FRATIO - RATIO OF FIN AREA TO OUTSIDE COIL SURFACE AREA
%C     LCOIL - LENGTH OF THE COIL SECTION IN THE AIR FLOW DIRECTION
%C             (SEE KAYS & LONDON, "COMPACT HEAT EXCHANGERS")
%C        AC - FLOW CROSS SECTIONAL AREA
%C        AX - CROSS SECTIONAL AREA OF ONE TUBE
%C
RI  = DI/2;
RO  = DO/2;
if (FMODE == 1)
    RE = sqrt(ADIST*CDIST/pi);
    AC = LT*WD-NFINS*FT*(NTUBES*ADIST+ADIST/2.)...
        -(NTUBES*LT*DO-(NFINS*FT*DO));
else
    RE = DE/2;
    AC = LT*WD-NTUBES*LT*DO-NTUBES*NFINS*(DE-DO)*FT;
end
% LENGTH OF THE COIL SECTION IN THE AIR FLOW DIRECTION
LCOIL = NROWS * CDIST;
FH  = RE - RO;
AX  = pi*RI^2;
AI  = NTUBES*NROWS*pi*DI*LT;
ATO = NTUBES*NROWS*pi*DO*(LT-NFINS*FT);
AF  = NFINS*NTUBES*NROWS*2*pi*(RE^2-RO^2);
AO  = ATO + AF;
FRATIO = AF/AO;
%C
%C** TUBE HEAT TRANSFER COEFFICIENT **
%C   BASED UPON INSIDE AREA
%C
UM = KT/RI/log(RO/RI);
%C-----------------------------------------------------------------------------------------------------------------------

%C******************************  INPUTS   ****************************
%C
%C  TA1     = ENTERING AIR DRY BULB TEMPERATURE (C, F)
%C  WA1     = ENTERING AIR HUMIDITY RATIO
%C  MA      = MASS FLOW RATE OF AIR (KG/HR, LBM/HR)
%C  TW1     = ENTERING WATER TEMPERATURE (C, F)
%C  MW      = MASS FLOW RATE OF WATER (KG/HR LBM/HR)
%C
TA1  =27;% XIN(1);
WA1  = 0.01;%XIN(2);
MA   = 54000;%XIN(3);
TW1  = 7;%XIN(4);
MW   = 60696;%XIN(5) ;%(kg/h)

%C-----------------------------------------------------------------------------------------------------------------------
%C************************* COIL ANALYSIS *************************
%C
%C  TA2     = DRY-BULB TEMPERATURE OF AIR LEAVING COIL
%C  WA2     = ABSOLUTE HUMIDITY OF AIR LEAVING COIL
%C  RHA2    = RELATIVE HUMIDITY OF AIR LEAVING COIL
%C  TW2     = DRY-BULB TEMPERATURE OF WATER LEAVING COIL
%C  QCOIL   = TOTAL HEAT TRANSFER TO COIL
%C  QSENS   = SENSIBLE HEAT REMOVED FROM MOIST AIR
%C  QLAT    = LATENT HEAT REMOVED FROM MOIST AIR
%C  QDAIR   = SENSIBLE HEAT REMOVED FROM AIR ONLY (DRY AIR)
%C  FDRY    = FRACTION OF COIL WHICH IS DRY
%C  GW      = WATER MASS FLOW RATE DIVIDED BY CROSS-SECTIONAL AREA
%C  REI     = INSIDE REYNOLDS NUMBER
%C  HI      = INSIDE COEFFICIENT OF CONVECTION
%C  GA      = AIR MASS FLOW RATE DIVIDED BY CROSS-SECTIONAL AREA
%C  REO     = OUTSIDE REYNOLDS NUMBER
%C  CPM     = MOIST AIR HEAT CAPACITY
%C  NTUO    = NTU'S OUTSIDE
%C  NTUI    = NTU'S INSIDE
%C  TDP     = AIR DEW-POINT
%C  HA1     = ENTHALPY OF ENTERING AIR
%C  HA2     = ENTHALPY OF EXITING AIR


    
    %C ***   FLOW    ***
    %C ** INSIDE FLUID COEFFICIENT **
    %C  FIND THE REYNOLDS NUMBER
    GW    = MW/NTUBES/AX; %
    TPROP = 1.8*TW1+32;% 参见温度转换，转换为华氏
    mhu =(7.67201 - 1.39290e-01*TPROP+ 1.23322e-03*TPROP.^2 - 5.32425e-06*TPROP.^3 + 8.87455e-09*TPROP.^4)*1.488;
    % 求解雷诺数
    
    REI  = GW*DI/mhu;
    
    %C  IF THE REYNOLDS NUMBER IS GREATER THEN 3000, USE THE CORRELATION
    %C  FOR TURBULENT WATER FLOW IN A TUBE.  IF THE REYNOLDS NUMBER IS
    %C  LESS THAN 2000, USE THE CORRELATION FOR LAMINAR WATER FLOW IN A
    %C  TUBE.  FOR A REYNOLDS NUMBER BETWEEN 2000 AND 3000, A LINEAR
    %C  RELATIONSHIP BETWEEN THE CONVECTION COEFFICIENTS FOR THE TURBULENT
    %C  AND LAMINAR CASES IS USED.  THE INLET TEMPERATURE IS USED FOR
    %C  PROPERTY EVALUATIONS.
    if (REI >= 3000)
        PRW=2.73327e01 - 6.30480e-01*TPROP + 7.56704e-03*TPROP.^2 -...
               5.04074e-05*TPROP.^3 + 1.74546e-07*TPROP.^4 - 2.43923e-10*TPROP.^5;
        HI = 0.023*2.043./DI.*REI.^0.8*PRW^0.4;
    elseif (REI <= 2000.)
        HI = 4.36*2.043./DI;
    else
        PRW=2.73327e01 - 6.30480e-01*TPROP + 7.56704e-03*TPROP.^2 -...
               5.04074e-05*TPROP.^3 + 1.74546e-07*TPROP.^4 - 2.43923e-10*TPROP.^5;
        HIT = 0.023*2.043./DI.*REI.^0.8.*PRW^0.4;
        HIL = 4.36*2.043./DI;
        HI = HIL + (REI - 2000) .* (HIT - HIL)./ 1000;
    end
    %C ** OUTSIDE COEFFICIENT FOR DRY SURFACES **
    %C   CORRELATION FOR OUTSIDE HEAT TRANSFER COEFFICIENT IS FROM
    %C   "FINNED TUBE HEAT EXCHANGER: CORRELATION OF DRY SURFACE HEAT
    %C   TRANSFER DATA," A.H. ELMAHDY, ASHRAE TRANSACTIONS.  THE
    %C   HYDRAULIC DIAMETER IS: 2 * THE FLOW LENGTH OF THE HEAT EXCHANGER *
    %C   THE FLOW CROSS SECTIONAL AREA / TOTAL HEAT TRANSFER AREA.
    %C   THE FIN EFFICIENCY EQUATION IS FOR ANNULAR FINS.  STRAIGHT FINS
    %C   ARE TREATED AS ANNULAR FINS BY FINDING AN EQUIVALENT ANNULAR FIN
    %C   WITH THE SAME SURFACE AREA.
    DH  = 4.*LCOIL*AC/AO;
    CJ1 = 0.159*(FT./FH).^0.141*(DH./FT).^0.065;
    CJ2 = -0.323.*(FT./FH).^0.049.*(FS./FT)^0.077;
    GA  = MA./AC;
    REO = GA.*DH./0.0659;
    JF  = CJ1.*REO.^CJ2;
    HDO = GA.*1.005*JF./0.72^0.6667; % CPA: Cp Air;
    
    %C FIN EFFICIENCY CALCULATIONS
    ALPHA  = RO./RE;
    BETA   = RE*sqrt(2*HDO./KF./FT);
    EFF = FIN(ALPHA,BETA);
    EFFD = 1 - FRATIO.*(1-EFF);
    
    %C ** DETERMINE NTU'S **
    %C   THE AIR SPECIFIC HEAT IS FOR MOIST AIR
    CPM  = 1.005 + WA1*1.884;
    NTUO = EFFD.*HDO.*AO./(MA.*CPM);
    NTUI = AI./(1./HI + 1./UM)/(MW.*4.186);
    RA   = MW./MA;
    %C ** ENTHALPIES FOR ENTERING CONDITIONS **
    PSYDAT(2) = TA1;
    PSYDAT(6) = WA1;
   
    TDP = PsychTdpFuTdbRH(TA1,PsychRHFuTdbW(TA1,WA1));
    HA1 = PsychHFuTdbW(TA1,WA1);
    PSYDAT(2) = TW1;
    PSYDAT(3) = TW1;
  
    HW1 = PsychHFuTdbRH(TW1,1);
    row=size(TA1,1);
    k=1;
while k<=row
    %C ** DRY ANALYSIS **
    %C   DETERMINES THE AIR EFFECTIVENESS (EPSD) AND OUTLET WATER TEMPERATURE
    %C   (TW2D) ASSUMING THE COIL IS DRY
    %C   IF THE SURFACE TEMPERATURE AT THE OUTLET IS GREATER THAN THE AIR
    %C   ENTERING DEWPOINT THEN COIL IS COMPLETELY DRY, OTHERWISE DO THE WET
    %C   ANALYSIS
    CSTAR = CPM./RA./4.186;
    NTUD   = NTUO./(1 + NTUO./NTUI.*CSTAR);
    TEMP = -NTUD.*(1-CSTAR);
    if (TEMP < 50.0)
        C     = exp(TEMP);
        EPSD  = (1 - C)./(1 - CSTAR.*C);
    else
        EPSD = 1./CSTAR;
    end
    TW2D  = TW1 + EPSD.*CSTAR.*(TA1 - TW1);
    TA2D  = TA1 - EPSD.*(TA1 - TW1);
    TS2D  = TW1 + CSTAR.*NTUD./NTUI.*(TA2D - TW1);
    %C
    DRY   = (TS2D > TDP);
    FDRY = 1;
    if(~ DRY)
        FDRY = 0;
        
        %C ** WET COIL **
        %C   DETERMINES THE AIR EFFECTIVENESS (EPSW) AND OUTLET WATER TEMPERATURE
        %C   (TW2W) ASSUMING THE COIL IS WET.
        %C   THE AVERAGE SATURATION SPECIFIC HEAT (CS) DEPENDS UPON THE OUTLET
        %C   CONDITIONS; THEREFORE AN ITERATIVE SOLUTION.
        %C   THE WET SURFACE HEAT TRANSFER COEFFICIENT (HWO) AND THEREFORE THE FIN
        %C   EFFICIENCY (EFFW) DEPEND UPON THE SATURATION SPECIFIC HEAT.
        %C   IF THE SURFACE TEMPERATURE AT WATER OUTLET IS LESS THAN THE DEWPOINT
        %C   OF THE ENTERING AIR THEN THE COIL IS COMPLETELY WET.
        
        % Assume the initial water side outlet temperature
        
        TW2WInit = TW2D;
        fun=@TW2Equation;
        TW2W=fzero(fun,TW2WInit);
        
        % Calculate the effective saturation enthalpy
        HA2=HA1-EPSW.*(HA1-HW1);
        HSSE=HA1+(HA2-HA1)./(1-exp(NTUO));
        
        TSE=PsychTdbFuHRH(HSSE,1);
        
        % Calculate the exit air temperature
        TA2W=TSE+(TA1-TSE).*exp(-NTUO);
        
        TS1W = TW2W + CSTAR/CPM*NTUW/NTUI*(HA1 - HW2);
    end
    
    %C ***  NO FLOW  ***
    if (MA <= 1.0e-06 || MW <= 1.0e-06)
        TA2   = TA1;
        if (MA <= 1.0e-02 && MW >= 1.0e-02)
            TA2 = TW1;
        end
        WA2   = WA1;
        RHA2  = RHA1;
        TW2   = TW1;
        QCOIL = 0.0;
        QSENS = 0.0;
        QLAT  = 0.0;
        QDAIR = 0.0;
        FDRY  = 1.0;
        GOTO 500
    end
    
    k=k+1;
end
%C-----------------------------------------------------------------------------------------------------------------------
%C    SET THE OUTPUTS FROM THIS MODEL IN SEQUENTIAL ORDER AND GET OUT
%C****************************** OUTPUTS *****************************
%C
QCOIL = MW*4.186*(TW2W - TW1);% kJ/hr
QLAT  = MA*(WA1 - WA2W)*2452;
QSENS = QCOIL - QLAT;
%C
%500   OUT(1) = TA2
%      OUT(2) = WA2
%      OUT(3) = MA
%      OUT(4) = TW2
%      OUT(5) = MW
%      OUT(6) = QCOIL
%      OUT(7) = QSENS
%      OUT(8) = QLAT
%      OUT(9) = FDRY%
%      OUT(10) = 100.*DMIN1(1.,(DMAX1(0.,RHA2)))

%C-----------------------------------------------------------------------------------------------------------------------

    function G=TW2Equation(TW2W)
        % Calculte Cs
        HW2=PsychTdbRH(TW2W,1);
        HW1=PsychTdbRH(TW1,1);
        CS    = (HW2 - HW1)/(TW2W - TW1);
        % Calculate m*
        MSTAR = CS/RA/4.186;
        
        % Calculate the wet coil NTU
        HWO   = CS*HDO/CPM;
        ALPHA = RO/RE;
        BETA  = RE*sqrt(2.*HWO/KF/FT);
        EFF   = FIN(ALPHA,BETA);
        EFFW  = 1 - FRATIO*(1-EFF);
        ERAT  = EFFW/EFFD;
        NTUW  = ERAT*NTUO/(1 + ERAT*NTUO/NTUI*MSTAR);
        
        % Calculate the wet coil tranfer effectiveness
        TEMP  = -NTUW*(1-MSTAR);
        if (TEMP < 50.0)
            C     = exp(TEMP);
            EPSW  = (1 - C)/(1 - MSTAR*C);
        else
            EPSW = 1/MSTAR;
        end
        
        G=TW2W-(TW1 + EPSW*(HA1 - HW1)/RA/4.186);
    end
end
%C******************************************************************************
%C  THIS FUNCTION CALCULATES THE FIN EFFICIENCY (EFFECTIVENESS)
%C  OF AN ANNULAR FIN OF CONSTANT THICKNESS.
%C
%C   ALPHA = RADIUS AT FIN BASE / RADIUS AT FIN TIP
%C   BETA  = RADIUS AT FIN TIP *
%C           (SQRT (2 * CONVECTION COEFFICIENT /
%C                  FIN CONDUCTIVITY * FIN THICKNESS))
function FinEffectiveness=FIN(ALPHA,BETA)

ALPBET = ALPHA * BETA;
[XI0,XI1,XK0,XK1]=BESSEL(ALPBET);

[YI0,YI1,YK0,YK1]=BESSEL(BETA);

FinEffectiveness=2*ALPHA./BETA./(1- ALPHA.^2).*(XK1.*YI1-XI1.*YK1)./(XK0.*YI1...
    +XI0.*YK1);
return
end
%C****************************************************************************


function [I0,I1,K0,K1]=BESSEL(X)
%C  THIS SUBROUTINE USES POLYNOMIAL APPROXIMATIONS TO EVALUATE
%C  THE BESSEL FUNCTIONS.  THE APPROXIMATIONS ARE FROM ABRAMOWITZ
%C  AND STEGUN, HANDBOOD OF MATHEMATICAL FUNCTIONS, DOVER
%C  PUBLICATIONS, INC., NEW YORK, NY.
%C
%      SUBROUTINE BESSEL(X,I0,I1,K0,K1)
%C  THE FOLLOWING DATA STATEMENTS CONTAIN THE COEFFICIENTS TO
%C  THE POLYNOMIALS.
%C  I0
A0=1;
A1=3.5156229;
A2=3.0899424;
A3=1.2067492;
A4=0.2659732;
A5=0.0360768;
A6=0.0045813;
%C  I0
B0=0.39894228;
B1=0.01328592;
B2=0.00225319;
B3=-0.00157565;
B4=0.00916281;
B5=-0.02057706;
B6=0.02635537;
B7=-0.01647633;
B8=0.00392377;

%C  I1
C0=0.5;
C1=0.87890594;
C2=0.51498869;
C3=0.15084934;
C4=0.02658733;
C5=0.00301532;
C6=0.00032411;
%C  I1
D0=0.39894228;
D1=-0.03988024;
D2=-0.00362018;
D3=0.00163801;
D4=-0.01031555;
D5=0.02282967;
D6=-0.02895312;
D7=0.01787654;
D8=-0.00420059;
%C  K0
E0=-0.57721566;
E1=0.4227842;
E2=0.23069756;
E3=0.0348859;
E4=0.00262698;
E5=0.0001075;
E6=0.0000074;
%C  K0
F0=1.25331414;
F1=-0.07832358;
F2=0.02189568;
F3=-0.01062446;
F4=0.00587872;
F5=-0.0025154;
F6=0.00053208;
%C  K1
G0=1.0;
G1=0.15443144;
G2=-0.67278579;
G3=-0.18156897;
G4=-0.01919402;
G5=-0.00110404;
G6=-0.00004686;
%C  K1
H0=1.25331414;
H1=0.23498619;
H2=-0.0365562;
H3=0.01504268;
H4=-0.00780353;
H5=0.00325614;
H6=-0.00068245;


%C
if (X < -3.75)
    error('X<-3.75 in Bessel function');
end
T=X/3.75;
TT=T*T;
%C I0
if (X < 3.75)
    I0=A0+TT.*(A1+TT.*(A2+TT.*(A3+TT.*(A4+TT.*(A5+TT.*A6)))));
else
    IT=1./T;
    I0=(B0+IT.*(B1+IT.*(B2+IT.*(B3+IT.*(B4+IT.*(B5+IT.*(B6+IT.*...
        (B7+IT.*B8))))))))/(sqrt(X).*exp(-X));
end
%C  I1
if (X < 3.75)
    I1=(C0+TT.*(C1+TT.*(C2+TT.*(C3+TT.*(C4+TT.*(C5+TT.*C6)))))).*X;
else
    IT=1./T;
    I1=(D0+IT.*(D1+IT.*(D2+IT.*(D3+IT.*(D4+IT.*(D5+IT.*(D6+IT.*...
        (D7+IT.*D8))))))))/(sqrt(X).*exp(-X));
end
%C  K0
if (X <0)
    error('X<0 in Bessel function');
end
X1 = (X./2).^2;
X2 = 2./X;
if (X < 2.0)
    K0=-log(X./2).*I0+E0+X1.*(E1+X1.*(E2+X1.*(E3+X1.*(E4+X1.*...
        (E5+X1.*E6)))));
else
    K0=(F0+X2.*(F1+X2.*(F2+X2.*(F3+X2.*(F4+X2.*(F5+X2.*F6))))))...
        /(sqrt(X).*exp(X));
end
%C  K1
if(X < 2.0)
    K1=(X.*log(X./2).*I1+G0+X1.*(G1+X1.*(G2+X1.*(G3+X1.*(G4+X1.*...
        (G5+X1.*G6))))))./X;
else
    K1=(H0+X2.*(H1+X2.*(H2+X2.*(H3+X2.*(H4+X2.*(H5+X2.*H6))))))...
        /(sqrt(X).*exp(X));
end
return
end

