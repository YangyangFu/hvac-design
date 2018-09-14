clear;
clc;
% Plot three Ts againist ENergy
EN1=[];
EN2=[];
 EN3=[];
EN1detailed={};
EN2detailed={};
 EN3detailed={};
E1=[];
E2=[];
 E3=[];
E1detailed={};
E2detailed={};
 E3detailed={};

x=[5.5,28,15,2,1,1,5];


for a=5.5:0.5:8
    x(1)=a;
    [ElectricityAll,GBCFPower,GBCFPowerPump,EcoCost,CapCostAll]=HVACDesignOptimization(x);
    
    EN1(end+1)=ElectricityAll;
    EN1detailed{end+1}=GBCFPower;
    E1(end+1)=CapCostAll;
    E1detailed{end+1}=EcoCost;
    
    
end


figure
a=5.5:0.5:8;
plot(a,EN1);
title ('Energy Cost');

saveas(gcf,'Energy Cost Versus Chilled Water Temperature','jpg');

figure;
plot (a, E1);
title('Capital Cost')

saveas(gcf,'Capital Cost Versus Chilled Water Temperature','jpg');
% Figure the primary pump energy and capitial cost
figure
EnPriPump1=[];
if x(5)==2
    for ii=1:length(EN1detailed)
        EnPriPump1(ii)=sum(sum(EN1detailed{1,ii}{1,1}(:,3)));
        EPrimPumpCost1=E1detailed{1,ii}{1,1}.ChilledWater.PrimaryPump.Small.CapCost+...
            E1detailed{1,ii}{1,1}.ChilledWater.PrimaryPump.Middle.CapCost+...
            E1detailed{1,ii}{1,1}.ChilledWater.PrimaryPump.Large.CapCost;
        EPrimPumpCost2=E1detailed{1,ii}{1,2}.ChilledWater.PrimaryPump.Small.CapCost+...
            E1detailed{1,ii}{1,2}.ChilledWater.PrimaryPump.Middle.CapCost+...
            E1detailed{1,ii}{1,2}.ChilledWater.PrimaryPump.Large.CapCost;
        EPrimPump1(ii)=EPrimPumpCost1+EPrimPumpCost2;
    end
else
    for ii=1:length(EN1detailed)
        EnPriPump1(ii)=sum(sum(EN1detailed{1,ii}(:,3)));
        EPrimPumpCost1=E1detailed{1,ii}.ChilledWater.PrimaryPump.Small.CapCost+...
            E1detailed{1,ii}.ChilledWater.PrimaryPump.Middle.CapCost+...
            E1detailed{1,ii}.ChilledWater.PrimaryPump.Large.CapCost;
        EPrimPump1(ii)=EPrimPumpCost1;
        
    end
end
plot(a,EnPriPump1);
title('Primary Pump Energy Consumption');
saveas(gcf,'Primary Pump Energy Consumption Versus Chilled Water Temperature','jpg');

figure
plot(a,EPrimPump1)
title('Primary Pump Captial Cost');
saveas(gcf,'Primary Pump Captial Cost Versus Chilled Water Temperature','jpg');

% plot secondary pumps
figure
EnSecPump1=[];
ESecondPumpCost1=[];
ESecondPumpCost2=[];
if x(5)==2
    for ii=1:length(EN1detailed)
        EnSecPump1(ii)=sum(sum(EN1detailed{1,ii}{1,1}(:,4)));
        [row,col]=size(E1detailed{1,ii}{1,1}.ChilledWater.SecondaryPump);
        
        for i=1:row
            for j=1:col
                ESecondPumpCost1(i,j)=E1detailed{1,ii}{1,1}.ChilledWater.SecondaryPump{i,j}.CapCost;
            end
        end
        
        ESecondPump11=sum(sum(ESecondPumpCost1));
        
        [row,col]=size(E1detailed{1,ii}{1,2}.ChilledWater.SecondaryPump);
        for i=1:row
            for j=1:col
                ESecondPumpCost2(i,j)=E1detailed{1,ii}{1,2}.ChilledWater.SecondaryPump{i,j}.CapCost;
            end
        end
        ESecondPump12=sum(sum(ESecondPumpCost2));
        
        ESecondPump1(ii)=ESecondPump11+ESecondPump12;
    end
