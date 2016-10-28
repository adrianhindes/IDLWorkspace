
function ri, vec,xp
n=n_elements(xp)
rv=fltarr(n)
for i=0,n-1 do rv(i)= xp(i) mod 2 eq 0 ? float(vec(i)) : imaginary(vec(i))
;for i=0,n-1 do rv(i)= xp(i) mod 2 eq 0 ? abs(vec(i)) : atan2(vec(i))
return,rv

end
