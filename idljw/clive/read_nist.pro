pro read_nist, lam,inten,nam=nam
fil='~/'+nam+'.htm'
;fil='~/Ar_I.htm'
ds=164
if nam eq 'Ar_II' then ds=168
d=read_ascii(fil,data_start=ds,delim='|')

dd=d.(0)
lam=reform(dd(0,*))
inten=dd(1,*)
idx=where(finite(lam))
inten=inten(idx)
lam=lam(idx)

end
