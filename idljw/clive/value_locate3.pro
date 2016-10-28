function value_locate3,arr,val
rv=val
nval=n_elements(val)
for i=0,nval-1 do begin
    dum=min(abs(arr-val(i)),imin)
    rv(i)=imin
endfor
return,rv
end