else
    for ii=1:length(EN1detailed)
        EnSecPump1(ii)=sum(sum(EN1detailed{1,ii}(:,4)));
        [row,col]=size(E1detailed{1,ii}.ChilledWater.SecondaryPump);
        
        for i=1:row
            for j=1:col
                ESecondPumpCost1(i,j)=E1detailed{1,ii}.ChilledWater.SecondaryPump{i,j}.CapCost;
            end
        end
        
        ESecondPump1(ii)=sum(sum(ESecondPumpCost1));
    end
end
plot(a,EnSecPump1);
title('Second Pump Energy Consumption');

saveas(gcf,'Second Pump Energy Consumption Versus Chilled Water Temperature','jpg');

figure
plot(a,ESecondPump1);
title('Secondary Pump Capitial Cost');
saveas(gcf,'Secondary Pump Captial Cost Versus Chilled Water Temperature','jpg');

% plot condense pump
figure
EncondPump1=[];
if x(5)==2
    for ii=1:length(EN1detailed)
        EncondPump1(ii)=sum(sum(EN1detailed{1,ii}{1,1}(:,5)));
        EConPumpCost1=E1detailed{1,ii}{1,1}.CondenseWater.CondensePump.Small.CapCost+...
            E1detailed{1,ii}{1,1}.CondenseWater.CondensePump.Middle.CapCost+...
            E1detailed{1,ii}{1,1}.CondenseWater.CondensePump.Large.CapCost;
        EConPumpCost2=E1detailed{1,ii}{1,2}.CondenseWater.CondensePump.Small.CapCost+...
            E1detailed{1,ii}{1,2}.CondenseWater.CondensePump.Middle.CapCost+...
            E1detailed{1,ii}{1,2}.CondenseWater.CondensePump.Large.CapCost;
        EConPump1(ii)=EConPumpCost1+EConPumpCost2;
        
    end
else
    for ii=1:length(EN1detailed)
        EncondPump1(ii)=sum(sum(EN1detailed{1,ii}(:,5)));
        EConPumpCost1=E1detailed{1,ii}.CondenseWater.CondensePump.Small.CapCost+...
            E1detailed{1,ii}.CondenseWater.CondensePump.Middle.CapCost+...
            E1detailed{1,ii}.CondenseWater.CondensePump.Large.CapCost;
        EConPump1(ii)=EConPumpCost1;
    end
end


plot(a,EncondPump1);
title('condense Pump Energy Consumption');
saveas(gcf,'Condense Pump Energy Consumption Versus Chilled Water Temperature','jpg');

figure
plot (a,EConPump1);
title('Condense Pump Capitial Cost')
saveas(gcf,'Condense Pump Capitial Cost Versus Chilled Water Temperature','jpg');
% plot AHU
figure
EnAHU1=[];

if x(5)==2
    for ii=1:length(EN1detailed)
        EnAHU1(ii)=sum(sum(EN1detailed{1,ii}{1,1}(:,1)));
        
        AHUcell1=E1detailed{1,ii}{1,1}.ChilledWater.AHU;
        AHUcell2=E1detailed{1,ii}{1,2}.ChilledWater.AHU;
        
        AHU1=0;
        AHU2=0;
        
        for i=1:length(AHUcell1{1,1})
            AHU1=AHUcell1{1,1}{i,1}.CapCost+AHU1;
        end
        for i=1:length(AHUcell2{1,1})
            AHU2=AHUcell2{1,1}{i,1}.CapCost+AHU2;
        end
        
        EAHU1(ii)=AHU1+AHU2;
    end
else
    for ii=1:length(EN1detailed)
        EnAHU1(ii)=sum(sum(EN1detailed{1,ii}(:,1)));
        
        AHUcell1=E1detailed{1,ii}.ChilledWater.AHU;
        
        AHU1=0;
        
        for i=1:length(AHUcell1{1,1})
            AHU1=AHUcell1{1,1}{i,1}.CapCost+AHU1;
        end
        EAHU1(ii)=AHU1;
    end
end

plot(a,EnAHU1);
title('AHu Energy Consumption');
saveas(gcf,'AHU Energy Consumption Versus Chilled Water Temperature','jpg');

figure
plot(a,EAHU1);
title('AHU Capitial Cost')
saveas(gcf,'AHU Capitial Cost Versus Chilled Water Temperature','jpg');

