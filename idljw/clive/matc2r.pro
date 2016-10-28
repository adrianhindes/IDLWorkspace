function matc2r, mat
sz=size(mat,/dim)
mat2=fltarr(sz*2)
matr=float(mat)
mati=imaginary(mat)
for i=0,sz(0)-1 do for j=0,sz(1)-1 do begin
    ii=2*i
    jj=2*j
    mat2(ii,jj)=matr(i,j)
    mat2(ii+1,jj)=-mati(i,j)
    mat2(ii,jj+1)=mati(i,j)
    mat2(ii+1,jj+1)=matr(i,j)
endfor
return,mat2
end
