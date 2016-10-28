function calc_mn,M

; Calculates the correlation mapping Mn matrix (\widehat{M}) in the paper)
; from M.

nn=(size(M))(2)
np=(size(M))(1)
Mn=fltarr(np*np,nn*nn)
for i=0,np-1 do begin
  for j=0,np-1 do begin
    for k=0,nn-1 do begin
      for l=0,nn-1 do begin
        Mn(i*np+j,k*nn+l)=M(i,k)*M(j,l)
      endfor
    endfor
  endfor
endfor        
return,Mn
end
