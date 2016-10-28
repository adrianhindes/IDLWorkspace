sh=86418
loadinterf,sh,d,dt=dt,t0=t0,/anal
d=d>0
;t=mdsvalue('DIM_OF(\H1DATA::TOP.ELECTR_DENS.CAMAC:A14_22:INPUT_2)')
t=findgen(n_elements(d(*,0)))*dt+t0

p1=mdsvalue('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_4')
p2=mdsvalue('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_09:INPUT_6')
tt=mdsvalue('DIM_OF(\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_5)')
xr=.0684+[0,0.0003];,.0720]
xr=.0273+[0,.001]
xr=.0503+[0,.001]
plot,tt,p1,xr=xr,pos=posarr(1,2,0)
oplot,tt,p2,col=3

d2=convol(d,fltarr(10,1)+1./10.)
;plot,t,d2(*,15),xr=xr,/noer,col=2,pos=po
;plot,t,d2(*,3),xr=xr,/noer,col=4

ii=value_locate(t,xr)
nch=n_elements(d2(0,*))
imgplot,d2(ii(0):ii(1),*),t(ii(0):ii(1)),findgen(nch),pos=posarr(/next),/noer,xsty=1




end
