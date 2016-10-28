@getslopeg
pro do2015a, sh, db=db,typ=typ,calib_offset=calib_offset,noplot=noplot
;typ='cal3'
;'shself';'cal1'
default,typ,'shcala'


sh=13212


  ia=1
  ib=3 
  ic=2
;  sh=13147 & ifr=0
;sh=13182 & ifr=0
;sh=13186 & ifr=0
zrd=[-360,360]
refmethod='no'

if typ eq 'shself' then begin
sh=13188 & ifr=0 &db='kl' & shref=sh & ifrref=0 & dbref='kcall' & calib_offset=30.*!dtor & psumsim_off=2*!pi
l0=660.7
dl=-0.8;1.0
ang=7*!dtor
;l0=661.0
demodtyper='basicnofull2r'
demodtype='basicnofull2b'
zr=[-90,90]
endif

if typ eq 'shselfa' then begin
ifr=0 &db='kl' & shref=sh & ifrref=0 & dbref='kcall' & calib_offset=-56.*!dtor+90*!dtor & psumsim_off=2*!pi
l0=660.4
dl=-0.8;1.0
ang=7*!dtor
;l0=661.0
demodtyper='basicnofull2r'
demodtype='basicnofull2b'
zr=[-45,45]
zrcirc=[-20,20]
refmethod='yes'
endif

default,  calib_offset, 0.*!dtor
if typ eq 'shcala' then begin
ifr=0
 default,db,'kl'

shref=80 & ifrref=0+6*2 + 6*2 & dbref='kcal2015'  & psumsim_off=2*!pi
l0=660.4
dl=-0.8;1.0
ang=7*!dtor
;l0=661.0
demodtyper='basicnofull2r'
demodtype='basicnofull2b'
zr=[-90,90]
refmethod='yes'
endif

if typ eq 'drifta' then begin
 ifr=0 
default,db,'kcall' 
shref = 50 & ifrref=0 & dbref='kcal2015'
psumsim_off=0.
;shref=80 & ifrref=0+6*2 + 6*2 & dbref='kcal2015'  & psumsim_off=2*!pi
l0=659.89
dl=0.;1.0
ang=0*!dtor
;l0=661.0
demodtyper='basicnofull2r'
demodtype='basicnofull2r'
zr=[-90,90]
refmethod='yes'
endif




;  db='kl'
;  sh=13188 & ifr=0 &   db='kcall'
;  shref=13184 & ifrref=0 &   dbref='kcall'
;  shref=13146 & ifrref=0 &   dbref='kcall' & calib_offset=20.*!dtor

;sh = 82 & ifr = 1 + 2*25 & db='kcal2015'  & l0=659.89 & dl=0. & ang=0.
;sh=13147 & ifr=0 & db='kcall' & clib_offset=0. * !dtor
;  shref=82 & ifrref=1+2*15 & dbref='kcal2015'    &calib_offset=-30*!dtor

;  shref=80 & ifrref=1+2*6+2*18  & dbref='kcal2015'    &calib_offset=60*!dtor

;  shref=80 & ifrref=0+2*6+2*9  & dbref='kcal2015'    &calib_offset=60*!dtor

;calib_offset=0.
;psumsim_off=2*!pi

if typ eq 'cal1' then begin
shref=67 & ifrref = 1+6*2 & dbref='kcal2015'  
sh = 70 & ifr=1+10*2 & db='kcal2015'
calib_offset=0.
l0=659.89 & dl=0 & ang=0. & psumsim_off=0.
demodtyper='basicnofull2r'
demodtype='basicnofull2b'
zr=[0,30]
zrd=[-200,0]
endif

if typ eq 'cal2' then begin
shref=67 & ifrref = 1+6*2 & dbref='kcal2015'  
;shref=64 & ifrref = 1+10*2 & dbref='kcal2015'  
sh = 40*0+53 & ifr=0 & db='kcal2015'
calib_offset=0.
l0=659.89 & dl=0 & ang=0. & psumsim_off=0.
demodtyper='basicnofull2bg'
demodtype='basicnofull2b'
zr=[-30,30]
endif

