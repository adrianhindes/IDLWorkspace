;sh=10931&tr=[2,3]
;sh=10951 & tr=[2,7];[2,4];.r [5,7]
;sh=10953 & tr=[1,4];[2,4];.r [5,7]
;sh=10962 & tr=[0.6, 2.0];+[0,2]
;sh=10989 & tr=[0.5,2]
;sh=10997 & tr=[8,10];[2.4,4.4]
;sh=11005 & tr=[2,6]
;sh=11006 & tr=[0,1]
;sh=11082 & tr=[.25,1.5];[1.5,3]
;sh=11104 & tr=[0,4]
sh=11082 & tr=[0.3,2.0] 
cacheread=0
cachewrite=1
nskip=1
nsm=1

;arange=

;goto,e
newdemodflcshot,sh,tr,res=res,/only2,cacheread=cacheread,cachewrite=cachewrite,nskip=nskip,sg=1,/lut
resnew=res
;newdemodflcshot,sh,tr,res=resnew,cacheread=0,cachewrite=cachewrite,nskip=nskip,rresref=res, nsm=1

e:


ip=cgetdata('\RC01',db='kstar',sh=sh)&ip.v*=(-1)
n1=cgetdata('\NB11_I0',db='kstar',sh=sh)
n2=cgetdata('\NB12_I0',db='kstar',sh=sh)
n3=cgetdata('\NB13_I0',db='kstar',sh=sh)

plot,ip.t,ip.v,xr=tr,xsty=1,pos=posarr(1,6,0),title='ip -- shot'+string(sh)
plot,n1.t,n1.v,xr=tr,xsty=1,pos=posarr(/next),/noer,title='beams'
oplot,n2.t,n2.v,col=2
oplot,n3.t,n3.v,col=3

plot,resnew.t,resnew.dopc(64,38,*),xr=tr,xsty=1,pos=posarr(/next),/noer,yr=prange,psym=-4,title='doppler phase/deg & light intensity(blue)'
;plot,t2,i0,xr=tr,xsty=1,pos=posarr(/curr),/noer,col=4,ysty=4
plot,resnew.t,resnew.ang(64,38,*),xr=tr,xsty=1,pos=posarr(/next),/noer,yr=arange,psym=-4,col=2,title='polarimetric phase/deg'



stop











f:

;n=n_elements(
offset=7.76
contourn2,transpose(reform(resnew.ang(*,76/2,*))-offset),resnew.t,resnew.r1,zr=[-20,20]/2,pal=-2,lev=[-10,-5,0,5,10],/box,xsty=1

readpatch,sh,db='k',str,/getflc,nfr=1
plot,str.pinfoflc.flc0.t,str.pinfoflc.flc0.v,xr=!x.crange,/noer,col=2,xsty=1;,pos=posarr(/curr)





nbi1=cgetdata('\NB11_I0',db='kstar',sh=sh)
nbi2=cgetdata('\NB12_I0',db='kstar',sh=sh)
nbi3=cgetdata('\NB13_I0',db='kstar',sh=sh)
;ece=cgetdata('\EC1_RFFWD1',db='kstar',sh=sh,/norest)
;plot,ece.t,ece.v,/noer,xr=!x.crange,xsty=1,col=1,thick=3
plot,nbi1.t,nbi1.v,/noer,xr=!x.crange,xsty=1,col=3
oplot,nbi2.t,nbi2.v,col=4
oplot,nbi3.t,nbi3.v,col=5

plot,resnew.t,resnew.dopc(64,35,*),/noer,xr=!x.crange,xsty=1,thick=3
axis,!x.crange(1),!y.crange(0),yaxis=1
stop
;,pos=posarr(1,2,0)


vg1=cgetdata('\NB11_VG1',db='kstar',sh=sh) & vg1.v*=1000
deg=360*600/3E8*SQRT(2*1.6E-19*(vg1.v*1000)/1.67E-27/2)
deg-=deg(value_locate(vg1.t,tr(0)))

dt1=resnew.t(1)-resnew.t(0)
dt1=30e-3
dt0=vg1.t(1)-vg1.t(0)
nsm=dt1/dt0
degs=smooth(deg,nsm)
degsi=interpol(degs,vg1.t,resnew.t+dt1/2)

plot,resnew.t,degsi,col=3,/noer,xr=!x.crange,xsty=1,yr=[-20,20]+20,psym=-4,pos=posarr(/next)
oplot,resnew.t,(resnew.ang(62,76/2,*)-55)*4,col=4

oplot,resnew.t,(resnew.ang(62,76/2,*)-55)*4-degsi,col=5

end
