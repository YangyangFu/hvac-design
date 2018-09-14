clear;

flowrate_in=0.3226;%[0.1:0.1:1]';
temp_in=12*ones(size(flowrate_in));
length_pipe=70;

    parameter_pipe.miu=1.01*10^(-3);
    parameter_pipe.obsolute_roughness=0.1*10^(-3);     % default: steel form, average workmanship;
    parameter_pipe.k=0.5;

[flowrate_out,temp_out,pressure_drop]=DetailedPipe(flowrate_in,temp_in,length_pipe,0.25,parameter_pipe);