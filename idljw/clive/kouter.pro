function kouter,kay1,kay2
sz1=size(kay1,/dim)
sz2=size(kay2,/dim)
n1=sz1(1)
n2=sz2(1)
n=n1*n2
szout=sz1 & szout(1)=n
kout=fltarr(szout)
for i=0,2 do for k1=0,n1-1 do for k2=0,n2-1 do begin
    kout(i,k1*n2+k2)=kay1(i,k1)+kay2(i,k2)
endfor

return,kout
end

