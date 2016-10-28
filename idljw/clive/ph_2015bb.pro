sh0=8052;3;46
ifr0=155
;sh=1615,returned
;ifr=0
;sh=1604 ; hor pol, in korea
;ifr=18
shr=1605 ; vert pol, in korea
ifrr=18


sh=1612 ; hor pol,returned
ifr=0

shr=1604 ; vert hor, in korea
ifrr=18


;shr=1614 ; vert pol, returned
;ifrr=0



doplot=0

img=getimgnew(sh0,ifr0,info=info,/getinfo,/nostop,/nosubindex,str=str,/getflc)*1.0

roi2=[str.roil,    str.roir,    str.roib,    str.roit]

img=getimgnew(sh,ifr,info=info,/getinfo,/nostop,/nosubindex,str=str,/getflc,roi=roi2)*1.0
imgr=getimgnew(shr,ifrr,/nosubindex,roi=roi2,str=strr,/getflc)*1.0



newdemod,imgr,carsr,sh=shr,lam=lam,doplot=doplot,demodtype='basicfull2w',ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/no2load
pr=atan2(carsr)

newdemod,img,cars,sh=sh,lam=lam,doplot=doplot,demodtype='basicfull2w',ix=ix,iy=iy,p=str,kx=kx,ky=ky,kz=kz,/no2load


ia=1
ib=3
p=atan2(cars/carsr)
pa=p(*,*,ia)
pb=p(*,*,ib)

paj=pa
pbj=pb
jumpimgh,paj
jumpimgh,pbj

psum=paj+pbj
pdif=paj-pbj

imgplot,pdif


end


;; stop


;; getptsnew,rarr=r,zarr=z,str=str,ix=ix,iy=iy,pts=pts



;; tmp=getimgnew('Cal_09102012_1',0,info=info,/getinfo,/nostop);.tif and cal_09102012_1_black

;; ;tmpblack=getimgn(...black)
;; ;tmp=tmp-tmpblack



;; ;tmp2=getimgnew(sh,(early time frame),info=info,/getinfo,/nostop);.tif and cal_09102012_1_black


;; ;newdemod, tmp,carscalzeta

;; ;newdemod, tmp2,carscalphase


;; ;cars = cars / abs(carscalzeta)

;; ;cars = cars / ( carscalphse/abs(carcalphase) )

;; ;phase = atan2(cars)
;; ;contrast = abs(cars)



;; ;contourn2,r

;; imgplot,abs(cars(*,*,1)),xsty=1,ysty=1
;; contour,r,xsty=1,ysty=1,/noer,nl=10,c_lab=replicate(1,10)

;; end
