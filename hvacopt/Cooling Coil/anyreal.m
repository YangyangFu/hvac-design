function [tf,realOne] = anyreal( A )
%ANTREAL determine if there is any real value in matrix A.
%   

[row,col]=size(A);

for i=1:row
    for j=1:col
        
        realOne(i,j)=isreal(A(i,j));
        
    end
end

if sum(sum(realOne))~=0
    tf=1;
else
    tf=0;
end

end

