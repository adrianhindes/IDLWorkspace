;sh=8044 
;lam=656e-9
sh=7266;74;8;l74;94;88;74
lam=529e-9
;simimgnew,simg,sh=sh,lam=lam,svec=[1,1,1,0]
simg0=getimgnew(sh,0,info=info,/getinfo,/nostop)*1.0
simg1=getimgnew(sh,20)*1.0
simg=simg1-simg0
;imgplot,simg,/cb

;stop
;simg=simimg_cxrs()

newdemod,simg,cars,sh=sh,lam=lam,/doplot,demodtype='basic',ix=ix,iy=iy,p=str
getptsnew,rarr=r,zarr=z,str=str,ix=ix,iy=iy,pts=pts



tmp=getimgnew('Cal_09102012_1',0,info=info,/getinfo,/nostop);.tif and cal_09102012_1_black

;tmpblack=getimgn(...black)
;tmp=tmp-tmpblack



;tmp2=getimgnew(sh,(early time frame),info=info,/getinfo,/nostop);.tif and cal_09102012_1_black


;newdemod, tmp,carscalzeta

;newdemod, tmp2,carscalphase


;cars = cars / abs(carscalzeta)

;cars = cars / ( carscalphse/abs(carcalphase) )

;phase = atan2(cars)
;contrast = abs(cars)



;contourn2,r

imgplot,abs(cars(*,*,1)),xsty=1,ysty=1
contour,r,xsty=1,ysty=1,/noer,nl=10,c_lab=replicate(1,10)

end
