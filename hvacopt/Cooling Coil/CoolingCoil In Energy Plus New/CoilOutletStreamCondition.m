function [EnergyOutStreamOne,EnergyOutStreamTwo]=CoilOutletStreamCondition(CapacityStream1,...
    EnergyInStreamOne,CapacityStream2,EnergyInStreamTwo,CoilUA,HeatExchType)

%! Calculating coil outlet stream conditions and coil UA for Cooling Coil
%! SUBROUTINE CoilOutletStreamCondition(CoilNum, CapacityStream1,EnergyInStreamOne,           &
%                                     CapacityStream2,EnergyInStreamTwo,                    &
%                                     CoilUA,EnergyOutStreamOne,EnergyOutStreamTwo)
%
%          ! FUNCTION INFORMATION:
%          ! AUTHOR         Rahul Chillar
%          ! DATE WRITTEN   March 2004
%          ! MODIFIED       na
%          ! RE-ENGINEERED  na
%
%          ! PURPOSE OF THIS FUNCTION:
%          ! Calculate the outlet states of a simple heat exchanger using the effectiveness-Ntu
%          ! method of analysis.
%
%          ! METHODOLOGY EMPLOYED:
%          ! na
%
%          ! REFERENCES:
%          ! Kays, W.M. and A.L. London.  1964.Compact Heat Exchangers, 2nd Ed.McGraw-Hill:New York.
%
%          ! FUNCTION ARGUMENT DEFINITIONS:
%      Integer, intent(in) :: CoilNum
%      REAL(r64), intent(in) :: CapacityStream1              ! Capacity rate of stream1(W/C)
%      REAL(r64), intent(in) :: EnergyInStreamOne            ! Inlet state of stream1 (C)
%      REAL(r64), intent(in) :: CapacityStream2              ! Capacity rate of stream2 (W/C)
%      REAL(r64), intent(in) :: EnergyInStreamTwo            ! Inlet state of stream2 (C)
%      REAL(r64), intent(in) :: CoilUA                       ! Heat transfer rateW)
%      REAL(r64)        :: EnergyOutStreamOne                ! Outlet state of stream1 (C)
%      REAL(r64)        :: EnergyOutStreamTwo                ! Outlet state of stream2 (C)
%
%
      

%          ! FUNCTION PARAMETER DEFINITIONS:
          LargeNo = 1e10 ;  %! value used in place of infinity
          SmallNo = 1e-15 ; %! value used in place of zero
%
%          ! FUNCTION LOCAL VARIABLE DECLARATIONS:
%      REAL(r64) MinimumCapacityStream    ! Minimum capacity rate of the streams(W/C)
%      REAL(r64) MaximumCapacityStream    ! Maximum capacity rate of the streams(W/C)
%      REAL(r64) RatioStreamCapacity      ! Ratio of minimum to maximum capacity rate
%      REAL(r64) NTU                       ! Number of transfer units
%      REAL(r64) :: effectiveness=0.0      ! Heat exchanger effectiveness
%      REAL(r64) MaxHeatTransfer          ! Maximum heat transfer possible(W)
%      REAL(r64)  e, eta, b, d             ! Intermediate variables in effectivness equation


%! NTU and MinimumCapacityStream/MaximumCapacityStream (RatioStreamCapacity) calculations
MinimumCapacityStream = min(CapacityStream1,CapacityStream2);
MaximumCapacityStream = max(CapacityStream1,CapacityStream2);



if(abs(MaximumCapacityStream) <=1e-6)  %! .EQ. 0.) THEN
    RatioStreamCapacity = 1;
else
    RatioStreamCapacity = MinimumCapacityStream./MaximumCapacityStream;
end


if(abs(MinimumCapacityStream) <=1e-6)
    NTU = LargeNo;
else
    NTU = CoilUA./MinimumCapacityStream;
end


%! Calculate effectiveness for special limiting cases
if(NTU < 0)
    effectiveness = 0;
    
elseif(RatioStreamCapacity < SmallNo)
    %! MinimumCapacityStream/MaximumCapacityStream = 0 and effectiveness is independent of configuration
    %! 20 is the Limit Chosen for Exponential Function, beyond which there is float point error.
    if(NTU > 20)
        effectiveness = 1.0;
    else
        effectiveness = 1.0 - exp(-NTU);
    end
    %! Calculate effectiveness depending on heat exchanger configuration
elseif (HeatExchType ==1)% Counter flow
    
    %! Counterflow Heat Exchanger Configuration
    if (abs(RatioStreamCapacity-1) < SmallNo)
        effectiveness = NTU./(NTU+1.0);
    else
        if(NTU*(1-RatioStreamCapacity) > 20.0)
            e = 0.0;
        else
            e=exp(-NTU*(1-RatioStreamCapacity));
        end
        effectiveness = (1-e)./(1-RatioStreamCapacity.*e);
    end
    
elseif (HeatExchType == 2)% Cross flow
    %! Cross flow, both streams unmixed
    eta = NTU.^(-0.22);
    if((NTU.*RatioStreamCapacity*eta)>20)
        b=1./(RatioStreamCapacity.*eta);
        if(b>20)
            effectiveness=1.0;
        else
            effectiveness = 1.0 - exp(-b);
            if(effectiveness<0)
                effectiveness=0;
            end
        end
    else
        d=(exp(-NTU.*RatioStreamCapacity.*eta)-1.0)./(RatioStreamCapacity.*eta);
        if((d < -20.0) || (d >0.0)) 
            effectiveness=1.0;
        else
            effectiveness = 1.0 - exp((exp(-NTU.*RatioStreamCapacity.*eta)-1)/(RatioStreamCapacity.*eta));
            if(effectiveness<0.0)
                effectiveness=0.0;
            end
        end
    end
elseif(HeatExchType == 0)% Ideal Type
    effectiveness=1;
end

%! Determine leaving conditions for the two streams
MaxHeatTransfer = max(MinimumCapacityStream,SmallNo).*(EnergyInStreamOne-EnergyInStreamTwo);
EnergyOutStreamOne = EnergyInStreamOne - effectiveness.* ...
MaxHeatTransfer./max(CapacityStream1,SmallNo);
EnergyOutStreamTwo = EnergyInStreamTwo + effectiveness.*  ...
MaxHeatTransfer/max(CapacityStream2,SmallNo);

return
end