if typ eq 'cal2a' then begin
;shref=70 & ifrref = 0+10*2 & dbref='kcal2015'  
sh=67 & ifr = 0+4*2 & db='kcal2015'   ; 0 deg

;sh=66 & ifr = 0+4*2 & db='kcal2015'   ; 5 deg
;sh=63 & ifr=
;sh=64 & ifr = 0+10*2 & db='kcal2015'  
shref = 40*0+53+1 & ifrref=0 & dbref='kcal2015'
calib_offset=0.
l0=659.89 & dl=0 & ang=0. & psumsim_off=0.
demodtyper='basicnofull2bg'
demodtype='basicnofull2b'
zr=[0,45]
zrcirc=[-30,30]
zrd=[0,100]
endif

if typ eq 'cal3' then begin
shref=70 & ifrref = 1+10*2 & dbref='kcal2015'  
sh = 40 & ifr=0 & db='kcal2015'
calib_offset=0.
l0=659.89 & dl=0 & ang=0. & psumsim_off=0.
demodtyper='basicnofull2bg'
demodtype='basicnofull2b'
zr=[-30,30]*3
endif


if typ eq 'cal3a' then begin
sh=70 & ifr = 0+10*2 & db='kcal2015'  
;shref=67 & ifrref = 0+6*2 & dbref='kcal2015'  
;shref=64 & ifrref = 1+10*2 & dbref='kcal2015'  
shref = 40*0+53+1 & ifrref=0 & dbref='kcal2015'
calib_offset=-56*!dtor
l0=659.89 & dl=0 & ang=0. & psumsim_off=0.
demodtyper='basicnofull2bg'
demodtype='basicnofull2b'
zr=[-90,90]
zrcirc=[-30,30]
zrd=[0,100]
endif

if typ eq 'cal3b' then begin
shref=70 & ifrref = 1+10*2 & dbref='kcal2015'  
sh = 71 & ifr=1+7*2 & db='kcal2015'
calib_offset=0.
l0=659.89 & dl=0 & ang=0. & psumsim_off=0.
demodtyper='basicnofull2bg'
demodtype='basicnofull2b'
zr=[-30,30]/3
endif

if typ eq 'cal3c' then begin
shref=80 & ifrref = 1+6*2 & dbref='kcal2015'  
sh = 79 & ifr=1+4*2 & db='kcal2015'
calib_offset=0.
l0=659.89 & dl=0 & ang=0. & psumsim_off=0.
demodtyper='basicnofull2bg'
demodtype='basicnofull2b'
zr=[-5,5]
endif

if typ eq 'cal3ca' then begin
shref=80 & ifrref = 0+6*2 & dbref='kcal2015'  
sh = 79 & ifr=0+4*2 & db='kcal2015'
calib_offset=0.
l0=659.89 & dl=0 & ang=0. & psumsim_off=0.
demodtyper='basicnofull2bg'
demodtype='basicnofull2b'
zr=[-5,5]
refmethod='yes'
zrcirc=[-5,5]
endif

if typ eq 'cal4' then begin
shref=70 & ifrref = 1+10*2 & dbref='kcal2015'  
sh = 64 & ifr=1+10*2 & db='kcal2015'
calib_offset=0.
l0=659.89 & dl=0 & ang=0. & psumsim_off=0.
demodtyper='basicnofull2bg'
demodtype='basicnofull2b'
zr=[-30,30]
endif

if typ eq 'cal4a' then begin
;sh = 64 & ifr=0+10*2 & db='kcal2015'
sh=70 & ifr = 0+10*2 & db='kcal2015'  
shref = 67 & ifrref=0+6*2 & dbref='kcal2015'
calib_offset=0.
l0=659.89 & dl=0 & ang=0. & psumsim_off=0.
demodtyper='basicnofull2bg'
demodtype='basicnofull2bg'
zr=[-30,30]
endif


 psgn=-1. 
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
carsr2 = carsr / abs(carsr)

