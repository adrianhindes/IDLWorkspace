sh=8053;46
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

lam2=661.5e-9
simimgnew,img,sh=sh,lam=lam2,svec=[2,1,1,0]

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
