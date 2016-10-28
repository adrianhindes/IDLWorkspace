function getc,sh1
sh=[intspace(136,140),117,119,77,79,142,150,17,26,65,70,80,82,67,66]
ang=[0,-10,-20,10,20,0,-10,0,-10,0,20,-26,-80,-30,20,0,0,-30+90-4,-30]
iw=value_locate3(sh,sh1)
if sh(iw) eq sh1 then return,ang(iw) else return,0
end

;goto,ee

;sh=[112];77,78,intspace(89,96)]
;shref=113 & ifrref=4 & qwpang0=0

;sh=[119];77,78,intspace(89,96)]
;shref=114 & ifrref=4 & qwpang0=-10
psgn2=1.
;seq='sat1';'new4';'sat1'
;seq='new2' ; first incarnation of fw savarta
;seq='new1' ; system as it was about to go on thursday night
;seq='new4' ; last one on friday

;seq='sun1'
seq='67b'
seq='82'
seq='90020'
seq='90021'

seq='65'
sim=0

;seq='old_today'
;demodtype='basicfull3'
demodtype='basicfull2'
demodtype='basicfull2g'

cachewrite=1
cacheread=0
doplot=0



if n_elements(angstep2) ne 0 then tmp=temporary(angstep2)
if seq eq 'old2' then begin
sh=[79];77,78,intspace(89,96)]
shref=77 & ifrref=4  
;sh=[104]
;shref=104 & ifrref=4
db='t5a'
iimg=4
   ia=3
   ib=2
   ic=1                         ;circ
nang=9
psgn=-1.
psgn2=-1.
endif

if seq eq 'old' then begin
sh=[117];77,78,intspace(89,96)]
shref=117 & ifrref=4  
;sh=[104]
;shref=104 & ifrref=4
db='t5sc'
iimg=4
   ia=1
   ib=3
   ic=2                         ;circ
nang=9
psgn=1.
endif



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

if seq eq 'old_today' then begin
ia=2
ib=3 
ic=1
sh=[18]
shref=17 & ifrref=0
nang=1
db='t5se'
iimg=0
psgn=-1.
endif

if seq eq 'old3' then begin
  ia=2
  ib=0 
  ic=1
  sh=[19]
  shref=20 & ifrref=0
  nang=1
  db='t5se'
  iimg=0
 psgn=-1.
endif

;   ia=1
;;   ib=3 
;;   ic=2
;;   sh=[21]
;;   shref=22 & ifrref=0
;;   nang=1
;;   db='t5se'
;;   iimg=0
;;  psgn=-1.

 ;;  ia=0
 ;;  ib=2 
 ;;  ic=1
 ;;  sh=[41]
 ;;  shref=42 & ifrref=0
 ;;  nang=1
 ;;  db='t5se'
 ;;  iimg=0
 ;; psgn=1.

if seq eq 'new1' then begin
  ia=2
  ib=0 
  ic=1
  sh=[136]
  shref=136 & ifrref=4
  nang=9
  db='t5sf'
  iimg=4
 psgn=1. 
endif


if seq eq 'new2' then begin
  ia=6
  ib=7 
  ic=2
  sh=[142]
  shref=142 & ifrref=4
  nang=9
  db='t5sf'
  iimg=4
 psgn=-1. 
demodtype='basicfull2g'
psgn2=-1.
endif

if seq eq 'new2c' then begin
  ia=6
  ib=7 
  ic=2
  sh=[46]
  shref=47 & ifrref=0
  sh=[49]
  shref=50 & ifrref=0
  nang=1
  db='t5se'
  iimg=0
 psgn=-1. 
demodtype='basicfull2b'
psgn2=-1.
endif

if seq eq 'new3c' then begin
  ia=6
  ib=7 
  ic=2
  sh=[53]
  shref=54 & ifrref=0
  nang=1
  db='t5se'
  iimg=0
 psgn=-1. 
demodtype='basicfull2b'
psgn2=-1.
endif

if seq eq 'new3' then begin
  ia=0
  ib=1 
  ic=2
  sh=[148]
  shref=148 & ifrref=4
  nang=9
  db='t5sf'
  iimg=0
 psgn=-1. 
demodtype='basicfull2bg'
psgn2=-1.
endif

