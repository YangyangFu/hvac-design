function [temperature_outlet]=HeatTransfer_Heat(flowrate_inlet,temperature_inlet,heat_flow,option,parameter_heattransfer)

%% application
% this model calculate temperature at outlet from given heat flow and
% temperature at inlet

%% description
%===================input==================
% flowrate_inlet: volume flow at inlet;[m3/s]
% heat_flow: heatflow in the heat transfer process;[W]
% temperature_inlet: a struct including :
%                     temperature_inlet.temperature: a column vector representing inlet temperature;[¡æ] 
%                     temperature_inlet.RH:          a column vector representing inlet relative humidity.if the medium is water, this column is blank.                            
% option:        0------represents that the medium is water;
%                else---represents that the medium is air;
% parameter_heattransfer: a 1-by-2 struct;
%                         parameter_heattransfer.cp:water specific heat in the first column and air heat specific in the second column;[J/kg.K]
%                         parameter-heattransfer.density:water density and air density respectively;[kg/m3]

%==================output==================
% temperature_outlet: temperature at the outlet;[¡æ]

%% model equation
% 
if nargin<4
     option=0;
end
if nargin<5
    parameter_heattransfer.cp=[4200 1012];
    parameter_heattransfer.density=[1000 1.29];
end

% initializtion
if option==0                          % flow medium is water;
cp=parameter_heattransfer.cp(1);
density=parameter_heattransfer.density(1);
temperature_outlet=temperature_inlet.temperature+heat_flow./(flowrate_inlet*density*cp);


else                       % flow medium is air;
    cp=parameter_heattransfer.cp(:,2);
    density=parameter_heattransfer.density(:,2);
    temperature_in=temperature_inlet.temperature;
    RH_in=temperature_inlet.RH;
    [h_in,W_in]=PsychTdbRH(temperature_in,RH_in);
    if flowrate_inlet==0
        h_out=h_in;
    else
    h_out=h_in+heat_flow./(density*flowrate_inlet);
    end
    W_out=W_in;
    temp_outlet=PsychTdbFuHW(h_out,W_out);
    RH_out=PsychRHFuTdbW(temp_outlet,W_out);
    
    temperature_outlet.temp=temp_outlet;
    temperature_outlet.RH=RH_out;
    
end


