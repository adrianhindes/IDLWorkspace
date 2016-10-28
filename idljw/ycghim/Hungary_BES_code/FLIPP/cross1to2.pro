function cross1to2,c1
; Transforms 1D cross-correlation vector to 2D cross-correlation
;  matrix

n=(size(c1))(1)
n=fix(sqrt(n))
c2=fltarr(n,n)
for i=0,n-1 do c2(i,*)=c1(i*n:i*n+n-1)
return,c2
end
