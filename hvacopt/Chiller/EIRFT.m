
EIRFTCoeff=[0.933884 -0.582120*10^(-1) 0.450036*10^(-2) 0.243000*10^(-2) 0.486000*10^(-3) -0.121500*10^(-2)];

A_EIRFT=EIRFTCoeff(1);
B_EIRFT=EIRFTCoeff(2);
C_EIRFT=EIRFTCoeff(3);
D_EIRFT=EIRFTCoeff(4);
E_EIRFT=EIRFTCoeff(5);
F_EIRFT=EIRFTCoeff(6);



 CapFTCoeff=[0.257896 0.389016*10^(-1) -0.217080*10^(-3) 0.468684*10^(-1) -0.94284*10^(-3) -0.343440*10^(-3)];
A_CapFT=CapFTCoeff(1);
B_CapFT=CapFTCoeff(2);
C_CapFT=CapFTCoeff(3);
D_CapFT=CapFTCoeff(4);
E_CapFT=CapFTCoeff(5);
F_CapFT=CapFTCoeff(6);

temp_leaving_chw=5.5:0.5:9;
temp_entering_cw=28;

for k=1:length(temp_leaving_chw)
EIRFT1(k)=A_EIRFT+B_EIRFT*temp_leaving_chw(k)+C_EIRFT*temp_leaving_chw(k).^2+...
            D_EIRFT*temp_entering_cw+E_EIRFT*temp_entering_cw.^2+...
            F_EIRFT*temp_leaving_chw(k).*temp_entering_cw;
        
        
CapFT1(k)=A_CapFT+B_CapFT*temp_leaving_chw(k)+C_CapFT*temp_leaving_chw(k).^2+...
            D_CapFT*temp_entering_cw+E_CapFT*temp_entering_cw.^2+...
            F_CapFT*temp_leaving_chw(k).*temp_entering_cw;
end
figure
plot (temp_leaving_chw,EIRFT1,temp_leaving_chw,CapFT1,temp_leaving_chw,1./CapFT1);

%plot(temp_leaving_chw,CapFT1);


