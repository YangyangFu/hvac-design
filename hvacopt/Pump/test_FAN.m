clear;
air_in.temp=25;
air_in.RH=0.5;

air_in.pressure=101325;

air_in.flowrate=[0:1:8]';

N=[3:0.5:5]';

[R,C]=size(N);

for i=1:R
    [air_out,head,power_total,heat2fluid,eff_dimen]=DetailedVSFan_Head(air_in,N(i,1),0.6858);
    H(:,i)=head;
    P(:,i)=power_total;
    E(:,i)=eff_dimen;
end
flowrate_in=air_in.flowrate;

figure;
hold on;
grid on;
surf(N,flowrate_in,H);
title('H--N and flowrate');
xlabel('N (1/s)');
ylabel('flowrate_in (m3/s)');
zlabel('H (Pa)');


figure;
hold on;
grid on;
surf(N,flowrate_in,P);
title('P--N and flowrate');
xlabel('N (1/s)');
ylabel('flowrate_in (m3/s)');
zlabel('P (W)');