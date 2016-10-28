function cross2to1,c
; Transforms 2D cross-correlation matrix to 1D cross-correlation vector

n=(size(c))(1)
c1=fltarr(n*n)
for i=0,n-1 do c1(i*n:i*n+n-1)=c(i,*)
return,c1
end
