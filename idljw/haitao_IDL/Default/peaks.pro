function peaks,y,nsig,dum,level=level,count=npk
on_error,2
d0 = y - shift(y,1)
d1 = y - shift(y,-1)
pk = where(d0 gt 0 and d1 gt 0,npk)
if keyword_set(level) then begin
    bigind = where(y[pk] gt level, npk)
    return,pk[bigind]
endif

if n_elements(nsig) gt 0 then begin
    yp = y[pk]
    mn = robust_mean(yp,4)
    sig = robust_sigma(yp)
    bigind = where(yp gt mn + nsig*sig, npk)
    if npk gt 0 then big = pk[bigind] else big = -1
endif else big = pk

return,big
end
