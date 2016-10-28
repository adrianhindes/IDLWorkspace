;sh=8052;3;46
;ifr=155
;sh=8053
;ifr=100



sh=22;22;21;23;22;29;22 ;15   ;phase het
ifr=4
shr=22;25;24;26;25;28;25;19 ; amp het
ifrr=2


db='t5a'
doplot=1
;img=getimgnew(sh,db=db,ifr,info=info,/getinfo,/nostop,/nosubindex,str=str)*1.0

newdemod,img,cars,sh=sh,ifr=ifr,db=db,lam=lam,doplot=doplot,demodtype='basicfull3',ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/doload;,/cachewrite,/cacheread
stop

;imgr=getimgnew(shr,db=db,ifrr,info=info,/getinfo,/nostop,/nosubindex,str=str)*1.0
newdemod,imgr,carsr,sh=shr,ifr=ifrr,db=db,lam=lam,doplot=doplot,demodtype='basicfull3',ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/doload;,/cachewrite,/cacheread

;ang = ifr*10. + (sh - 3) * (-10.)
;angr = ifrr*10. + (shr-3) * (-10.)


ia=2
ib=3

ic=1;circ
p=atan2(cars/carsr)
pa=p(*,*,ia)
pb=p(*,*,ib)

paj=pa
pbj=pb
jumpimgh,paj
jumpimgh,pbj

psum=paj-pbj
pdif=paj+pbj


circ=atan(abs(cars(*,*,ic))/ (2*abs(cars(*,*,ia))) )

polang=pdif/4*!radeg


;pdif = pdif+!pi/2 
ny=n_elements(pdif(0,*))
;plot,pdif(*,ny/2)*!radeg

sz=size(pdif,/dim)
cx=sz(0)/2
cy=sz(1)/2

polangc=polang(cx,cy)
dpolang=polang-polangc

imgplot,dpolang,/cb,pal=-2,pos=posarr(2,1,0)
imgplot,circ,/cb,pos=posarr(/next),/noer

print,'polang c is',polangc
;print,'actual ang is',ang-angr,ang,angr

end

