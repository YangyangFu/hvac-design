function [coefficient_EIRFTemp,gof_EIRFTemp]=ChillerEIRFTemp(Leaving_Chw_T,Entering_Cw_T,COP,nominal_COP)
%% application
% This function describes  chiller available capactiy at specific
% condition, based on the leaving chilled water temperature and entering
% condenser water temperature.
%% description
%=================input==========================
% Leaving_Chw_T: a variable describing leaving chilled water temperature; 
% Entering_Cw_T: a variable describing entering condenser water temperature;

%================output==========================
% coefficient: a 1-by-6 matrix describing the coefficients of performance
% curve

%% model


%CREATEFIT(ENTERING_CHW_T2,LEAVING_CW_T2,PLR2)
%  Create a fit.
%
%  Data for 'ChillerEIRFTemp' fit:
%      X Input : entering_chw_t2
%      Y Input : leaving_cw_t2
%      Z Output: PLR2
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  ¡Ì«Î≤Œ‘ƒ FIT, CFIT, SFIT.


%% Fit: 'ChillerCapFTemp'.
[xData, yData, zData] = prepareSurfaceData( Leaving_Chw_T, Entering_Cw_T, nominal_COP./COP );

% Set up fittype and options.
ft = fittype( 'poly22' );

% Fit model to data.
[fitresult_EIRFTemp, gof_EIRFTemp] = fit( [xData, yData], zData, ft );
coefficient_EIRFTemp=[fitresult_EIRFTemp.p00 fitresult_EIRFTemp.p10 fitresult_EIRFTemp.p20 fitresult_EIRFTemp.p01 fitresult_EIRFTemp.p02 fitresult_EIRFTemp.p11 ];
% Plot fit with data.
figure( 'Name', 'ChillerEIRFTemp' );
h = plot( fitresult_EIRFTemp, [xData, yData], zData );
legend( h, 'ChillerEIRFTemp', 'EIR vs. Leaving Chw T, Entering Cw T', 'Location', 'NorthEast' );
% Label axes
xlabel( ' Leaving Chw T' );
ylabel( 'Entering Cw T' );
zlabel( 'EIR' );


