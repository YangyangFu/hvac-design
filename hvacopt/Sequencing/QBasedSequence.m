function NumON=QBasedSequence(FlowRate,NomFlow,NumONMax)



row=size(FlowRate,1);
NumON=NumONMax*ones(row,1);

k=1;
while k<=row
    % flowrate required is far more than that all the pumps can provide.
    if FlowRate(k,1)>=NumONMax*NomFlow*1.2
        NumON(k)=NumONMax;
        % determine the online number of pumps due to real-time flowrate
        % required by AHUs and nominal flowrate of pumps
    elseif (floor(FlowRate(k,1)/NomFlow)*...
            NomFlow*1.2-FlowRate(k,1))>=0
        
        NumON(k)=floor(FlowRate(k,1)/NomFlow);
        
    else
        NumON(k)=floor(FlowRate(k,1)/NomFlow)+1;
    end
    
    k=k+1;
end
end