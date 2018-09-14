function [flowrate_out,temp_out,pressure_out,delta_pressure_pipe,pressure_drop]=DWPipe(flowrate_in,temp_in,pressure_in,length_pipe,diameter,parameter_pipe)
%% application
% One important special case for a pressure loss is the friction at the wall
% of a pipe under the assumption of quasi steady state flow (i.e., the mass
% flow rate varies only slowly). In this section it is explained how this
% case is handled for pipes with nonuniform roughness. The treatment is
% non-standard in order to get a numerically well-posed description.
% For pipes with circular cross section the pressure drop is computed as:

%   dp = 竹(Re,D)*(L/D)*老*v*|v|/2
%     = 竹(Re,D)*8*L/(羽^2*D^5*老)*m_flow*|m_flow|
% with
%   Re     = |v|*D*老/米
%          = |m_flow|*4/(羽*D*米)
%   m_flow = A*v*老
%   A      = 羽*(D/2)^2
% Valves like cut-off valve are always connected to a piece of pipe. In
% this pipe model the pressure loss through these valves are calculated
% along with pipe model.


%% description
%========================input=============================================
% flowrate_in: the volume flow at the inlet of a pipe;  [m3/s]
% temp_in:     the temperature at the inlet of a pipe;  [⊥]
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
    pressure_in=101325;
end

if nargin<4
    length_pipe=100;
end 

if nargin<5
    diameter=0.2;
end

if nargin<6
    parameter_pipe.miu=1.01*10^(-3);
    parameter_pipe.density=1000;
    parameter_pipe.obsolute_roughness=0.1*10^(-3);     % default: steel pipes,mortar lined, average finish;
    parameter_pipe.k=0.5;  
end

miu=parameter_pipe.miu;
density_water=parameter_pipe.density;
obsolute_roughness=parameter_pipe.obsolute_roughness;
delta=obsolute_roughness/diameter;
k=parameter_pipe.k;

massflow_rate=flowrate_in*density_water;
Re=4*massflow_rate./(pi*diameter*miu); % Reynolds number, dementionless;
[x]=iterate1(8);

%    delta P = 竹(Re,D)*8*L/(羽^2*D^5*老)*m_flow*|m_flow|
lamda=(1./x).^2;
delta_pressure_pipe=lamda*8*length_pipe./(pi^2*diameter.^5*density_water).*massflow_rate.^2;

% pressure drop through valve at inlet
delta_pressure_valve1=8*k/(pi^2*diameter^4*density_water).*massflow_rate.^2;
delta_pressure_valve2=8*k/(pi^2*diameter^4*density_water).*massflow_rate.^2;
% pressure at outlet
pressure_drop=delta_pressure_valve1+delta_pressure_pipe+delta_pressure_valve2;
pressure_out=pressure_in-pressure_drop;

temp_out=temp_in;
flowrate_out=flowrate_in;


  function [x1,n]=iterate1(x)
     x1=ColebrookEquation(x);
     n=1;
    while (abs(x1-x)>=10^(-6))&(n<=10^6)
    x=x1;
    x1=ColebrookEquation(x);
    n=n+1;
     end
  end

    function y=ColebrookEquation(x)
        y=1.74-2*log10(2*delta+18.7./Re.*x);
    end

end