figure()
EnChiller1=[];
if x(5)==2
    for ii=1:length(EN1detailed)
        EnChiller1(ii)=sum(sum(EN1detailed{1,ii}{1,1}(:,2)));
        
        EChillerCost1=E1detailed{1,ii}{1,1}.ChilledWater.Chiller.Small.CapCost+...
            E1detailed{1,ii}{1,1}.ChilledWater.Chiller.Middle.CapCost+...
            E1detailed{1,ii}{1,1}.ChilledWater.Chiller.Large.CapCost;
        EChillerCost2=E1detailed{1,ii}{1,2}.ChilledWater.Chiller.Small.CapCost+...
            E1detailed{1,ii}{1,2}.ChilledWater.Chiller.Middle.CapCost+...
            E1detailed{1,ii}{1,2}.ChilledWater.Chiller.Large.CapCost;
        EChiller1(ii)=EChillerCost1+EChillerCost2;
        
    end
else
    for ii=1:length(EN1detailed)
        EnChiller1(ii)=sum(sum(EN1detailed{1,ii}(:,2)));
        
        EChillerCost1=E1detailed{1,ii}.ChilledWater.Chiller.Small.CapCost+...
            E1detailed{1,ii}.ChilledWater.Chiller.Middle.CapCost+...
            E1detailed{1,ii}.ChilledWater.Chiller.Large.CapCost;
        
        EChiller1(ii)=EChillerCost1;
    end
end

plot(a,EnChiller1);
title('Chiller Energy Cost');
saveas(gcf,'Chiller Energy Consumption Versus Chilled Water Temperature','jpg');


figure
plot (a, EChiller1);
title ('Chiller Capitial Cost');
saveas(gcf,'Chiller Capitial Cost Versus Chilled Water Temperature','jpg');


figure()
EnCT1=[];
if x(5)==2
    for ii=1:length(EN1detailed)
        EnCT1(ii)=sum(sum(EN1detailed{1,ii}{1,1}(:,6)));
        
        ECTCost1=E1detailed{1,ii}{1,1}.CondenseWater.CT.Small.CapCost+...
            E1detailed{1,ii}{1,1}.CondenseWater.CT.Middle.CapCost+...
            E1detailed{1,ii}{1,1}.CondenseWater.CT.Large.CapCost;
        ECTCost2=E1detailed{1,ii}{1,2}.CondenseWater.CT.Small.CapCost+...
            E1detailed{1,ii}{1,2}.CondenseWater.CT.Middle.CapCost+...
            E1detailed{1,ii}{1,2}.CondenseWater.CT.Large.CapCost;
        ECT1(ii)=ECTCost1+ECTCost2;
        
    end
else
    for ii=1:length(EN1detailed)
        EnCT1(ii)=sum(sum(EN1detailed{1,ii}(:,6)));
        
        ECTCost1=E1detailed{1,ii}.CondenseWater.CT.Small.CapCost+...
            E1detailed{1,ii}.CondenseWater.CT.Middle.CapCost+...
            E1detailed{1,ii}.CondenseWater.CT.Large.CapCost;
        
        ECT1(ii)=ECTCost1;
    end
end

plot(a,EnCT1);
title('CoolingTower Energy Cost');
saveas(gcf,'CoolingTower Energy Consumption Versus Chilled Water Temperature','jpg');


figure
plot (a, ECT1);
title ('CoolingTower Capitial Cost');
saveas(gcf,'CoolingTower Capitial Cost Versus Chilled Water Temperature','jpg');

%% cooling water temperature
x=[5.5,28,15,2,1,1,5];

for b=28:34
    x(2)=b;
    [ElectricityAll,GBCFPower,GBCFPowerPump,EcoCost,CapCostAll]=HVACDesignOptimization(x);
    
    EN2(end+1)=ElectricityAll;
    EN2detailed{end+1}=GBCFPower;
    E2(end+1)=CapCostAll;
    E2detailed{end+1}=EcoCost;
    
end
figure
b=28:34;
plot(b,EN2);
title ('Energy Cost');
saveas(gcf,'Energy Cost Versus Condense Water Temperature','jpg');

figure;
plot (b, E2);
title('Capital Cost');
saveas(gcf,'Capitial Cost Versus Condensed Water Temperature','jpg');