denom= (abs(cars(*,*,ia))+abs(cars(*,*,ib)))
if refmethod eq 'no' then numer=        abs(cars(*,*,ic));/carsr2(*,*,ic))



denom2= (abs(carsr(*,*,ia))+abs(carsr(*,*,ib)))
numer2=        abs(carsr(*,*,ic));/carsr(*,*,ic))

circr=0.5*!radeg*atan($
     numer2,denom2) 


pa=atan2(cars(*,*,ia)/carsr(*,*,ia))
pb=atan2(cars(*,*,ib)/carsr(*,*,ib))
;stop

jumpimgh,pa
jumpimgh,pb

psum=(pa+psgn*pb)/2.
pdif=psgn2*(pa-psgn*pb)/4. - calib_offset






getptsnew,pts=pts,str=str,ix=ix,iy=iy,bin=bin,rarr=rarr,zarr=zarr,cdir=cdir,ang=ang1,plane=1

z1=zarr(sz(0)/2,*)
iz0=value_locate(z1,0);sz(1)/2
;
r1=rarr(*,iz0)






;l0=661.3
;l0=660.9
;mkfig,'~/a1.eps',xsize=28,ysize=21,font_size=9
getslopeg, l0,dl, d1,d2, ph=psumsim,which='displacer',ang=ang
imgplot,psum*!radeg,/cb,pos=posarr(3,3,0),zr=zrd,title='raw doppler phase'
imgplot,(psumsim+psumsim_off)*!radeg,/cb,zr=[-360,360],pos=posarr(/next),/noer,title='doppler phase model'
plot,psum(*,iz0)*!radeg,pos=posarr(/next),/noer,title='compare meas,model doppler ph',yr=zrd
oplot,(psumsim(*,iz0)+psumsim_off)*!radeg,col=2


getslopeg, l0,dl, d1,d2, ph=pdifsim,which='savart',ang=ang


pref=-psumsim+2*!pi
pcar=exp(complex(0,1)*pref)
if refmethod eq 'yes' then begin
   numer=        abs2(cars(*,*,ic)/carsr2(*,*,ic)/pcar)
endif
circ=0.5*!radeg*atan($
     numer,denom) 


pcor=(pdif - pdifsim) 
imgplot,(pdif)*!radeg,pal=-2,/cb,zr=zr,pos=posarr(/next),/noer,title='raw pol angle'
imgplot,pdifsim*!radeg,pal=-2,/cb,zr=zr,pos=posarr(/next),/noer,title='pol angle correction'
imgplot,(pcor)*!radeg,pal=-2,/cb,zr=zr,pos=posarr(/next),/noer,title='corrected pol angle (sub)'

plot,pcor(*,iz0)*!radeg,pos=posarr(/next),/noer,yr=zr,title='compare profile of corrected(wt), uncorrected(red) pol angle'
oplot,pdif(*,iz0)*!radeg,col=2
oplot,!x.crange,[0,0],linesty=3
imgplot,circ,/cb,pos=posarr(/next),/noer,title='circ (deg)',pal=-2,zr=zrcirc

plot,circ(*,iz0),title='profiles of circ (deg)',pos=posarr(/next),/noer,yr=zrcirc
oplot,!x.crange,[0,0],linesty=2
;imgplot,circr,/cb,pos=posarr(/next),/noer,title='circ ref (deg)'
;contourn2,(psum)*!radeg,r1,z1,/cb,zr=[-360,360] ;,zr=[-1.5,1.5]*3
;      stop

txt=string(sh,ifr,db,shref,ifrref,dbref,l0,dl,calib_offset,format='("sh=",I0,"/",I0,";",A," shref=",I0,"/",I0,";",A," l0=",G0," dl=",G0,"offset=",G0)')
xyouts,0.5,0.97,txt,/norm,ali=0.5



endfig,/gs,/jp
stop
end
