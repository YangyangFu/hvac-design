
clear;
clc;


parameter_chiller(1).coefficient=[0.257896 0.389016*10^(-1) -0.217080*10^(-3) 0.468684*10^(-1) -0.94284*10^(-3) -0.343440*10^(-3)];
    parameter_chiller(2).coefficient=[0.933884 -0.582120*10^(-1) 0.450036*10^(-2) 0.243000*10^(-2) 0.486000*10^(-3) -0.121500*10^(-2)];
    parameter_chiller(3).coefficient=[1.7059 -2.2032 1.5028 0];
    parameter_chiller(1).nominal=2813000;
    parameter_chiller(2).nominal=6;
    parameter_chiller(3).nominal=0.97;
    parameter_chiller(1).flowrate=0.134444;
    parameter_chiller(2).flowrate=0.161944;
    parameter_chiller(1).PLR=0.15;
    parameter_chiller(2).PLR=1.2;
    parameter_chiller(3).PLR=0.25;
    parameter_chiller(1).resistance=6;    % resistance factor, whose range can be [1 10]
    parameter_chiller(2).resistance=4;
    parameter_chiller(1).density=999.4;   % water density at 10 ¡æ in evaporator;
    parameter_chiller(2).density=995.5;   % water density at 30 ¡æ in condenser;
    parameter_chiller(1).cp=4191.4;       % water specific heat at 10 ¡æ£»
    parameter_chiller(2).cp=4178.4;       % water specific heat at 30 ¡æ£»

temp_SP=[5.5:0.5:9]';
[r,c]=size(temp_SP);
temp_entering_cw=28*ones(r,1);
temp_entering_chw=12*ones(r,1);

load=2000000*ones(r,1);

NumON=2*ones(r,1);
Schedule=ones(r,1);

for i=1:r
    
    
    [ EvaOutlet,ConOutlet,Power,HeatEva,COP,PLR]=DesEleChillerEIR(temp_entering_chw(i),temp_entering_cw(i),temp_SP(i),NumON,Schedule,parameter_chiller);
    
    temp_chw=EvaOutlet.temp;
    temp_cw=ConOutlet.temp;
    HEAT_EVA=HeatEva;
    
    power=Power;
    COP_OUT(i)=COP;
    PLR_OUT(i)=PLR;
end
figure
plot(temp_SP,COP_OUT)

% surf(temp_entering_chw,temp_entering_cw,COP_OUT);
% title('COP-Tchw,e-Tcw,e');
% xlabel('Tchw,e');
% ylabel('Tcw,e');
% zlabel('COP');