% Figure the primary pump energy and capitial cost
figure
EnPriPump2=[];
if x(5)==2
    for ii=1:length(EN2detailed)
        EnPriPump2(ii)=sum(sum(EN2detailed{1,ii}{1,1}(:,3)));
        EPrimPumpCost1=E2detailed{1,ii}{1,1}.ChilledWater.PrimaryPump.Small.CapCost+...
            E2detailed{1,ii}{1,1}.ChilledWater.PrimaryPump.Middle.CapCost+...
            E2detailed{1,ii}{1,1}.ChilledWater.PrimaryPump.Large.CapCost;
        EPrimPumpCost2=E2detailed{1,ii}{1,2}.ChilledWater.PrimaryPump.Small.CapCost+...
            E2detailed{1,ii}{1,2}.ChilledWater.PrimaryPump.Middle.CapCost+...
            E2detailed{1,ii}{1,2}.ChilledWater.PrimaryPump.Large.CapCost;
        EPrimPump2(ii)=EPrimPumpCost1+EPrimPumpCost2;
    end
else
    for ii=1:length(EN2detailed)
        EnPriPump2(ii)=sum(sum(EN2detailed{1,ii}(:,3)));
        EPrimPumpCost1=E2detailed{1,ii}.ChilledWater.PrimaryPump.Small.CapCost+...
            E2detailed{1,ii}.ChilledWater.PrimaryPump.Middle.CapCost+...
            E2detailed{1,ii}.ChilledWater.PrimaryPump.Large.CapCost;
        EPrimPump2(ii)=EPrimPumpCost1;
        
    end
end
plot(b,EnPriPump2);
title('Primary Pump Energy Consumption');
saveas(gcf,'Primary Pump Energy Consumption Versus Condensed Water Temperature','jpg');




figure
plot(b,EPrimPump2)
title('Primary Pump Captial Cost');
saveas(gcf,'Primary Pump Captial Cost Versus Condensed Water Temperature','jpg');

% plot secondary pumps
figure
EnSecPump2=[];
ESecondPumpCost1=[];
ESecondPumpCost2=[];
if x(5)==2
    for ii=1:length(EN2detailed)
        EnSecPump2(ii)=sum(sum(EN2detailed{1,ii}{1,1}(:,4)));
        [row,col]=size(E2detailed{1,ii}{1,1}.ChilledWater.SecondaryPump);
        
        for i=1:row
            for j=1:col
                ESecondPumpCost1(i,j)=E2detailed{1,ii}{1,1}.ChilledWater.SecondaryPump{i,j}.CapCost;
            end
        end
        
        ESecondPump12=sum(sum(ESecondPumpCost1));
        
        [row,col]=size(E2detailed{1,ii}{1,2}.ChilledWater.SecondaryPump);
        for i=1:row
            for j=1:col
                ESecondPumpCost2(i,j)=E2detailed{1,ii}{1,2}.ChilledWater.SecondaryPump{i,j}.CapCost;
            end
        end
        ESecondPump22=sum(sum(ESecondPumpCost2));
        
        ESecondPump2(ii)=ESecondPump12+ESecondPump22;
    end
else
    for ii=1:length(EN2detailed)
        EnSecPump2(ii)=sum(sum(EN2detailed{1,ii}(:,4)));
        [row,col]=size(E2detailed{1,ii}.ChilledWater.SecondaryPump);
        
        for i=1:row
            for j=1:col
                ESecondPumpCost12(i,j)=E2detailed{1,ii}.ChilledWater.SecondaryPump{i,j}.CapCost;
            end
        end
        
        ESecondPump2(ii)=sum(sum(ESecondPumpCost12));
    end
end
plot(b,EnSecPump2);
title('Second Pump Energy Consumption');
saveas(gcf,'Second Pump Energy Consumption Versus Condensed Water Temperature','jpg');

figure
plot(b,ESecondPump2);
title('Secondary Pump Capitial Cost');
saveas(gcf,'Second Pump Captial Cost Versus Condensed Water Temperature','jpg');

% plot condense pump
figure
EncondPump2=[];
if x(5)==2
    for ii=1:length(EN2detailed)
        EncondPump2(ii)=sum(sum(EN2detailed{1,ii}{1,1}(:,5)));
        EConPumpCost1=E2detailed{1,ii}{1,1}.CondenseWater.CondensePump.Small.CapCost+...
            E2detailed{1,ii}{1,1}.CondenseWater.CondensePump.Middle.CapCost+...
            E2detailed{1,ii}{1,1}.CondenseWater.CondensePump.Large.CapCost;
        EConPumpCost2=E2detailed{1,ii}{1,2}.CondenseWater.CondensePump.Small.CapCost+...
            E2detailed{1,ii}{1,2}.CondenseWater.CondensePump.Middle.CapCost+...
            E2detailed{1,ii}{1,2}.CondenseWater.CondensePump.Large.CapCost;
        EConPump2(ii)=EConPumpCost1+EConPumpCost2;
        
    end
