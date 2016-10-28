function bolyongas3

length=0

for m=0,127 do begin
  for l=0,127 do begin
  
  length=length+cos(sqrt(abs(l-m))*0.3*randomn(seed,1,/NORMAL,/DOUBLE))
    
  endfor
endfor

return,length

end