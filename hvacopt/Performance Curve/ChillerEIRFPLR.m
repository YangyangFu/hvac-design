function [coefficient_EIRFPLR,gof_EIRFPLR]=ChillerEIRFPLR(PLR,COP,nominal_COP)
%% application
% This function describes  chiller available capactiy at specific
% condition, based on the leaving chilled water temperature and entering
% condenser water temperature.
%% description
%=================input==========================
% PLR: a variable describing leaving chilled water temperature; 
% COP: a variable describing entering condenser water temperature;

%================output==========================
% coefficient: a 1-by-3 matrix describing the coefficients of performance
% curve

%% model


%CREATEFIT(ENTERING_CHW_T2,LEAVING_CW_T2,PLR2)
%  Create a fit.
%
%  Data for 'ChillerEIRFPLR' fit:
%      X Input : PLR
%      Y Input : EIR
%      
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  ¡Ì«Î≤Œ‘ƒ FIT, CFIT, SFIT.


%% Fit: 'ChillerEIRFPLR'.
[xData, yData] = prepareCurveData( PLR, nominal_COP./COP );

% Set up fittype and options.
ft = fittype( 'poly4' );

% Fit model to data.
[fitresult_EIRFPLR, gof_EIRFPLR] = fit( xData, yData, ft);
coefficient_EIRFPLR=[fitresult_EIRFPLR.p4 fitresult_EIRFPLR.p3 fitresult_EIRFPLR.p2 fitresult_EIRFPLR.p1];

% Plot fit with data.
figure( 'Name', 'ChillerEIRFPLR' );
h = plot( fitresult_EIRFPLR, xData, yData);
legend( h, 'ChillerEIRFPLR', 'EIRFPLR vs.PLR', 'Location', 'NorthEast' );
% Label axes
xlabel( 'PLR' );
ylabel( 'EIRFPLR');


