pro getslope2, l0, dl, dpdx, dpdy,ph=ph
common cbb2, thx,thy
sh=63
dbtrue='kcal2015t0'
la=659.89e-9

;   lamv=lam*(fltarr(1600,1644)+1) ;529e-9

;simimgnew,img,sh=sh,db=dbtrue,lam=la,svec=[2.2,1,1,.2];,/angdeptilt
img=fltarr(1280,1080)
db='kcal2015'
doplot=0
demodtype='basicnofull2'
if n_elements(thx) eq 0 then $
newdemod,img,cars,sh=sh,ifr=ifr,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,thx=thx,thy=thy;,/doload;,/cachewrite,/cacheread

;stop

nx=n_elements(thx)
ny=n_elements(thy)
thv=fltarr(nx,ny,2)
thv(*,*,0) = thx # replicate(1,ny)
thv(*,*,1) = replicate(1,nx) # thy

;l0=659.89
;dl=1
lamh=linspace(l0-dl,l0+dl,nx)*1e-9
lamv=lamh # replicate(1,ny)

;gencarriers2,th=[0,0], sh=sh,db=dbtrue,lam=lamv,kx=kx,ky=ky,kz=kz,tkz=tkz,vth=thv,vkzv=kzv,/quiet
;gencarriers2,th=[0,0], sh=sh,db=dbtrue,lam=la,kx=kx,ky=ky,kz=kz,tkz=tkz,vth=thv,vkzv=kzva,/quiet

gencarriers2,th=[0,0], sh=sh,db=dbtrue,lam=la,kx=kxa,ky=kya,kz=kza,tkz=tkz,vth=thv,vkzv=kzva,/quiet,indexlist=indexlist
gencarriers2,th=[0,0], sh=sh,db=dbtrue,lam=lamv,kx=kx,ky=ky,kz=kz,tkz=tkz,vth=thv,vkzv=kzv,/quiet,indexlist=indexlist,/useindex

dkzv=(kzv-kzva) * 2 * !pi ; fringes to radians

ph=dkzv(*,*,3) / 2 ; pol angle is half savart fringe
;stop

;imgplot,ph,/cb,pos=posarr(2,1,0)
;plot,ph(*,ny/2),pos=posarr(/next),/noer
;oplot,ph(nx/2,*),col=2
;dpdx=(deriv(ph(*,ny/2)))(nx/2)
;dpdy=(deriv(ph(nx/2,*)))(ny/2)
;stop
end


pro getslope, l0, dl, dpdx, dpdy,ph=ph
common cbb, thx,thy
sh=63
dbtrue='kcal2015tt'
la=659.89e-9

;   lamv=lam*(fltarr(1600,1644)+1) ;529e-9

;simimgnew,img,sh=sh,db=dbtrue,lam=la,svec=[2.2,1,1,.2];,/angdeptilt
img=fltarr(1280,1080)
db='kcal2015'
doplot=0
demodtype='basicnofull2'
if n_elements(thx) eq 0 then $
newdemod,img,cars,sh=sh,ifr=ifr,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,thx=thx,thy=thy;,/doload;,/cachewrite,/cacheread

;stop

nx=n_elements(thx)
ny=n_elements(thy)
thv=fltarr(nx,ny,2)
thv(*,*,0) = thx # replicate(1,ny)
thv(*,*,1) = replicate(1,nx) # thy

;l0=659.89
;dl=1
lamh=linspace(l0-dl,l0+dl,nx)*1e-9
lamv=lamh # replicate(1,ny)

gencarriers2,th=[0,0], sh=sh,db=dbtrue,lam=lamv,kx=kx,ky=ky,kz=kz,tkz=tkz,vth=thv,vkzv=kzv,/quiet

gencarriers2,th=[0,0], sh=sh,db=dbtrue,lam=la,kx=kx,ky=ky,kz=kz,tkz=tkz,vth=thv,vkzv=kzva,/quiet
dkzv=(kzv-kzva) * 2 * !pi ; fringes to radians

ph=dkzv(*,*,3)

;imgplot,ph,/cb,pos=posarr(2,1,0)
;plot,ph(*,ny/2),pos=posarr(/next),/noer
;oplot,ph(nx/2,*),col=2
dpdx=(deriv(ph(*,ny/2)))(nx/2)
dpdy=(deriv(ph(nx/2,*)))(ny/2)
;stop
end


  ia=1
  ib=3 
  ic=2
  sh=43 & ifr=0
  shref=50 & ifrref=0
  db='kcal2015'
  dbref='kcal2015'

 psgn=-1. 
demodtyper='basicnofull2r'
demodtype='basicnofull2b'
psgn2=1.

lam=659.89e-9

doplot=0
cacheread=0
cachewrite=1

   newdemod,imgref,carsr,sh=shref,ifr=ifrref,db=dbref,lam=lam,doplot=doplot,demodtype=demodtyper,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,doload=1,cachewrite=cachewrite,cacheread=cacheread;,/onlyplot

;stop

      newdemod,img,cars,sh=sh,ifr=ifr,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ixi,iy=iyi,p=str,kx=kx,ky=ky,kz=kz,doload=1,cachewrite=cachewrite,cacheread=cacheread

;stop
;
sz=size(cars,/dim)

denom= (abs(cars(*,*,ia))+abs(cars(*,*,ib)))
numer=        abs2(cars(*,*,ic)/carsr(*,*,ic))

circ=0.5*!radeg*atan($
     numer,denom) 


pa=atan2(cars(*,*,ia)/carsr(*,*,ia))
pb=atan2(cars(*,*,ib)/carsr(*,*,ib))
;stop

jumpimgh,pa
jumpimgh,pb

psum=(pa+psgn*pb)/2.
pdif=psgn2*(pa-psgn*pb)/4.


getptsnew,pts=pts,str=str,ix=ix,iy=iy,bin=bin,rarr=rarr,zarr=zarr,cdir=cdir,ang=ang,plane=1

z1=zarr(sz(0)/2,*)
iz0=value_locate(z1,0)
r1=rarr(*,iz0)






l0=656.3
dl=0.
getslope, l0,dl, d1,d2, ph=psumsim
imgplot,psum,/cb,pos=posarr(4,2,0),zr=zr
imgplot,psumsim-4*2*!pi,/cb,zr=zr,pos=posarr(/next),/noer
plot,psum(*,iz0),pos=posarr(/next),/noer
oplot,psumsim(*,iz0)+2*!pi,col=2


getslope2, l0,dl, d1,d2, ph=pdifsim



pcor=(pdif - pdifsim)
imgplot,(pdif)*!radeg,pal=-2,/cb,zr=[-90,90],pos=posarr(/next),/noer,title='raw pol angle'
imgplot,pdifsim*!radeg,pal=-2,/cb,zr=[-90,90],pos=posarr(/next),/noer,title='pol angle correction'
imgplot,(pcor)*!radeg,pal=-2,/cb,zr=[-90,90],pos=posarr(/next),/noer,title='corrected pol angle (sub)'

plot,r1,pcor(*,iz0)*!radeg,pos=posarr(/next),/noer,yr=[-90,90]
oplot,r1,pdif(*,iz0)*!radeg,col=2

;; exp=pdif*!radeg
;; sim=pdifsim*!radeg
;; contourn2,exp,lev=lev,pal=-2,pos=posarr(2,1,0),/iso
;; contour,sim,lev=lev,/overplot,c_lab=replicate(1,100)


;contourn2,(psum)*!radeg,r1,z1,/cb,zr=[-360,360] ;,zr=[-1.5,1.5]*3
;      stop


end