if seq eq 'new4' then begin
  ia=1
  ib=0 
  ic=2
  sh=[150]
  shref=150 & ifrref=4
  nang=9
  db='t5sf'
  iimg=0
 psgn=-1. 
;demodtype='basicfull2g'
demodtype='basicnofull2'
psgn2=1.
endif

if seq eq 'sat1' then begin
  ia=1
  ib=0 
  ic=2
  sh=[17]
  shref=17 & ifrref=1+2*13
  startref=1
  angstep2=2.
  nang=45;26
  db='kcal2015'
  iimg=0
 psgn=-1. 
demodtype='basicnofull2'
psgn2=1.
endif

if seq eq 'sun1' then begin
  ia=1
  ib=3 
  ic=2
  sh=[26]
  shref=26 & ifrref=1+2*16
  startref=1
  ;angstep2=2.
  nang=18;4;26
  db='kcal2015'
  iimg=0
 psgn=-1. 
demodtype='basicnofull2'
psgn2=1.
endif

if seq eq '65' then begin
  ia=1
  ib=3 
  ic=2
  sh=[65]
  shref=65 & ifrref=1+2*15
  startref=1
  angstep2=2.
  nang=30;4;26
  db='kcal2015'
  iimg=0
 psgn=-1. 
demodtype='basicnofull2'
psgn2=1.
endif

if seq eq '67' then begin
  ia=1
  ib=3 
  ic=2
  sh=[67]
  shref=67 & ifrref=1+2*6
  startref=1
  angstep2=5.
  nang=13;4;26
  db='kcal2015'
  iimg=0
 psgn=-1. 
demodtype='basicnofull2'
psgn2=1.
endif

if seq eq '67b' then begin
  ia=1
  ib=3 
  ic=2
  sh=[67]
  shref=49 & ifrref=0
  startref=1
  angstep2=5.
  nang=13;4;26
  db='kcal2015'
  iimg=0
 psgn=-1. 
demodtype='basicnofull2'
psgn2=1.
endif

if seq eq '66' then begin
  ia=1
  ib=3 
  ic=2
  sh=[66]
  shref=66 & ifrref=1+2*6
  startref=1
  angstep2=5.
  nang=13;4;26
  db='kcal2015'
  iimg=0
 psgn=-1. 
demodtype='basicnofull2'
psgn2=1.
endif

if seq eq '70' then begin
  ia=1
  ib=3 
  ic=2
  sh=[70]
  shref=70 & ifrref=1+2*10
  startref=1
  angstep2=-2.
  nang=20;4;26
  db='kcal2015'
  iimg=0
 psgn=-1. 
demodtype='basicnofull2'
psgn2=1.
endif
if seq eq '80' then begin
  ia=1
  ib=3 
  ic=2
  sh=[80]
  shref=80 & ifrref=1+2*0
  startref=1
  angstep2=-5.
  nang=37;4;26
  db='kcal2015'
  iimg=0
 psgn=-1. 
demodtype='basicnofull2'
psgn2=1.
endif

if seq eq '82' then begin
  ia=1
  ib=3 
  ic=2
  sh=[82]
  shref=82 & ifrref=1+2*0
  startref=1
  angstep2=-2.
  nang=31;4;26
  db='kcal2015'
  iimg=0
 psgn=-1. 
demodtype='basicnofull2'
psgn2=1.
endif

if seq eq '90020' then begin
  ia=1
  ib=3 
  ic=2
  sh=[90020]
  shref=90020 & ifrref=1+2*0
  startref=1
  angstep2=-2.
  nang=21;4;26
  db='kcal2015'
  iimg=0
 psgn=-1. 
demodtype='basicnofull2'
psgn2=1.
endif

if seq eq '90021' then begin
  ia=1
  ib=3 
  ic=2
  sh=[90021]
  shref=90021 & ifrref=1+2*0
  startref=1
  angstep2=-2.
  nang=6;21;4;26
  db='kcal2015'
  iimg=0
 psgn=-1. 
demodtype='basicnofull2'
psgn2=1.
endif



