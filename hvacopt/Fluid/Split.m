function [temp_out,flowrate_out,pressure_out]=Split(primary,density_water,varargin)
%% Calculate the pressure from given inlet pressure and flowrate

%% desicription
%============================input====================
% primary:  a struct, describes the primary pipe, which contains:
%                   primary.temp:     inlet temperature of the merge;[¡æ]
%                   primary.pressure: inlet pressure of the merge;[Pa];
%                   primary.resistance: inlet resistance of the merge;[1/(kg.m)]
% varargin: a cell, braches with unknown number.Each cell is composed of a
%                   1-by-2 matrix:
%                   varargin{i}(:,1): the flowrate of the ith brach;[m3/s];
%                   varargin{i}(:,2): the resistance of the ith branch;[1/(kg.m)]
%            

%==========================output====================


%% equation


temp_in=primary.temp;
pressure_in=primary.pressure;
resistance_in=primary.resistance;

n=length(varargin{1,1});
r=size(temp_in,1);

% temperature at the outlet of each brach;
temp_out=zeros(r,n);
for i=1:n
    temp_out(:,i)=temp_in;
end

% flworate at the outlet of each branch;
flowrate_out=zeros(r,n);
for i=1:n
    flowrate_out(:,i)=varargin{1,1}{1,i}(:,1);
end

% Calculate the total flowrate;
flowrate_in=0;
for i=1:n
    flowrate_in=flowrate_in+sum(varargin{1,1}{1,i}(:,1));
end

% pressure at the center of the merge
pressure_center=pressure_in-resistance_in*density_water.*flowrate_in.^2;

% pressure at the outlet of each branch
pressure_out=zeros(r,n);
for i=1:n
    pressure_out(:,i)=pressure_center-varargin{1,1}{1,i}(:,2).*density_water.*varargin{1,1}{1,i}(:,1).^2;
end