function bolyongas2

g=0.3*randomn(seed,128,/NORMAL,/DOUBLE)
g[0]=2*!DPI*randomn(seed,1,/UNIFORM,/DOUBLE)

ii=(dcomplex(0,1))
v=dcomplexarr(128)

  for i=0,127 do begin
    v[i]=exp(ii*(total(g[0:i])))
  endfor

;print,total(v)
length=abs(total(v))/128
return,length
end