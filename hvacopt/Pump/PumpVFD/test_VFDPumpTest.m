
clear;

PumpVolFlow=0.12*[0.3:0.1:1]';

row=size(PumpVolFlow,1);

InletPump.temp=25*ones(row,1);

 % PumpHeadPa=[23370.7616253829;55379.0903341571;21544.2424379100;20592.9089563571;20071.8390973659;47602.1739417724;46544.9219154518;117442.660638295];
PumpSpd=[0.1:0.1:1.2]'*1450;
row2=size(PumpSpd,1);

Schedule=ones(row,1);

NumON=1*ones(row,1);

TempRise=1;

for i=1:row2
    
Spd=PumpSpd(i,1)*ones(row,1);
    
%[OutletPump, Power,HeadPa,PumpHeadMRatedSpd,Eff,PumpEffRatedSpd,MotorEff ] = PumpVFD( InletPump,Spd, PumpVolFlow,Schedule,TempRise);
[OutletPump, Power,HeadPa,Eff] = DesignPumpVFD...
    ( InletPump,Spd, PumpVolFlow,NumON,Schedule,TempRise );

PumpPower(:,i)=Power;
PumpHeadPa(:,i)=HeadPa;


TotalEff(:,i)=Eff;

end
%% PLOT THE RESULTS
figure1 = figure('Name','VFD Pump');

% 创建 axes
axes1 = axes('Parent',figure1);
box(axes1,'on');
hold(axes1,'all');

Pump=[PumpPower,PumpHeadPa,TotalEff];

% 使用 bar 的矩阵输入创建多行
AX=plotyy(PumpVolFlow./0.07,TotalEff,PumpVolFlow./0.07,PumpHeadPa);

% 创建 xlabel
xlabel('PLR');

% 创建 ylabel
ylabel(AX(1),'efficiency');
ylabel(AX(2),'head (Pa)');

% 创建 title
title('VFD Pump');

% 创建 legend
legend(axes1,'show');

%% figure1 = figure('Name','VFD Pump');
figure2 = figure('Name','VFD Pump');
% 创建 axes
axes1 = axes('Parent',figure2);
box(axes1,'on');
hold(axes1,'all');


% 使用 bar 的矩阵输入创建多行
plot(PumpVolFlow./0.07,PumpPower);

% 创建 xlabel
xlabel('PLR');

% 创建 ylabel
ylabel('Power (W)');

% 创建 title
title('VFD Pump');

% 创建 legend
legend(axes1,'show');

