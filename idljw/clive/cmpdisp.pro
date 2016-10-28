;goto,ee

;sh=[112];77,78,intspace(89,96)]
;shref=113 & ifrref=4 & qwpang0=0

;sh=[119];77,78,intspace(89,96)]
;shref=114 & ifrref=4 & qwpang0=-10


;sh=[116];77,78,intspace(89,96)]
;shref=115 & ifrref=4  & qwpang0=10 

;db='t5sc'
;iimg=4
;   ia=1
;   ib=3
;   ic=2                         ;circ
;nang=9
;psgn=1.



; ia=0
; ib=1 
; ic=2
; sh=[13]
; shref=12 & ifrref=0
; nang=1
; db='t5sd'
; iimg=0

; ia=1
; ib=0 
; ic=2
; sh=[14]
; shref=15 & ifrref=0
; nang=1
; db='t5se'
; iimg=0
;psgn=-1.

; ia=2
; ib=3 
; ic=1
; sh=[18]
; shref=17 & ifrref=0
; nang=1
; db='t5se'
; iimg=0
;psgn=-1.

; ia=2
; ib=3 
; ic=1
; sh=[19]
; shref=20 & ifrref=0
; nang=1
; db='t5se'
; iimg=0
;psgn=-1.

 ia=1
 ib=3 
 ic=2
 sh=[21]
 shref=27 & ifrref=0
 nang=1
 db='t5se'
 iimg=0
psgn=-1.



nsh=n_elements(sh)
np=nsh*nang
sh2=reform( replicate(1,nang) # sh,np)
iarr2=reform((findgen(nang)) # replicate(1,nsh)  ,np)
ash=fltarr(np)
theta0=fltarr(np)
dtheta=fltarr(np)
theta=fltarr(np)
qwpang=fltarr(np); & for i=0,np-1 do qwpang(i)=getc(sh2(i))


demodtype='basic3'
demodtype='basicfull2'

cachewrite=0;1
cacheread=0;1
doplot=1

goto,aa

!p.multi=[0,2,2]
   newdemod,imgref,carsr,sh=24,ifr=ifrref,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/doload,cachewrite=cachewrite,cacheread=cacheread
ia=1
imgplot,abs(carsr(*,*,ia)),/cb

   newdemod,imgref,carsr,sh=25,ifr=ifrref,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/doload,cachewrite=cachewrite,cacheread=cacheread
ia=3
imgplot,abs(carsr(*,*,ia)),/cb


   newdemod,imgref,carsr,sh=26,ifr=ifrref,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/doload,cachewrite=cachewrite,cacheread=cacheread
ia=3
imgplot,abs(carsr(*,*,ia)),/cb


   newdemod,imgref,carsr,sh=27,ifr=ifrref,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/doload,cachewrite=cachewrite,cacheread=cacheread
ia=3
imgplot,abs(carsr(*,*,ia)),/cb


stop
aa:
;simimgnew,imgref,sh=44,db=db,lam=658.89e-9,svec=[2.2,1,1,0.2],/angdeptilt
;sh=12 & db='kcal2015' & ifrref=0 & doplot=1

;sh=26 & db='kcal2015' & ifrref=1 & doplot=1
sh=53 & db='kcalb2015' & ifrref=0 & doplot=1

   newdemod,imgref,carsr,sh=sh,ifr=ifrref,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,doload=1,cachewrite=cachewrite,cacheread=cacheread;,/onlyplot
stop
;   newdemod,imgref,carsr,sh=137,ifr=4,db='t5sf',lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/doload,cachewrite=cachewrite,cacheread=cacheread,/onlyplot

ia=1
;imgplot,abs(carsr(*,*,ia)),/cb

end
