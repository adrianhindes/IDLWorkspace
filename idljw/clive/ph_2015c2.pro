sh='wltesta';8053;46
ifr=100

doplot=0

lam=659.89e-9 ;529e-9
simimgnew,imgr,sh=sh,lam=lam,svec=[2,1,1,0]

newdemod,imgr,carsr,sh=sh,lam=lam,doplot=doplot,demodtype='basicfull',ix=ix,iy=iy,p=str,kx=kx,ky=ky,kz=kz
pr=atan2(carsr)

;stop
;imgplot,img
;stop
shr=1615

;img=getimgnew(shr,0,/nosubindex)*1.0

lam2=659.89e-9
sh2='wltestb'

simimgnew,img,sh=sh2,lam=lam2,svec=[2,1,1,0]

;img=getimgnew(sh,ifr,info=info,/getinfo,/nostop,/nosubindex)*1.0


newdemod,img,cars,sh=sh,lam=lam,doplot=doplot,demodtype='basicfull',ix=ix,iy=iy,p=str,kx=kx,ky=ky,kz=kz


ia=1
ib=3
p=atan2(cars/carsr)
pa=p(*,*,ia)
pb=p(*,*,ib)

paj=pa
pbj=pb
jumpimg,paj
jumpimg,pbj


psum=paj+pbj
pdif=paj-pbj

imgplot,pdif,/cb,pal=-2,pos=posarr(2,1,0),title='pdif'
imgplot,psum,/cb,pal=-2,pos=posarr(2,1,1),title='psum',/noer

end

