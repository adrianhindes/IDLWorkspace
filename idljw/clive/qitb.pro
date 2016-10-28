goto,ee2
;sh=8044 
;lam=656e-9
sh=7266;74;8;l74;94;88;74
lam=529e-9
doplot=0
;simimgnew,simg,sh=sh,lam=lam,svec=[1,1,1,0]
simg0=getimgnew(sh,1,info=info,/getinfo,/nostop)*1.0
simg1=getimgnew(sh,twant=5.3)*1.0
simg00=(simg1-simg0)>0
simg=median(simg00,3,dimension=0) ;; filter hard coded!!!
simg=median(simg,3,dimension=1) ;; filter hard coded!!!



;imgplot,simg,/cb

plot,simg00
oplot,simg,col=2
;simg=simimg_cxrs()
stop
newdemod,simg,cars,sh=sh,lam=lam,doplot=doplot,demodtype='basic',ix=ix,iy=iy,p=str




;getptsnew,rarr=r,zarr=z,str=str,ix=ix,iy=iy,pts=pts

ee:

;tmp=getimgnew('Cal_09102012_1',0,info=info,/getinfo,/nostop);.tif and cal_09102012_1_black

tmp1=1.0*getimgnew('edge_cal',0,info=info,/getinfo,/nostop);.tif and cal_09102012_1_black
tmp0=1.0*getimgnew('edge_cal_black',0,info=info,/getinfo,/nostop);.tif and cal_09102012_1_black
tmp=tmp1-tmp0

tmp=median(tmp,3,dimension=0) ;; filter hard coded!!!
tmp=median(tmp,3,dimension=1) ;; filter hard coded!!!

newdemod,tmp,carc,lam=lam,doplot=doplot,demodtype='basic',sh='edge_cal'


;stop
;tmpblack=getimgn(...black)
;tmp=tmp-tmpblack



;tmp2=getimgnew(sh,(early time frame),info=info,/getinfo,/nostop);.tif and cal_09102012_1_black


;newdemod, tmp,carscalzeta

;newdemod, tmp2,carscalphase

ee2:

carcb = carc/replarr(abs(carc(*,*,1)),5)
carsb = cars/replarr(abs(cars(*,*,1)),5)

cars2 = carsb / abs(carcb)

;cars = cars / ( carscalphse/abs(carcalphase) )

;phase = atan2(cars)
contrast = abs(cars2)

gencarriers,th=[0,0],sh=sh,kx=kx,ky=ky,kz=kz,lam=lam
idx=sort(abs(kz))
kz2=abs(kz(idx))

plot,abs(kz2),contrast(90,50,idx),psym=-4
oplot,abs(kz2),contrast(70,50,idx),psym=-4,col=2
oplot,abs(kz2),contrast(55,50,idx),psym=-4,col=3

sz=size(contrast,/dim)
contourn2,reform(contrast(*,50,idx)),indgen(sz(0)),abs(kz2),/cb,zr=[0,1]
plot,indgen(sz(0)),abs(cars(*,50,1)),/noer
stop

;contrast=contrast(*,*,idx)
pos=posarr(3,2,0)&erase
zr1=[1,1,1,1,1]
for i=0,4 do begin
    imgplot,contrast(*,*,i),pos=pos,/noer,/cb,zr=[0,zr1(i)]
    pos=posarr(/next)
endfor



;contourn2,r

;imgplot,abs(cars(*,*,1)),xsty=1,ysty=1
;contour,r,xsty=1,ysty=1,/noer,nl=10,c_lab=replicate(1,10)

end
