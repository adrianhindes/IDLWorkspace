function ir, vec
n=n_elements(vec)
rv=complexarr(n/2)
;for i=0,n/2-1 do rv(i)=vec(2*i)*exp(complex(0,1)*vec(2*i+1))
for i=0,n/2-1 do rv(i)=complex(vec(2*i),vec(2*i+1))
return,rv
end
