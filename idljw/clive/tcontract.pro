function tcontract,tens1,tens2
sz1=size(tens1,/dim) ; 4x4;n
sz2=size(tens2,/dim) ; 4x4;m .e.g. 3
n1=sz1(2)
n2=sz2(2)
n=n1*n2
szout=sz1 & szout(2)=n
tout=complexarr(szout)
for i=0,3 do for j=0,3 do for k1=0,n1-1 do for k2=0,n2-1 do begin
    tout(i,j,k1*n2 + k2)=total(tens1(i,*,k1)*tens2(*,j,k2))
endfor
return,tout
end

