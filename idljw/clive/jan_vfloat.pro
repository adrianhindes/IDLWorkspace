pro jan_vfloat,sh,xr=xr,fr=fr,zrm=zrm,zri=zri,df=df,dt=dt,nohan=nohan,minc=minc
default,dt,3e-3
default,df,3e3
default,fr,[0,200e3]
default,zrm,[-7,-2]
default,zri,[-10,-2]
default,xr,[0,.05]

mdsopen,'h1data',sh
fvolt=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_4',/nozero)
volt=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_1',/nozero)
rf=mdsvalue2('\H1DATA::TOP.RF:P_RF_NET',/nozero)
mirn=mdsvalue2('\H1DATA::TOP.MIRNOV.ACQ132_8:INPUT_01',/nozero)
plot,fvolt.t,fvolt.v,pos=posarr(2,4,0),title='fvolt #'+string(sh,format='(I0)'),xsty=1,xr=xr,/yno

spectdata2,interpol(fvolt.v,fvolt.t,mirn.t),ps,t1,f1,t0=min(mirn.t),fdig=1/(mirn.t(1)-mirn.t(0)),dt=dt,nohan=nohan,df=df
imgplot,alog10(ps),t1,f1,pos=posarr(/next),/noer,title='ps fvolt',xr=!x.crange,xsty=1,/cb,zr=zri,yr=fr

plot,volt.t,volt.v,/noer,pos=posarr(/next),title='volt',xr=!x.crange,xsty=1
dum=posarr(/next)
plot,mirn.t,mirn.v,/noer,pos=posarr(/next),title='mirn',xr=!x.crange,xsty=1

spectdata2,mirn.v,ps2,t2,f2,t0=min(mirn.t),fdig=1/(mirn.t(1)-mirn.t(0)),dt=dt,nohan=nohan,df=df
imgplot,alog10(ps2),t2,f2,pos=posarr(/next),/noer,title='ps mirn',xr=!x.crange,xsty=1,/cb,zr=zrm,yr=fr

plot,rf.t,rf.v,/noer,pos=posarr(/next),xr=!x.crange,xsty=1,title='rf'

spectdata2c,mirn.v,interpol(fvolt.v,fvolt.t,mirn.t),cc,t3,f3,t0=min(mirn.t),fdig=1/(mirn.t(1)-mirn.t(0)),dt=dt,nohan=nohan,df=df

cc=cc/sqrt(ps*ps2)
default,minc,0.4
idx=where(abs(cc) lt minc)
if idx(0) ne -1 then cc(idx)=0
imgplot,(abs(cc)),t2,f2,pos=posarr(/next),/noer,title='cc isat mirn',xr=!x.crange,xsty=1,/cb,yr=fr,zr=[minc,1]
stop



;stop
end
