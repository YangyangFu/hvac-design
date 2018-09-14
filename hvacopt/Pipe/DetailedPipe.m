function [flowrate_out,temp_out,pressure_drop]=DetailedPipe(flowrate_in,temp_in,length_pipe,diameter,parameter_pipe)
%% application
% One important special case for apressure loss is the friction at the wall
% of a pipe under the assumption of quasi steady state flow (i.e., the mass
% flow rate varies only slowly). In this section it is explained how this
% case is handled for pipes with nonuniform roughness. The treatment is
% non-standard in order to get a numerically well-posed description.
% For pipes with circular cross section the pressure drop is computed as:
%
%   dp = ¦Ë(Re,D)*(L/D)*¦Ñ*v*|v|/2
%     = ¦Ë(Re,D)*8*L/(¦Ð^2*D^5*¦Ñ)*m_flow*|m_flow|
%      = ¦Ë2(Re,D)*k2*sign(m_flow);
%
% with
%   Re     = |v|*D*¦Ñ/¦Ì
%          = |m_flow|*4/(¦Ð*D*¦Ì)
%   m_flow = A*v*¦Ñ
%   A      = ¦Ð*(D/2)^2
%   ¦Ë2     = ¦Ë*Re^2
%   k2     = L*¦Ì^2/(2*D^3*¦Ñ)
%
%
%% description
%========================input=============================================
% flowrate_in: the volume flow at the inlet of a pipe;  [m3/s]
% temp_in:     the temperature at the inlet of a pipe;  [¡æ]
% length_pipe: the length of pipe;                      [m]
% diameter:    the diameter of the circular pipe;       [m]
% parameter_pipe: a struct containing:
%                 parameter_pipe.miu:                  dynamic viscosity;
%                 parameter_pipe.density:              water density;
%                 parameter_pipe.osbolute_roughness:   obsolute
%                 roughness;the specific value can be obtained from the
%                 following table;
%                 parameter_pipe.k: K factor; geometry- and size-dependent
%                 loss coefficient;
%----------------|----------------------------------------------|---------------
% Smooth pipes	 |  Drawn brass, copper, aluminium, glass, etc.	| d = 0.0025 mm
%                |  New smooth pipes	                        | d = 0.025 mm
%----------------|----------------------------------------------|-----------------
% Steel pipes	 |  Mortar lined, average finish	            | d = 0.1 mm
%                |  Heavy rust                                  | d = 1 mm
%----------------|----------------------------------------------|-----------------
%                |  Steel forms, first class workmanship	    | d = 0.025 mm
% Concrete pipes |  Steel forms, average workmanship	        | d = 0.1 mm
%                |  Block linings	                            | d = 1 mm
%--------------------------------------------------------------------------------
%=======================output=============================================
% delta_pressure: the pressure difference between inlet and outlet;
% temp_out:       the temperature at outlet of a pipe;

%% equation


if nargin<3
    length_pipe=100;
end

if nargin<4
    diameter=0.2;
end

if nargin<5
    parameter_pipe.miu=1.01*10^(-3);
    parameter_pipe.obsolute_roughness=0.1*10^(-3);     % default: steel form, average workmanship;
    parameter_pipe.k=2;
end

miu=parameter_pipe.miu;
density_water=RhoWater(temp_in);
obsolute_roughness=parameter_pipe.obsolute_roughness;
delta=obsolute_roughness/diameter;
k=parameter_pipe.k;

massflow_rate=flowrate_in.*density_water;
Re=4*massflow_rate./(pi*diameter*miu);

k2=length_pipe*miu^2./(2*diameter^3.*density_water);

lambda2=0.25*(Re./(log10(delta/3.7+5.74./Re.^0.9))).^2;
delta_pressure_pipe=k2.*lambda2;


delta_pressure_valve1=8*k./(pi^2*diameter^4.*density_water).*massflow_rate.^2;
delta_pressure_valve2=8*k./(pi^2*diameter^4.*density_water).*massflow_rate.^2;
% pressure at outlet
pressure_drop=delta_pressure_valve1+delta_pressure_pipe+delta_pressure_valve2;

temp_out=temp_in;
flowrate_out=flowrate_in;

