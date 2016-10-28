pro read_he_nist, lam,inten
fil='~/He_I.htm'
d=read_ascii('~/He_I.htm',data_start=164,delim='|')

dd=d.(0)
lam=reform(dd(0,*))
inten=dd(1,*)
idx=where(finite(lam))
inten=inten(idx)
lam=lam(idx)
end
