pro an_x,el,state=state
read_spe,'~/spectrum/'+el+' lamp.spe',l,t,d,str=str
ds=total(d(*,512-50:512+50),2)
dlam=l
ddat=ds
default,state,'I'
read_nist,lam,inten,nam=el+'_'+state

plot,dlam,ddat,/ylog,xr=[300,750],psym=-5
plot,lam,alog10(inten),col=2,psym=4,/noer,xr=!x.crange,xsty=4,ysty=4
for i=0,n_elements(lam)-1 do oplot,lam(i)*[1,1],[!y.crange(0),alog10(inten(i))],col=2

end

