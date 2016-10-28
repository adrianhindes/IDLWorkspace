sh=8052;3;46
ifr=155
sh=8053
ifr=100
doplot=0
shr=1605
ifrr=18
img=getimgnew(sh,ifr,info=info,/getinfo,/nostop,/nosubindex,str=str,/getflc)*1.0
idx=where(long(img) eq 65535L) 
if idx(0) ne -1 then img(idx)=0.
roi2=[str.roil,    str.roir,    str.roib,    str.roit]



imgr=getimgnew(shr,ifrr,/nosubindex,roi=roi2,str=strr,/getflc)*1.0


newdemod,imgr,carsr,sh=shr,lam=lam,doplot=doplot,demodtype='basicfull2w',ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/no2load
pr=atan2(carsr)

;stop
;imgplot,img
;stop



newdemod,img,cars,sh=sh,lam=lam,doplot=doplot,demodtype='basicfull2',ix=ix,iy=iy,p=str,kx=kx,ky=ky,kz=kz,/no2load


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
