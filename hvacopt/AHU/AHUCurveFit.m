function [ output_args ] = AHUCurveFit( InletAir,InletWaterCC,InletWaterHC,...
    AirSetPointTemp,CoilUA,Schedule,FanDiameter,ParameterAHU,ParameterVFDFan,SizingParameter)
%AHUCURVEFIT this function models AHU performance based on experiment data.





if (Ta_in>=Ta_out) % Cooling mode
    x1 = Tw_in;
    x2 = Ta_in;
    x3 = Tawb_in;
    x4 = Ta_out;
    x5 = Vr;  % Vr=air flow / design air flow
    
    shrc1 = 0.8419;
    shrc2 = 0.0222;
    shrc3 = 0.0368;
    shrc4 = -0.0587;
    shrc5 = -0.0156;
    shrc6 = 0.1259;
    shrc7 = -0.0012;
    shrc8 = 5.5386e-4;
    shrc9 = -5.7779e-4;
    shrc10= -8.6552e-5;
    shrc11= 0.0015;
    shrc12= 2.1135e-4;
    shrc13= -4.3646e-4;
    shrc14= 5.0896e-4;
    shrc15= -0.0058;
    shrc16= 0.0048;
    shrc17= 7.9511e-4;
    shrc18= -3.8760e-4;
    shrc19= -0.0012;
    shrc20= 9.4578e-5;
    shrc21= -0.0173;
    
    SHR_coil = shrc1 + shrc2*x1 + shrc3*x2 + shrc4*x3 + ...
        shrc5*x4 + shrc6*x5 + shrc7*x1*x2 + shrc8*x1*x3 +...
        shrc9*x1*x4 + shrc10*x1*x5 + shrc11*x2*x3 + ...
        shrc12*x2*x4 + shrc13*x2*x5 + shrc14*x3*x4 + ...
        shrc15*x3*x5 + shrc16*x4*x5 +...
        shrc17*x1*x1 + shrc18*x2*x2 + shrc19*x3*x3 + ...
        shrc20*x4*x4 + shrc21*x5*x5;
    
    if (SHR_coil>1)
        SHR_coil=1;
    end
    Qs_load=VFR_real*RHOWA*CPA*max(Ta_in-Ta_out,0.)/3600;
    Qsen_real=Qs_load;
    Qlat_real = Qsen_real*(1-SHR_coil)/SHR_coil;%Qs_load = Qsen_real
    
else  % heating mode
    Qlat_real=0;
    Qs_load=VFR_real*RHOWA*CPA*max(Ta_out-Ta_in,0.)/3600;
    Qsen_real=Qs_load;
    
end

end