else
    for ii=1:length(EN2detailed)
        EncondPump2(ii)=sum(sum(EN2detailed{1,ii}(:,5)));
        EConPumpCost1=E2detailed{1,ii}.CondenseWater.CondensePump.Small.CapCost+...
            E2detailed{1,ii}.CondenseWater.CondensePump.Middle.CapCost+...
            E2detailed{1,ii}.CondenseWater.CondensePump.Large.CapCost;
        EConPump2(ii)=EConPumpCost1;
    end
end


plot(b,EncondPump2);
title('condense Pump Energy Consumption');
saveas(gcf,'Condense Pump Energy Consumption Versus Condensed Water Temperature','jpg');

figure
plot (b,EConPump2);
title('Condense Pump Capitial Cost')
saveas(gcf,'Condense Pump Captial Cost Versus Condensed Water Temperature','jpg');

% plot AHU
figure
EnAHU2=[];

if x(5)==2
    for ii=1:length(EN2detailed)
        EnAHU2(ii)=sum(sum(EN2detailed{1,ii}{1,1}(:,1)));
        
        AHUcell1=E2detailed{1,ii}{1,1}.ChilledWater.AHU;
        AHUcell2=E2detailed{1,ii}{1,2}.ChilledWater.AHU;
        AHU1=0;
        AHU2=0;
        for i=1:length(AHUcell1{1,1})
            AHU1=AHUcell1{1,1}{i,1}.CapCost+AHU1;
        end
        for i=1:length(AHUcell2{1,1})
            AHU2=AHUcell2{1,1}{i,1}.CapCost+AHU2;
        end
        
        EAHU2(ii)=AHU1+AHU2;
    end
else
    for ii=1:length(EN2detailed)
        EnAHU2(ii)=sum(sum(EN2detailed{1,ii}(:,1)));
        
        AHUcell1=E2detailed{1,ii}.ChilledWater.AHU;
        AHU1=0;
        for i=1:length(AHUcell1{1,1})
            AHU1=AHUcell1{1,1}{i,1}.CapCost+AHU1;
        end
        EAHU2(ii)=AHU1;
    end
end

plot(b,EnAHU2);
title('AHu Energy Consumption');
saveas(gcf,'AHU Energy Consumption Versus Condensed Water Temperature','jpg');

figure
plot(b,EAHU2);
title('AHU Capitial Cost')
saveas(gcf,'AHU Captial Cost Versus Condensed Water Temperature','jpg');

figure()
EnChiller2=[];
if x(5)==2
    for ii=1:length(EN2detailed)
        EnChiller2(ii)=sum(sum(EN2detailed{1,ii}{1,1}(:,2)));
        
        EChillerCost1=E2detailed{1,ii}{1,1}.ChilledWater.Chiller.Small.CapCost+...
            E2detailed{1,ii}{1,1}.ChilledWater.Chiller.Middle.CapCost+...
            E2detailed{1,ii}{1,1}.ChilledWater.Chiller.Large.CapCost;
        EChillerCost2=E2detailed{1,ii}{1,2}.ChilledWater.Chiller.Small.CapCost+...
            E2detailed{1,ii}{1,2}.ChilledWater.Chiller.Middle.CapCost+...
            E2detailed{1,ii}{1,2}.ChilledWater.Chiller.Large.CapCost;
        EChiller2(ii)=EChillerCost1+EChillerCost2;
        
    end
else
    for ii=1:length(EN2detailed)
        EnChiller2(ii)=sum(sum(EN2detailed{1,ii}(:,2)));
        
        EChillerCost1=E2detailed{1,ii}.ChilledWater.Chiller.Small.CapCost+...
            E2detailed{1,ii}.ChilledWater.Chiller.Middle.CapCost+...
            E2detailed{1,ii}.ChilledWater.Chiller.Large.CapCost;
        
        EChiller2(ii)=EChillerCost1;
    end
end

plot(b,EnChiller2);
title('Chiller Energy Cost');
saveas(gcf,'Chiller Energy Consumption Versus Condensed Water Temperature','jpg');


figure
plot (b, EChiller2);
title ('Chiller Capitial Cost')
saveas(gcf,'Chiller Captial Cost Versus Condensed Water Temperature','jpg');


