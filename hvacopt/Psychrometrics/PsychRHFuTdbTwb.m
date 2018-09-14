function [RH]=PsychRHFuTdbTwb(Tdb,Twb)

H=PsychTdbRH(Twb,1);
W=PsychWFuTdbH(Tdb,H);
RH=PsychRHFuTdbW(Tdb,W);