d=25.

ix=intspace(-5,5)
iy=intspace(0,58)
nx=n_elements(ix)
ny=n_elements(iy)
nh=nx*ny

lns=fltarr(3,2,nh)
k=0
for i=0,nx-1 do for j=0,ny-1 do begin
lns(0,*,k) = ix(i)*d
lns(1,*,k) = iy(j)*d
lns(2,*,k) = [0,d/10]
k=k+1
endfor

save,lns,file='~/idl/clive/nleonw/gridsmall2/grid.sav'


end