figure()
EnCT2=[];
if x(5)==2
    for ii=1:length(EN2detailed)
        EnCT2(ii)=sum(sum(EN2detailed{1,ii}{1,1}(:,6)));
        
        ECTCost1=E2detailed{1,ii}{1,1}.CondenseWater.CT.Small.CapCost+...
            E2detailed{1,ii}{1,1}.CondenseWater.CT.Middle.CapCost+...
            E2detailed{1,ii}{1,1}.CondenseWater.CT.Large.CapCost;
        ECTCost2=E2detailed{1,ii}{1,2}.CondenseWater.CT.Small.CapCost+...
            E2detailed{1,ii}{1,2}.CondenseWater.CT.Middle.CapCost+...
            E2detailed{1,ii}{1,2}.CondenseWater.CT.Large.CapCost;
        ECT2(ii)=ECTCost1+ECTCost2;
        
    end
else
    for ii=1:length(EN2detailed)
        EnCT2(ii)=sum(sum(EN2detailed{1,ii}(:,6)));
        
        ECTCost1=E2detailed{1,ii}.CondenseWater.CT.Small.CapCost+...
            E2detailed{1,ii}.CondenseWater.CT.Middle.CapCost+...
            E2detailed{1,ii}.CondenseWater.CT.Large.CapCost;
        
        ECT2(ii)=ECTCost1;
    end
end

plot(b,EnCT2);
title('CoolingTower Energy Cost');
saveas(gcf,'CoolingTower Energy Consumption  Versus Condensed Water Temperature','jpg');


figure
plot (b, ECT2);
title ('CoolingTower Capitial Cost');
saveas(gcf,'CoolingTower Capitial Cost  Versus Condensed Water Temperature','jpg');


%% Air ..
x=[5.5,28,15,2,1,1,5];

for c=13:16
    x(3)=c;
    [ElectricityAll,GBCFPower,GBCFPowerPump,EcoCost,CapCostAll]=HVACDesignOptimization(x);
    
    EN3(end+1)=ElectricityAll;
    EN3detailed{end+1}=GBCFPower;
    E3(end+1)=CapCostAll;
    E3detailed{end+1}=EcoCost;
    
end
figure
c=13:16;
plot(c,EN3);
title ('Energy Cost');
saveas(gcf,'Energy Cost Versus AHU SetPoint Temperature','jpg');

figure;
plot (c, E3);
title('Capital Cost')
saveas(gcf,'Capitial Cost Versus AHU SetPoint Temperature','jpg');
% Figure the primary pump energy and capitial cost
figure
EnPriPump3=[];
if x(5)==2
    for ii=1:length(EN3detailed)
        EnPriPump3(ii)=sum(sum(EN3detailed{1,ii}{1,1}(:,3)));
        EPrimPumpCost1=E3detailed{1,ii}{1,1}.ChilledWater.PrimaryPump.Small.CapCost+...
            E3detailed{1,ii}{1,1}.ChilledWater.PrimaryPump.Middle.CapCost+...
            E3detailed{1,ii}{1,1}.ChilledWater.PrimaryPump.Large.CapCost;
        EPrimPumpCost2=E3detailed{1,ii}{1,2}.ChilledWater.PrimaryPump.Small.CapCost+...
            E3detailed{1,ii}{1,2}.ChilledWater.PrimaryPump.Middle.CapCost+...
            E3detailed{1,ii}{1,2}.ChilledWater.PrimaryPump.Large.CapCost;
        EPrimPump3(ii)=EPrimPumpCost1+EPrimPumpCost2;
    end
else
    for ii=1:length(EN3detailed)
        EnPriPump3(ii)=sum(sum(EN3detailed{1,ii}(:,3)));
        EPrimPumpCost1=E3detailed{1,ii}.ChilledWater.PrimaryPump.Small.CapCost+...
            E3detailed{1,ii}.ChilledWater.PrimaryPump.Middle.CapCost+...
            E3detailed{1,ii}.ChilledWater.PrimaryPump.Large.CapCost;
        EPrimPump3(ii)=EPrimPumpCost1;
        
    end
end
plot(c,EnPriPump3);
title('Primary Pump Energy Consumption');
saveas(gcf,'Primary Pump Energy Consumption Versus AHU SetPoint Temperature','jpg');

figure
plot(c,EPrimPump3)
title('Primary Pump Captial Cost');
saveas(gcf,'Primary Pump Captial Cost Versus AHU SetPoint Temperature','jpg');

