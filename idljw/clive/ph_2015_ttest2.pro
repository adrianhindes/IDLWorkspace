;sh=8052;3;46
;ifr=155
;sh=8053
;ifr=100
;goto,ee


sh=3;w;1\\
;sh='overnight_amplitude_insulated_window'
shr=sh
ifrr=0;18;0 ; 20

ifr=0
db='t5c'
doplot=0

mult=1

cachewrite=1
cacheread=0

img=getimgnew(sh,db=db,ifrr,info=info,/getinfo,/nostop,/nosubindex,str=str)*1.0
;nfr=70-18;info.num_images
nfr=info.num_images
demodtype='basic3'
newdemod,imgr,carsr,sh=shr,ifr=ifrr,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/doload,cacheread=cacheread,cachewrite=cachcwrite

sz=size(carsr,/dim)
psumarr=fltarr(sz(0),sz(1),nfr/mult)
pdifarr=psumarr
zeta=fltarr(sz(0),sz(1),nfr/mult,3)

for ifr=0,nfr/mult-1 do begin

newdemod,img,cars,sh=sh,ifr=ifr+ifrr,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/doload,cacheread=cacheread,cachewrite=cachewrite

ia=2
ib=3

ic=1;circ
p=atan2(cars/carsr)
pa=p(*,*,ia)
pb=p(*,*,ib)

paj=pa
pbj=pb
;jumpimgh,paj
;jumpimgh,pbj

psum=paj-pbj
pdif=paj+pbj

;psum=paj*2
;pdif=pbj*2
krn=fltarr(3,3)+1./9.

psumarr(*,*,ifr)=convol(psum,krn)
pdifarr(*,*,ifr)=convol(pdif,krn)
zeta(*,*,ifr,0)=convol(abs(cars(*,*,ia)),krn)
zeta(*,*,ifr,1)=convol(abs(cars(*,*,ib)),krn)
zeta(*,*,ifr,2)=convol(abs(cars(*,*,ic)),krn)

plot,psumarr(sz(0)/2,sz(1)/2,0:ifr)/2*!radeg,pos=posarr(3,1,0)
plot,pdifarr(sz(0)/2,sz(1)/2,0:ifr)/2*!radeg,col=2,pos=posarr(/next),/noer
plot,zeta(sz(0)/2,sz(1)/2,0:ifr,0),col=3,pos=posarr(/next),/noer
oplot,zeta(sz(0)/2,sz(1)/2,0:ifr,1),col=4
oplot,zeta(sz(0)/2,sz(1)/2,0:ifr,2),col=5


endfor
ee:
mkfig,'~/stab1c.eps',xsize=13,ysize=10,font_size=9
fx=0.5 & fy=0.5
ix=sz(0)*fx&iy=sz(1)*fy
plot,psumarr(ix,iy,*)/2*!radeg,pos=posarr(2,1,0,cny=0.1),title='0.5*sum phase/deg',xtitle='10s of frames (total ~20 hours?)'
fx=0.25&fy=0.25&oplot,psumarr(sz(0)*fx,sz(1)*fy,*)/2*!radeg
fx=0.25&fy=0.75&oplot,psumarr(sz(0)*fx,sz(1)*fy,*)/2*!radeg
fx=0.75&fy=0.25&oplot,psumarr(sz(0)*fx,sz(1)*fy,*)/2*!radeg
fx=0.75&fy=0.75&oplot,psumarr(sz(0)*fx,sz(1)*fy,*)/2*!radeg

plot,pdifarr(sz(0)/2,sz(1)/2,*)/2*!radeg,col=2,pos=posarr(/next),/noer,title='0.5*dif phase /deg',xtitle='10s of frames'
fx=0.25&fy=0.25&oplot,pdifarr(sz(0)*fx,sz(1)*fy,*)/2*!radeg,col=2
fx=0.25&fy=0.75&oplot,pdifarr(sz(0)*fx,sz(1)*fy,*)/2*!radeg,col=2
fx=0.75&fy=0.25&oplot,pdifarr(sz(0)*fx,sz(1)*fy,*)/2*!radeg,col=2
fx=0.75&fy=0.75&oplot,pdifarr(sz(0)*fx,sz(1)*fy,*)/2*!radeg,col=2




endfig,/gs,/jp
end

