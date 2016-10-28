   dat=(read_ascii('/data/kstar/misc/wbtest1/Ar_lamp_spec.txt',data_start=12)).(0)
   dlam=reform(dat(0,*))
   ddat=reform(dat(2,*))

read_ar_nist,lam,inten
inten/=max(inten)
ddat/=max(ddat)
plot,dlam,ddat,/ylog,xr=[600,700],psym=-5
plot,lam,alog10(inten),col=2,psym=4,/noer,xr=!x.crange,xsty=4,ysty=4
for i=0,n_elements(lam)-1 do oplot,lam(i)*[1,1],[!y.crange(0),alog10(inten(i))],col=2

end

