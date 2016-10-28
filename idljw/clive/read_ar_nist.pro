pro read_nist, lam,inten,nam=nam
fil='~/'+nam+'.htm'
;fil='~/Ar_I.htm'
d=read_ascii(nam,data_start=164,delim='|')

dd=d.(0)
lam=reform(dd(0,*))
inten=dd(1,*)
idx=where(finite(lam))
inten=inten(idx)
lam=lam(idx)

end
