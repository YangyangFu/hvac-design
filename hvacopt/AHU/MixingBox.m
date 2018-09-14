function [AirOutletMix]=MixingBox(air_OA,air_RE,frac_OA,flowrate_mix,parameter_mixingbox)
% This Model Describes the mixing box of fresh air and return air before
% AHU model.


if nargin<5
    parameter_mixingbox.density=1.29;
    parameter_mixingbox.barom_pressure=101325;
    parameter_mixingbox.resistance=[5e5 5e5 5e5];
end


% Initialize the INPUT
temp_OA=air_OA.temp;
RH_OA=air_OA.RH;

temp_RE=air_RE.temp;
RH_RE=air_RE.RH;

temp_in.temp1=temp_OA;
temp_in.temp2=temp_RE;

RH_in.RH1=RH_OA;
RH_in.RH2=RH_RE;

flowrate_OA=frac_OA.*flowrate_mix;
flowrate_RE=flowrate_mix-flowrate_OA;
flowrate_in.flowrate1=flowrate_OA;
flowrate_in.flowrate2=flowrate_RE;

% air mixing
[temp_mix,RH_mix]=AirMixer(temp_in,RH_in,flowrate_in,parameter_mixingbox);

% air mixer outlet condition
AirOutletMix.temp=temp_mix;
AirOutletMix.RH=RH_mix;
AirOutletMix.flowrate=flowrate_mix;
AirOutletMix.W=PsychWFuTdbRH(temp_mix,RH_mix);