pro qitmy3
sh=9194;86
ifr=125;50
ifrdark=329
lam=529e-9

;Contrast (zeta) correction - using calibration file
calblack=getimgnew(sh,0,db='calbg')*1.
cal=getimgnew(sh,0,db='cal')*1.

cal=cal-calblack

    calimg0=cal&sz=size(cal,/dim)
    for i=0,sz(1)-1 do cal(*,i)=median(calimg0(*,i),5)


;stop

img=getimgnew(sh,ifr,db='c')*1.0
imgdark=getimgnew(sh,ifrdark,db='c')*1.0
;Shot dark correction
img=img-imgdark

    img0=img&sz=size(img,/dim)
    for i=0,sz(1)-1 do img(*,i)=median(img0(*,i),5)

idx=where(img gt 2000)
img(idx)=0.

;imgplot,img,pos=posarr(2,1,0),zr=[0,2000]
;imgplot,img0,pos=posarr(/next),/noer,zr=[0,2000]
;stop

gencarriers,th=[0,0],sh=sh,kx=kx,ky=ky,kz=kz,lam=lam,db='c'

newdemod, cal,carscal,sh=sh,db='c',lam=lam,demodtype='basicd44',ix=ix,iy=iy,p=str;,/doplot
for i=0,4 do if i ne 1 then carscal(*,*,i)=carscal(*,*,i)/carscal(*,*,1)

newdemod,img,cars,sh=sh,db='c',lam=lam,demodtype='basicd44',ix=ix,iy=iy,p=str;,/doplot

for i=0,4 do if i ne 1 then cars(*,*,i)=cars(*,*,i)/cars(*,*,1)

;stop
;cars = cars / ( carscalphase/abs(carscalphase) )
cars = cars / (carscal)

;;Output
phase = atan(imaginary(cars)/real_part(cars))
contrast = abs(cars)
;
jj=[0,2,3,4]
!p.multi=[0,2,5]
for k=0,3 do begin
  imgplot,contrast(*,*,jj(k)),xsty=1,ysty=1,/cb,title=kz(jj(k)),zr=[0,1]
  imgplot,phase(*,*,jj(k)),xsty=1,ysty=1,/cb,title=kz(jj(k)),pal=-2

end
stop
end

qitmy3
end
