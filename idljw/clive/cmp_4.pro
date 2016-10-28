@getptsnew
;goto,af

sh=7426&off=52&only2=0


;sh=7485&off=52&only2=1

newdemodflc,sh, off,dopc=dopc1,angt=ang1,eps=eps1,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,demodtype='basicd2'
common cbshot, shotc,dbc,isconnected
shotc=sh
dbc='kstar'

nbi1=cgetdata('\NB11_VG1')      ;\NB11_I0')
nbi2=cgetdata('\NB12_VG1')
nsm=round( p.dt / (nbi1.t(1)-nbi1.t(0)))
tw=p.t0+off*p.dt
tmp=smooth(nbi1.v,nsm)
en=interpol(tmp,nbi1.t,tw)




sh=1203
off=5 ; 2.5s
newdemodflc,sh, off,dopc=dopc2,angt=ang2,demodtype='basicd2';,only2=1
af:
dd=dopc1-dopc2
dd=dd*!dtor
print,dd(100,100)
jumpimg,dd
print,dd(100,100),'after jump'
dd=dd*!radeg


iy=100





getptsnew,rarr=r2,zarr=z2,str=p,ix=ix2,iy=iy2,pts=pts,cdir=cdir,ang=ang



mi=1.67e-27
echarge=1.6e-19
kev=1000

vel=sqrt(2*echarge*en*kev/(mi*2)) ; deuterium primary
clight=3e8
vc=vel/clight
l0=656.1
ds=l0 *(1+ vc * cos(ang*!dtor))

gencarriers2,th=[0,0],sh=7425,kz=kz,kappa=kappa
;kappa=1/kappa
nwav=-kz(1) * ds/l0 * kappa
nwav0=nwav(100,100)-dd(100,100)/360

mkfig,'~/rsphy/cmp_4.eps'
plot,dd(*,iy),yr=[-400,300]
oplot,(nwav(*,iy)-nwav0)*360,col=3
endfig,/jp
stop
resid=dd - (nwav-nwav0)*360
imgplot,resid,/cb
print,'nwav0=',nwav0
print,'en=',en
;endfig,/jp,/gs

;imgplot,resid-resid0,/cb,pal=-2

;, only2=only2, eps=eps,angt=ang,dop1=dop1,dop2=dop2,doplot=doplot,cacheread=cacheread,cachewrite=cachewrite,dop3=dop3,dopc=dopc,dostop=dostop,ang0=ang0,pp=p,str=str,sd=sd,noload=noload,vkz=vkz,lin=lin,inten=inten,ix=ix,iy=iy,plotcar=plotcar,cix=cix,ciy=ciy,only1=only1,cars=cars
end