nsh=n_elements(sh)
np=nsh*nang
sh2=reform( replicate(1,nang) # sh,np)
iarr2=reform((findgen(nang)) # replicate(1,nsh)  ,np)
if n_elements(startref) ne 0  then $
   iarr2 = reform(((startref+2*findgen(nang))) # replicate(1,nsh)  ,np)
ash=fltarr(np)
theta0=fltarr(np)
dtheta=fltarr(np)
theta=fltarr(np)
qwpang=fltarr(np) & for i=0,np-1 do qwpang(i)=getc(sh2(i))





if sim eq 1 then simimgnew,imgref,sh=shref,db=db,lam=656.3e-9,svec=[2.2,1,1,.2],/angdeptilt
   newdemod,imgref,carsr,sh=shref,ifr=ifrref,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,doload=sim eq 0,cachewrite=cachewrite,cacheread=cacheread;,/onlyplot
stop

;carsr=carsr/abs(carsr)
sz=size(carsr,/dim)
cstore=complexarr(sz(0),sz(1),sz(2),np)
pastore=fltarr(sz(0),sz(1),np)
pbstore=pastore
psumarr=pastore
pdifarr=pastore


for i=0,nsh-1 do begin
   img=getimgnew(sh(i),db=db,0,info=info,/getinfo,/nostop,/nosubindex,str=str)*1.0; & info={theta0:0,flipper:0,angstep:0}
   for j=0,nang-1 do begin
      k=i*nang + j
      if istag(info,'theta0') then theta0(k)=info.theta0
;      ash(k)=info.flipper
      if istag(info,'angstep') then      dtheta(k)=info.angstep
      if n_elements(angstep2) ne 0 then dtheta(k)=angstep2
      theta(k)=theta0(k) + iarr2(k) * dtheta(k)
      if n_elements(startref) ne 0  then $
      theta(k)=theta0(k) + j * dtheta(k)
         

;img=getimgnew(sh,db=db,ifr,info=info,/getinfo,/nostop,/nosubindex,str=str)*1.0

if sim eq 1 then simimgnew,img,sh=shref,db=db,lam=659.8e-9,svec=[2.2,1,1,.2],/angdeptilt

      newdemod,img,cars,sh=sh2(k),ifr=iarr2(k),db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ixi,iy=iyi,p=strr,kx=kx,ky=ky,kz=kz,doload=sim eq 0,cachewrite=cachewrite,cacheread=cacheread

      
;      denom= (abs(cars(*,*,ia))+abs(cars(*,*,ib)))
;      numer=        abs2(cars(*,*,ic)/carsr(*,*,ic))
      
;      circ=0.5*!radeg*atan($
;           numer,denom) 
      cstore(*,*,*,k)=cars

      pa=atan2(cars(*,*,ia)/carsr(*,*,ia))
      pb=atan2(cars(*,*,ib)/carsr(*,*,ib))
      jumpimg,pa
      jumpimg,pb
      pastore(*,*,k)=pa
      pbstore(*,*,k)=pb
      psumarr(*,*,k)=(pastore(*,*,k)+psgn*pbstore(*,*,k))/2.
      pdifarr(*,*,k)=psgn2*(pastore(*,*,k)-psgn*pbstore(*,*,k))/4.
;      stop
      contourn2,(pdifarr(*,*,k)-1*pdifarr(sz(0)/2,sz(1)/2,k))*!radeg,pal=-2,title=k,/cb,zr=[-1.5,1.5]*3
;      stop
;      a='' & read,a
      if j eq nang/2 then stop
   endfor
endfor



ee:
tmp=pdifarr(sz(0)/2,sz(1)/2,*)
tmp2=phs_jump(tmp*4)/4*!radeg
wset2,0
thetap=theta + qwpang
mkfig,'~/rotscan.eps',xsize=24,ysize=18
plot,thetap,tmp2,pos=posarr(2,1,0)


oplot,thetap,thetap,col=2
plot,thetap,tmp2-thetap,pos=posarr(/next),/noer,yr=[-2,2]
endfig,/gs,/jp
stop
;a='' & read,a
for i=0,sz(0)-1,3 do for j=0,sz(1)-1,3 do begin
   tmp=pdifarr(i,j,*)
   tmp2=phs_jump(tmp*4)/4*!radeg
   oplot,thetap,tmp2+thetap,col=j
endfor

wset2,1

;imgplot,pdifarr(*,*,4)*!radeg,/cb,pal=-2 
;imgplot,pdifarr(*,*,iimg)*!radeg,/cb,pal=-2 
end





