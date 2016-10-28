pro ansnd,sh,tshift=tshift,tr=tr,zr=zr,prange=prange,arange=arange
default,tr,[0,10]
default,zr,[3.5,5.5]
case sh of 
   11105 : default,tshift,-1
   11104 : default,tshift,-4
   11107 : default,tshoft,-8.5
else: default,tshift,0
endcase


  default,tshift,0
getsound,sh,d,t
;d=fltarr(100)
;t=linspace(0,10,100)
t+=tshift

ip=cgetdata('\RC01',db='kstar',sh=sh)&ip.v*=(-1)
n1=cgetdata('\NB11_I0',db='kstar',sh=sh)
n2=cgetdata('\NB12_I0',db='kstar',sh=sh)
n3=cgetdata('\NB13_I0',db='kstar',sh=sh)

plot,ip.t,ip.v,xr=tr,xsty=1,pos=posarr(1,6,0),title='ip -- shot'+string(sh)
plot,n1.t,n1.v,xr=tr,xsty=1,pos=posarr(/next),/noer,title='beams'
oplot,n2.t,n2.v,col=2
oplot,n3.t,n3.v,col=3
plot,t,d,xr=tr,xsty=1,pos=posarr(/next),/noer,title='sound&low pass filtered rms'
nsm=44e3 / 1000.

d=d*1.
d2=smooth(d,nsm)
sstdev=sqrt(smooth(d2^2,nsm))
oplot,t,sstdev,col=2
oplot,t,-sstdev,col=2

spectdata2,d,ps,t1,f1,t0=t(0),fdig=1/(t(1)-t(0)),dt=0.05,df=20,/nohan
imgplot,alog10(ps),t1,f1,/cb,xr=tr,xsty=1,pos=posarr(/next),/noer,zr=zr,yr=[0,10e3],title='spectrogram of sound'
;mdsopen,'dum',0
common cbshot, shotc,dbc, isconnected
if n_elements(isconnected) ne 0 then if isconnected eq 1 then mdsdisconnect
getphasejohn,sh,t2,p2,i0=i0,/geti0,pd=pd
plot,t2,p2,xr=tr,xsty=1,pos=posarr(/next),/noer,yr=prange,psym=-4,title='doppler phase/deg & light intensity(blue)'
plot,t2,i0,xr=tr,xsty=1,pos=posarr(/curr),/noer,col=4,ysty=4
plot,t2,pd,xr=tr,xsty=1,pos=posarr(/next),/noer,yr=arange,psym=-4,col=2,title='polarimetric phase/deg'
end



