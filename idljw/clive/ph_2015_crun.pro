;sh=8052;3;46
;ifr=155
;sh=8053
;ifr=100

aw=4
sh=3+aw
ifr=aw+2


shr=3
ifrr=0


db='t5a'
doplot=0
;img=getimgnew(sh,db=db,ifr,info=info,/getinfo,/nostop,/nosubindex,str=str)*1.0
newdemod,img,cars,sh=sh,ifr=ifr,db=db,lam=lam,doplot=doplot,demodtype='basicfull3',ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/doload,/cachewrite,/cacheread


;imgr=getimgnew(shr,db=db,ifrr,info=info,/getinfo,/nostop,/nosubindex,str=str)*1.0
newdemod,imgr,carsr,sh=shr,ifr=ifrr,db=db,lam=lam,doplot=doplot,demodtype='basicfull3',ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/doload,/cachewrite,/cacheread

ang = ifr*10. + (sh - 3) * (-10.)
angr = ifrr*10. + (shr-3) * (-10.)


ia=2
ib=3
p=atan2(cars/carsr)
pa=p(*,*,ia)
pb=p(*,*,ib)

paj=pa
pbj=pb
jumpimgh,paj
jumpimgh,pbj

psum=paj-pbj
pdif=(paj+pbj)
polang=pdif/4*!radeg


;pdif = pdif+!pi/2 
ny=n_elements(pdif(0,*))
;plot,pdif(*,ny/2)*!radeg

sz=size(pdif,/dim)
cx=sz(0)/2
cy=sz(1)/2

polangc=polang(cx,cy)
dpolang=polang-polangc

imgplot,dpolang,/cb,pal=-2,zr=[-10,10]

print,'polang c is',polangc
print,'actual ang is',ang-angr,ang,angr

end

