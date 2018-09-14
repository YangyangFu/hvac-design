function [ output_args ] = ChillerSequencingQBased( input_args )
%CHILLERSEQUENCINGQBASED chiller sequencing strategy based on real load
%   This function simulates chiller sequences based on real metered cooling
%   load.

% 06/05/2008
%
%*************************************************************************
% Inputs
%
% Includes three parts: measurements, parameters and previous results
%
% % measurements
% 01-06 : Pev % Evaporating pressure(kPa)
% 07-12 : Pcd % Condensing temperature(kPa)
% 13    : CL_fusion % Fused cooling load(kW)
% 14    : CL_degree % Fused cooling load quality
% 15    : trnTime % Current system time(minutes)
% 16    : Tchout % Chilled water supply temperature (C)
% 17-20 : reserve for future use
%
% % previous results
% 21    : OTime          % previous action occuring time (minute)
% 22    : Num_previous   % current number of operating chiller
% 23    : Pre_oper       % previous action:1 indicates staging one
%                       and -1 indicates destaging one
% 24-28 : reserve for future use
%
% % parameters
% 29    : A=3150        % The parameter for determining the maximum cooling
%                         capacity of single chiller
% 30    : T_err=0.5     % The allowed temperature deviation (C)
% 31    : Tset=5.5      % Chilled water supply temperature setpoint (C)
% 32    : OPeriodThreshold=30 % Time limit for same action orientation
% 33    : CPeriodThreshold=40 % Time limit for opposite action orientation
% 34    : Deadband=5    % the band for preventing chiller from
%                         repeatedly switching
% 35-39 : reserve for future use
%
%*********************************************************************
%****
% Outputs
%
% 01 : the number of operating chillers in next time instant (Num_previous)
% 02 : the time of action occured last time (OTime)
% 03 : the switching action of last time (Pre_oper)
% 04 : Chiller maximum cooling capacity (kW)
% 5-8: reserve for future use
%
%
%*********************************************************************
%****
%
% variables
% CAP    : Maximum cooling capacity of single chiller (kW)
% ONum   : number of chillers that could be changed
% Period : time length between the current time and the last action occuring time
% Q_load : fused cooling load (kW)
% Q_state_threshold : threshold for staging one more chiller (kW)
% Q_Destate_threshold : threshold for destaging one more chiller (kW)

% measurement inputs
Pev = SeqCtrl_input(1:6);
Pcd = SeqCtrl_input(7:12);
CL_fusion = SeqCtrl_input(13);
CL_degree = SeqCtrl_input(14);
trnTime = SeqCtrl_input(15);
Tchout = SeqCtrl_input(16);

% % filtering the foul data
% Pev_thre=10;
% Pcd_thre=10;
% CL_fusion_thre=0;
% CL_degree_thre=0;
% Tchout_thre=0;
% for i=1:6
%     if Pev(i)<Pev_thre
%         Pev(i)=Pev_thre;
%     end
%     if Pcd(i)<Pcd_thre
%         Pcd(i)=Pcd_thre;
%     end
% end
% if CL_fusion<CL_fusion_thre
%     CL_fusion=CL_fusion_thre;
% end
% if CL_degree<CL_degree_thre
%     CL_degree=CL_degree_thre;
% end
% if Tchout<Tchout_thre
%     Tchout=Tchout_thre;
% end

% previous results
OTime = SeqCtrl_input(21);
Num_previous = SeqCtrl_input(22);
Pre_oper = SeqCtrl_input(23);

% % parameters
% A     = SeqCtrl_input(29);
% T_err = SeqCtrl_input(30);
% Tset  = SeqCtrl_input(31);
OPeriodThreshold = SeqCtrl_input(32);
CPeriodThreshold = SeqCtrl_input(33);
DeadBand         = SeqCtrl_input(34);

% A = 3150;    % the parameter to determine the maximum cooling capacity of chiller
% Tset = 5.5;  %Temp. setpoint
% T_err = 0.5; % temperature deviation allowed

