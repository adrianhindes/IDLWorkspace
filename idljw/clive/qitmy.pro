lam=529e-9

;Contrast (zeta) correction - using calibration file
calblack='Cal_13102012_1400x1440_black';'edge_cal_black'
calzeta='Cal_13102012_1400x1440';'Cal_13102012_max';'edge_cal';7231;7260;74;8;l74;94;88;74

calblackimg=getimgnew(calblack,0,info=info,/getinfo,/nostop)*1.0


calzetaimg=getimgnew(calzeta,0,info=info,/getinfo,/nostop)*1.0
;Cal dark correction
calzetaimg=calzetaimg-calblackimg
newdemod, calzetaimg,carscalzeta,sh=calzeta,lam=lam,demodtype='basic',ix=ix,iy=iy,p=str;noplot
;stop
;Shot and frame input here
sh=7335;7262;7260;'edge_cal';7231;7260;74;8;l74;94;88;74

darkframe=0
startframe=1
refframe=10
if sh EQ 7262 then refframe=8
if sh EQ 7335 then refframe=40

;Phase correction
shimgdark=getimgnew(sh,darkframe,info=info,/getinfo,/nostop)*1.0
shimgref=getimgnew(sh,refframe)*1.0
shimgref=shimgref-shimgdark
newdemod,shimgref,carscalphase,sh=sh,lam=lam,demodtype='basic',ix=ix,iy=iy,p=str;no /doplot

gencarriers,th=[0,0],sh=sh,kx=kx,ky=ky,kz=kz,lam=lam

frame=50
shimg=getimgnew(sh,frame)*1.0
;Shot dark correction
shimg=shimg-shimgdark

;newdemod,shimg,cars,sh=sh,lam=lam,/doplot,demodtype='basic',ix=ix,iy=iy,p=str
newdemod,shimg,cars,sh=sh,lam=lam,demodtype='basic',ix=ix,iy=iy,p=str;no /doplot


;getptsnew,rarr=r,zarr=z,str=str,ix=ix,iy=iy,pts=pts

;plot uncalibrated image
;imgplot,abs(cars(*,*,2)),xsty=1,ysty=1
;contour,r,xsty=1,ysty=1,/noer,nl=10,c_lab=replicate(1,10)
;stop

;Apply phase and contrast calibrations
cars = cars / ( carscalphase/abs(carscalphase) )
cars = cars / abs(carscalzeta)

;;Output
phase = atan(imaginary(cars)/real_part(cars))
contrast = abs(cars)
;
jj=[0,2,3,4]
!p.multi=[0,2,5]
for k=0,3 do begin
  imgplot,contrast(*,*,jj(k)),xsty=1,ysty=1,/cb,title=kz(jj(k)),zr=[0,1]
  imgplot,phase(*,*,jj(k)),xsty=1,ysty=1,/cb,title=kz(jj(k)),zr=[0,1]
  end
end
