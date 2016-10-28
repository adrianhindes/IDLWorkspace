;sh=8052;3;46
;ifr=155
;sh=8053
;ifr=100
;goto,ee


sh='overnight_amplitude_insulated_window@0001'
;sh='overnight_amplitude_insulated_window'
shr=sh
ifrr=0

ifr=10
db='t6a'
doplot=0

mult=10

cachewrite=1
cacheread=0

img=getimgnew(sh,db=db,ifrr-20,info=info,/getinfo,/nostop,/nosubindex,str=str)*1.0
nfr=info.num_images
demodtype='basic3'
newdemod,imgr,carsr,sh=shr,ifr=ifrr,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/doload,cacheread=cacheread,cachewrite=cachcwrite

sz=size(carsr,/dim)
psumarr=fltarr(sz(0),sz(1),nfr/mult)
pdifarr=psumarr


for ifr=0,nfr/mult-1 do begin

newdemod,img,cars,sh=sh,ifr=ifr*mult,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/doload,cacheread=cacheread,cachewrite=cachewrite

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

psumarr(*,*,ifr)=psum
pdifarr(*,*,ifr)=pdif

plot,psumarr(sz(0)/2,sz(1)/2,0:ifr)/2*!radeg,pos=posarr(2,1,0)
plot,pdifarr(sz(0)/2,sz(2)/2,0:ifr)/2*!radeg,col=2,pos=posarr(/next),/noer

endfor
ee:
mkfig,'~/stab1b.eps',xsize=13,ysize=10,font_size=9
fx=0.5 & fy=0.5
ix=sz(0)*fx&iy=sz(1)*fy
plot,psumarr(ix,iy,*)/2*!radeg,pos=posarr(2,1,0,cny=0.1),title='0.5*sum phase/deg',xtitle='10s of frames (total ~20 hours?)'
fx=0.25&fy=0.25&oplot,psumarr(sz(0)*fx,sz(1)*fy,*)/2*!radeg
fx=0.25&fy=0.75&oplot,psumarr(sz(0)*fx,sz(1)*fy,*)/2*!radeg
fx=0.75&fy=0.25&oplot,psumarr(sz(0)*fx,sz(1)*fy,*)/2*!radeg
fx=0.75&fy=0.75&oplot,psumarr(sz(0)*fx,sz(1)*fy,*)/2*!radeg

plot,pdifarr(sz(0)/2,sz(2)/2,*)/2*!radeg,col=2,pos=posarr(/next),/noer,title='0.5*dif phase /deg',xtitle='10s of frames'
fx=0.25&fy=0.25&oplot,pdifarr(sz(0)*fx,sz(1)*fy,*)/2*!radeg,col=2
fx=0.25&fy=0.75&oplot,pdifarr(sz(0)*fx,sz(1)*fy,*)/2*!radeg,col=2
fx=0.75&fy=0.25&oplot,pdifarr(sz(0)*fx,sz(1)*fy,*)/2*!radeg,col=2
fx=0.75&fy=0.75&oplot,pdifarr(sz(0)*fx,sz(1)*fy,*)/2*!radeg,col=2




endfig,/gs,/jp
end

