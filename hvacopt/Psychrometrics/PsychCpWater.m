function [CpWater] = PsychCpWater(T)
%
%          !       AUTHOR         FUYANGYANG
%          !       DATE WRITTEN   January 2015
%
%          ! PURPOSE OF THIS FUNCTION:
%          ! This function provides the specific of water at a specific temperature.
%
%          ! METHODOLOGY EMPLOYED:
%          ! na
%          ! REFERENCES:
%          ! na


  CpWater=4180*ones(size(T)); %[J/(kg.k)]
end