% plot secondary pumps
figure
EnSecPump3=[];
ESecondPumpCost1=[];
ESecondPumpCost2=[];
if x(5)==2
    for ii=1:length(EN3detailed)
        EnSecPump3(ii)=sum(sum(EN3detailed{1,ii}{1,1}(:,4)));
        [row,col]=size(E3detailed{1,ii}{1,1}.ChilledWater.SecondaryPump);
        
        for i=1:row
            for j=1:col
                ESecondPumpCost1(i,j)=E3detailed{1,ii}{1,1}.ChilledWater.SecondaryPump{i,j}.CapCost;
            end
        end
        
        ESecondPump1=sum(sum(ESecondPumpCost1));
        
        [row,col]=size(E3detailed{1,ii}{1,2}.ChilledWater.SecondaryPump);
        for i=1:row
            for j=1:col
                ESecondPumpCost2(i,j)=E3detailed{1,ii}{1,2}.ChilledWater.SecondaryPump{i,j}.CapCost;
            end
        end
        ESecondPump12=sum(sum(ESecondPumpCost2));
        
        ESecondPump3(ii)=ESecondPump1+ESecondPump12;
    end
else
    for ii=1:length(EN3detailed)
        EnSecPump3(ii)=sum(sum(EN3detailed{1,ii}(:,4)));
        [row,col]=size(E3detailed{1,ii}.ChilledWater.SecondaryPump);
        
        for i=1:row
            for j=1:col
                ESecondPumpCost1(i,j)=E3detailed{1,ii}.ChilledWater.SecondaryPump{i,j}.CapCost;
            end
        end
        
        ESecondPump3(ii)=sum(sum(ESecondPumpCost1));
    end
end
plot(c,EnSecPump3);
title('Second Pump Energy Consumption');
saveas(gcf,'Secondary Pump Energy Consumption Versus AHU SetPoint Temperature','jpg');


figure
plot(c,ESecondPump3);
title('Secondary Pump Capitial Cost');
saveas(gcf,'Secondary Pump Captial Cost Versus AHU SetPoint Temperature','jpg');

% plot condense pump
figure
EncondPump3=[];
if x(5)==2
    for ii=1:length(EN3detailed)
        EncondPump3(ii)=sum(sum(EN3detailed{1,ii}{1,1}(:,5)));
        EConPumpCost1=E3detailed{1,ii}{1,1}.CondenseWater.CondensePump.Small.CapCost+...
            E3detailed{1,ii}{1,1}.CondenseWater.CondensePump.Middle.CapCost+...
            E3detailed{1,ii}{1,1}.CondenseWater.CondensePump.Large.CapCost;
        EConPumpCost2=E3detailed{1,ii}{1,2}.CondenseWater.CondensePump.Small.CapCost+...
            E3detailed{1,ii}{1,2}.CondenseWater.CondensePump.Middle.CapCost+...
            E3detailed{1,ii}{1,2}.CondenseWater.CondensePump.Large.CapCost;
        EConPump3(ii)=EConPumpCost1+EConPumpCost2;
        
    end
else
    for ii=1:length(EN3detailed)
        EncondPump3(ii)=sum(sum(EN3detailed{1,ii}(:,5)));
        EConPumpCost1=E3detailed{1,ii}.CondenseWater.CondensePump.Small.CapCost+...
            E3detailed{1,ii}.CondenseWater.CondensePump.Middle.CapCost+...
            E3detailed{1,ii}.CondenseWater.CondensePump.Large.CapCost;
        EConPump3(ii)=EConPumpCost1;
    end
end


plot(c,EncondPump3);
title('condense Pump Energy Consumption');
saveas(gcf,'Condense Pump Energy Consumption Versus AHU SetPoint Temperature','jpg');

figure
plot (c,EConPump3);
title('Condense Pump Capitial Cost')
saveas(gcf,'Condense Pump Captial Cost Versus AHU SetPoint Temperature','jpg');

% plot AHU
figure
EnAHU3=[];

if x(5)==2
    for ii=1:length(EN3detailed)
        EnAHU3(ii)=sum(sum(EN3detailed{1,ii}{1,1}(:,1)));
        
        AHUcell1=E3detailed{1,ii}{1,1}.ChilledWater.AHU;
        AHUcell2=E3detailed{1,ii}{1,2}.ChilledWater.AHU;
        
        AHU1=0;
        AHU2=0;
        
        for i=1:length(AHUcell1{1,1})
            AHU1=AHUcell1{1,1}{i,1}.CapCost+AHU1;
        end
        for i=1:length(AHUcell2{1,1})
            AHU2=AHUcell2{1,1}{i,1}.CapCost+AHU2;
        end
        
        EAHU3(ii)=AHU1+AHU2;
    end