% % parameters for pressure and temp. convertion for R134a
% Ac1=17.4;
% Bc1=3297.2;
% % R134a thermophysical parameters
% Cpl = 1.265; % liquid refrigerant R134a specific heat(kW/kg.C)
% Cpg = 0.8925; % gaseous refrigerant specific heat R134a(kW/kg.C)
% Hfg0 = 197.9; % latent heat at reference state pressure R134a (kJ/kg)
% RZ = 73.4143; % gas constant times the compressibility factor of the refrigerant R134a
% 
% [Pev_oper,N_oper] = min(Pev);
% Tev(N_oper)=273.15+Bc1/(Ac1+log(Pev(N_oper)));
% Tcd(N_oper)=273.15+Bc1/(Ac1+log(Pcd(N_oper)));
% Tev_oper = Tev(N_oper);
% Tcd_oper = Tcd(N_oper);
% CAP0 =(A*Pev_oper)*(Hfg0+Cpg*Tev_operCpl*Tcd_oper)/(RZ*(273.15+Tev_oper));
% %considering the real CAP with respect to the CL_degree
% if Tchout <= Tset+T_err
%     if CL_degree>=0.8
%         CAP = CAP0;
%     else
%         CAP = CAP0*1.02;
%     end
% else
%     CAP = CAP0;
% end
% %
%**********************************************************************
% Updated Chiller sequence Control
%
%**********************************************************************
% OPeriodThreshold = 30/60; % the time period (hour) for two operations with same direction
% CPeriodThreshold = 40/60; % the time period (hour) for two operations with opposite directions
% DeadBand = 5;
% calculate the Q_load
Q = CL_fusion;
if Q < 0
    Q_load = 0;
else
    Q_load = Q;
end
% % calculate the number of chillers in operation
%
% OTime = history.OTime;
% Pre_oper = history.Pre_oper;
%
% % the number of chillers in operation
Period = trnTime-OTime; % the period
if Period<0
    Period=Period+24;
end
% the threshold for switching on/off a chiller
Q_state_threshold = Num_previous*CAP*(1+DeadBand/100);
Q_Destate_threshold = (Num_previous-1)*CAP*(1-DeadBand/100);
% determine the number of chillers should be in operation

% open a chiller
if Q_load > Q_state_threshold & Num_previous < 6
    % ONum = 1; % start from the second one
    % % which one should be open
    % while CH(ONum).ONOFF >= 1 & ONum<6
    % ONum = ONum+1;
    % end
    ONum=Num_previous+1;
    % open the chiller
    if ONum <= 6
        if Period >= OPeriodThreshold & Pre_oper==1
            % CH(ONum).ONOFF = 1;
            %at the beginning of the state or destate the chiller power
            %consumption can not indicate the supplied cooling
            Pre_oper=1;
            OTime = trnTime;
            Num_previous = Num_previous+1;
        elseif Period>= CPeriodThreshold & Pre_oper==-1
            %at the beginning of the state or destate the chiller power
            %consumption can not indicate the supplied cooling
            Pre_oper=1;
            Num_previous = Num_previous+1;
            OTime = trnTime;
        end
    end
end
% close a chiller
if Q_load < Q_Destate_threshold & Num_previous > 1
    ONum=Num_previous;
    % close the one
    if ONum >= 2
        if Period >= OPeriodThreshold & Pre_oper==-1
            Pre_oper=-1;
            Num_previous = Num_previous-1;
            OTime = trnTime;
        elseif Period >= CPeriodThreshold & Pre_oper==1
            Pre_oper=-1;
            Num_previous = Num_previous-1;
            OTime = trnTime;
        end
    end
end
% Outputs
SeqCtrl_output = zeros(1,8);
SeqCtrl_output(1) = Num_previous;
SeqCtrl_output(2) = OTime;
SeqCtrl_output(3) = Pre_oper;
SeqCtrl_output(4) = CAP;

end

