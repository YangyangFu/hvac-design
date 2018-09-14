function [coefficient_CapFT,gof_CapFT]=ChillerCapFTemp(Leaving_Chw_T,Entering_Cw_T,CoolingCap_Factor)
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
%  Data for 'untitled fit 1' fit:
%      X Input : entering_chw_t2
%      Y Input : leaving_cw_t2
%      Z Output: PLR2
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  ¡Ì«Î≤Œ‘ƒ FIT, CFIT, SFIT.


%% Fit: 'ChillerCapFTemp'.
[xData, yData, zData] = prepareSurfaceData( Leaving_Chw_T, Entering_Cw_T, CoolingCap_Factor );

% Set up fittype and options.
ft = fittype( 'poly22' );

% Fit model to data.
[fitresult_CapFT, gof_CapFT] = fit( [xData, yData], zData, ft, 'Normalize', 'on' );
coefficient_CapFT=[fitresult_CapFT.p00 fitresult_CapFT.p10 fitresult_CapFT.p20 fitresult_CapFT.p01 fitresult_CapFT.p02 fitresult_CapFT.p11];
% Plot fit with data.
figure( 'Name', 'ChillerCapFTemp' );
h = plot( fitresult_CapFT, [xData, yData], zData );
legend( h, 'ChillerCapFTemp', 'CoolingCap_Factor vs. Leaving_Chw_T, Entering_Cw_T', 'Location', 'NorthEast' );
% Label axes
xlabel( ' Leaving_Chw_T' );
ylabel( 'Entering_Cw_T' );
zlabel( 'CoolingCap_Factor' );


