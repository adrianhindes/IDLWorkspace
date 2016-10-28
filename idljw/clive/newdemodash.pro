pro newdemodash,sh, ifr, only2=only2p, eps=eps,angt=ang,dop1=dop1,dop2=dop2,doplot=doplot,cacheread=cacheread,cachewrite=cachewrite,dop3=dop3,dopc=dopc,dostop=dostop,ang0=ang0,pp=str,str=none,sd=sd,noload=noload,vkz=vkz,lin=lin,inten=inten,ix=ix,iy=iy,plotcar=plotcar,cix=cix,ciy=ciy,only1=only1,cars=cars,istata=istata,demodtype=demodtype,noid2=noid2,db=db,multiplier=multiplier,remember=remember,filter=filter
default,only2p,0
default,only1,0
;;;;;;;;;;;;;;;;;;


;@getslopeg

  ia=1
  ib=3 
  ic=2

db='k' & shref=sh & ifrref=0 & dbref='kcal' & calib_offset=0 & psumsim_off=2*!pi ; -56.*!dtor+90*!dtor

if sh ge 13493 and sh le 99999 then shref=13492
default,filter,0
default,l0,660.9;7
default,dl,-0.8;1.0
ang=7*!dtor
;l0=661.0
demodtyper='basicnofull2r'
demodtype='basicnofull2b'
refmethod='yes'

 psgn=-1. 
psgn2=1.

lam=659.89e-9

doplotb=0
default,cacheread,0
cachewrite=1

common cbremember, imgref, carsr,psumsim, rarr,zarr
imgref=getimgnew(shref,ifrref,db=dbref)
if not keyword_set(remember) then    newdemod,imgref,carsr,sh=shref,ifr=ifrref,db=dbref,lam=lam,doplot=doplotb,demodtype=demodtyper,ix=ixi,iy=iyi,p=strr,kx=kx,ky=ky,kz=kz,doload=0,cachewrite=cachewrite,cacheread=cacheread;,/onlyplot

;stop
img=getimgnew(sh,ifr,db=db,filter=filter,str=str)

time=str.t0 + ifr * str.dt
      newdemod,img,cars,sh=sh,ifr=ifr,db=db,lam=lam,doplot=doplotb,demodtype=demodtype,ix=ix,iy=iy,p=str,kx=kx,ky=ky,kz=kz,doload=0,cachewrite=cachewrite,cacheread=cacheread

;stop
;
sz=size(cars,/dim)
carsr2 = carsr / abs(carsr)

denom= (abs(cars(*,*,ia))+abs(cars(*,*,ib)))

pa=atan2(cars(*,*,ia)/carsr(*,*,ia))
pb=atan2(cars(*,*,ib)/carsr(*,*,ib))
;stop

;jumpimg,pa
;jumpimg,pb

psum=(pa+psgn*pb)/2.
if not keyword_set(remember) then getslopeg, l0,dl, d1,d2, ph=psumsim,which='displacer',ang=ang

pdif=psgn2*(pa-psgn*pb)/4. - calib_offset

;if not keyword_set(remember) then getptsnew,pts=pts,str=str,ix=ix,iy=iy,bin=bin,rarr=rarr,zarr=zarr,cdir=cdir,ang=ang1,plane=1

;z1=zarr(sz(0)/2,*)
;iz0=value_locate(z1,20);sz(1)/2
;
;r1=rarr(*,iz0)



pref=-psumsim
pcar=exp(complex(0,1)*pref)
   numer=        abs2(cars(*,*,ic)/carsr2(*,*,ic)/pcar)
ang=0.5*!radeg*atan($
     numer,denom) 
dop1=psum
eps=pdif
dop2=dop1
dopc=dop1
dop3=dop1
inten=abs(cars(*,*,0))
lin1=abs(cars(*,*,ia))/abs(cars(*,*,0))
linr=abs(carsr(*,*,ia))/abs(carsr(*,*,0))
lin1=lin1/linr

lin2=abs(cars(*,*,ic))/abs(cars(*,*,0))
lin2r=abs(carsr(*,*,ic))/abs(carsr(*,*,0))
lin2=lin2/lin2r

lin=sqrt(lin1^2+lin2^2)




if keyword_set(doplot) then begin
print,'should be ang0=',ang(sz(0)/2,sz(1)/2)
default,ang0,0
imgplot,(ang-ang0),/cb,pal=-2,zr=[-10,10],pos=posarr(2,2,0)
;imgplot,eps,/cb,zr=[-10,10],pal=-2,pos=posarr(/next),/noer
;imgplot,abs(svec2(*,*,0)),/cb,pos=posarr(/next),/noer
imgplot,dopc,/cb,pos=posarr(/next),/noer
;imgplot,dop2,/cb,pos=posarr(/next),/noer
imgplot,lin,/cb,pos=posarr(/next),/noer,zr=[0,.7]
;stop
endif
;stop

;if keyword_set(only1) then stop
if keyword_set(dostop) then stop


end



;newdemodflcshot,7426,[1.,2.],res=res;
;end

; common cbshot, shotc,dbc,isconnected
; shotc=sh
; dbc='kstar'
; nbi1=cgetdata('\NB11_VG1');\NB11_I0')
; ;nbi2=cgetdata('\NB12_I0')
; plot,t,dop2,/yno,pos=posarr(1,2,0),yr=[-180,180]
; oplot,t,dop2-180,col=3
; oplot,t,dop3,col=4
; vs=smooth(nbi1.v,200)
; plot,nbi1.t,vs,xr=!x.crange,xsty=1,/noer,/yno,col=2,pos=posarr(/next)

; end

;newdemodflc,7358, 40,/doplot,/dostop,/only2,ang0=-5;-5 john
;newdemodflc,7483, 82,/doplot,/dostop,/only2,ang0=0+10;0 john
;newdemodflc,7484, 92,/doplot,/dostop,/only2,ang0=-10+14;-10john
;newdemodflc,7690, 60,/doplot,/dostop,/only2,ang0=-10+12;-10
;newdemodflc,7688, 80,/doplot,/dostop,/only2,ang0=+10+12;+10
;newdemodflc,7695, 94,/doplot,/dostop,/only2,ang0=-20+12;-20
;newdemodflc,7696, 160,/doplot,/dostop,/only2,ang0=-30+90+12;-20

;bch

;end


;    -23.1555
;      102.722
;      85.3442

