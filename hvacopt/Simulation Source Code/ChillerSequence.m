
function [NumONSmall,NumONMiddle,NumONLarge]=ChillerSequence(RealValue,DesignValue,MaxNum,ControlStrategy)

DesignSmall=DesignValue.Small;
DesignMiddle=DesignValue.Middle;
DesignLarge=DesignValue.Large;

NumONSmallMax=MaxNum.Small;
NumONMiddleMax=MaxNum.Middle;
NumONLargeMax=MaxNum.Large;


row=size(RealValue,1);

NumONSmall=zeros(row,1);
NumONMiddle=zeros(row,1);
NumONLarge=zeros(row,1);

k=1;
while k<=row
    if (RealValue(k)<0)||isinf(RealValue(k))||isnan(RealValue(k))||~isreal(RealValue(k))
        NumONSmall(k)=NumONSmallMax;
        NumONMiddle(k)=NumONMiddleMax;
        NumONLarge(k)=NumONLargeMax;
        
    elseif (RealValue(k)>=(DesignSmall*NumONSmallMax+...
            DesignMiddle*NumONMiddleMax+DesignLarge*NumONLargeMax));
        NumONSmall(k)=NumONSmallMax;
        NumONMiddle(k)=NumONMiddleMax;
        NumONLarge(k)=NumONLargeMax;
    else
                [NumONSmall(k),NumONMiddle(k),NumONLarge(k)]=FBasedChillerSequence(...
                    RealValue(k),DesignValue,MaxNum);

    end
    k=k+1;
end

end





