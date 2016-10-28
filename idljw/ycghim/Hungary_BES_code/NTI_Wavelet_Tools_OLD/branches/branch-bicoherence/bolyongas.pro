function bolyongas

g=0.3*randomn(seed,128,/NORMAL,/DOUBLE)
g[0]=2*!DPI*randomn(seed,1,/UNIFORM,/DOUBLE)
length=0

for m=0,127 do begin
  for l=0,127 do begin
  
    if l GT m then begin
      length=length+cos(total(g[m+1:l]))
    endif
    if l LT m then begin
      length=length+cos(total(g[l+1:m]))
    endif  
  
  endfor
endfor

return,length

end