else
    for ii=1:length(EN3detailed)
        EnAHU3(ii)=sum(sum(EN3detailed{1,ii}(:,1)));
        
        AHUcell1=E3detailed{1,ii}.ChilledWater.AHU;
        
        AHU1=0;
        
        for i=1:length(AHUcell1{1,1})
            AHU1=AHUcell1{1,1}{i,1}.CapCost+AHU1;
        end
        EAHU3(ii)=AHU1;
    end
end

plot(c,EnAHU3);
title('AHu Energy Consumption');
saveas(gcf,'AHU Energy Consumption Versus AHU SetPoint Temperature','jpg');

figure
plot(c,EAHU3);
title('AHU Capitial Cost')
saveas(gcf,'AHU Captial Cost Versus AHU SetPoint Temperature','jpg');

figure()
EnChiller3=[];
if x(5)==2
    for ii=1:length(EN3detailed)
        EnChiller3(ii)=sum(sum(EN3detailed{1,ii}{1,1}(:,2)));
        
        EChillerCost1=E3detailed{1,ii}{1,1}.ChilledWater.Chiller.Small.CapCost+...
            E3detailed{1,ii}{1,1}.ChilledWater.Chiller.Middle.CapCost+...
            E3detailed{1,ii}{1,1}.ChilledWater.Chiller.Large.CapCost;
        EChillerCost2=E3detailed{1,ii}{1,2}.ChilledWater.Chiller.Small.CapCost+...
            E3detailed{1,ii}{1,2}.ChilledWater.Chiller.Middle.CapCost+...
            E3detailed{1,ii}{1,2}.ChilledWater.Chiller.Large.CapCost;
        EChiller3(ii)=EChillerCost1+EChillerCost2;
        
    end
else
    for ii=1:length(EN3detailed)
        EnChiller3(ii)=sum(sum(EN3detailed{1,ii}(:,2)));
        
        EChillerCost1=E3detailed{1,ii}.ChilledWater.Chiller.Small.CapCost+...
            E3detailed{1,ii}.ChilledWater.Chiller.Middle.CapCost+...
            E3detailed{1,ii}.ChilledWater.Chiller.Large.CapCost;
        
        EChiller3(ii)=EChillerCost1;
    end
end

plot(c,EnChiller3);
title('Chiller Energy Cost');
saveas(gcf,'Chiller Energy Consumption Versus AHU SetPoint Temperature','jpg');

figure
plot (c, EChiller3);
title ('Chiller Capitial Cost')
saveas(gcf,'Chiller Captial Cost Versus AHU SetPoint Temperature','jpg');

figure()
EnCT3=[];
if x(5)==2
    for ii=1:length(EN3detailed)
        EnCT3(ii)=sum(sum(EN3detailed{1,ii}{1,1}(:,6)));
        
        ECTCost1=E3detailed{1,ii}{1,1}.CondenseWater.CT.Small.CapCost+...
            E3detailed{1,ii}{1,1}.CondenseWater.CT.Middle.CapCost+...
            E3detailed{1,ii}{1,1}.CondenseWater.CT.Large.CapCost;
        ECTCost2=E3detailed{1,ii}{1,2}.CondenseWater.CT.Small.CapCost+...
            E3detailed{1,ii}{1,2}.CondenseWater.CT.Middle.CapCost+...
            E3detailed{1,ii}{1,2}.CondenseWater.CT.Large.CapCost;
        ECT3(ii)=ECTCost1+ECTCost2;
        
    end
else
    for ii=1:length(EN3detailed)
        EnCT3(ii)=sum(sum(EN3detailed{1,ii}(:,6)));
        
        ECTCost1=E3detailed{1,ii}.CondenseWater.CT.Small.CapCost+...
            E3detailed{1,ii}.CondenseWater.CT.Middle.CapCost+...
            E3detailed{1,ii}.CondenseWater.CT.Large.CapCost;
        
        ECT3(ii)=ECTCost1;
    end
end

plot(c,EnCT3);
title('CoolingTower Energy Cost');
saveas(gcf,'CoolingTower Energy Consumption  Versus AHU SetPoint Temperature','jpg');


figure
plot (c, ECT3);
title ('CoolingTower Capitial Cost');
saveas(gcf,'CoolingTower Capitial Cost  Versus AHU SetPoint Temperature','jpg');

