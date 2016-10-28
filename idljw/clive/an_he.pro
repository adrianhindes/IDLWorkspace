read_spe,'~/spectrum/He lamp.spe',l,t,d,str=str
ds=total(d(*,512-50:512+50),2)
dlam=l
ddat=ds
read_nist,lam,inten,nam='He_I'

plot,dlam,ddat,/ylog,xr=[450,600],psym=-5
plot,lam,alog10(inten),col=2,psym=4,/noer,xr=!x.crange,xsty=4,ysty=4
for i=0,n_elements(lam)-1 do oplot,lam(i)*[1,1],[!y.crange(0),alog10(inten(i))],col=2

end

