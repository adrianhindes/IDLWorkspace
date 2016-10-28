pro qitmy3b
sh=9211;9206;86
ifr=3.34 ;50
ifrdark=3.30;85
lam=529e-9

;Contrast (zeta) correction - using calibration file
calblack=getimgnew(sh,0,db='calbg')*1.
cal=getimgnew(sh,0,db='cal')*1.

cal=cal-calblack

    calimg0=cal&sz=size(cal,/dim)
    for i=0,sz(1)-1 do cal(*,i)=median(calimg0(*,i),5)


;stop

imglight=getimgnew(sh,twant=ifr,db='c')*1.0
imgdark=getimgnew(sh,twant=ifrdark,db='c')*1.0
print,total(imglight)
print,total(imgdark)
;Shot dark correction

img0=imglight&sz=size(imglight,/dim)
for i=0,sz(1)-1 do imglight(*,i)=median(img0(*,i),5)
idx=where(imglight gt 2000)
if idx(0) ne -1 then imglight(idx)=0.

img0=imgdark&sz=size(imgdark,/dim)
for i=0,sz(1)-1 do imgdark(*,i)=median(img0(*,i),5)
idx=where(imgdark gt 2000)
if idx(0) ne -1 then imgdark(idx)=0.


img=imglight-imgdark

imgplot,imglight,pos=posarr(2,2,0),zr=[0,1000],title=string(sh,ifr,format='("#",I0,"@t=",G0,"s")'),/cb
imgplot,imgdark,pos=posarr(/next),zr=[0,1000],/noer,title=string(sh,ifr,format='("#",I0,"@t=",G0,"s")'),/cb
imgplot,img,pos=posarr(/next),/noer,zr=[0,100],title='difference',/cb
stop

gencarriers,th=[0,0],sh=sh,kx=kx,ky=ky,kz=kz,lam=lam,db='c'

newdemod, cal,carscal,sh=sh,db='c',lam=lam,demodtype='basicd46',ix=ix,iy=iy,p=str;,/doplot
for i=0,4 do if i ne 1 then carscal(*,*,i)=carscal(*,*,i)/carscal(*,*,1)

newdemod,img,cars,sh=sh,db='c',lam=lam,demodtype='basicd46',ix=ix,iy=iy,p=str,/doplot
stop
for i=0,4 do if i ne 1 then cars(*,*,i)=cars(*,*,i)/cars(*,*,1)

;stop
;cars = cars / ( carscalphase/abs(carscalphase) )
cars = cars / (carscal)

;;Output
phase = atan(imaginary(cars)/real_part(cars))
contrast = abs(cars)
;
jj=[0,2,4]
;!p.multi=[0,2,5]
erase
for k=0,2 do begin
  imgplot,contrast(*,*,jj(k)),xsty=1,ysty=1,/cb,title=kz(jj(k)),zr=[0,1],pos=posarr(2,3,2*k),/noer

  imgplot,phase(*,*,jj(k)),xsty=1,ysty=1,/cb,title=kz(jj(k)),pal=-2,pos=posarr(2,3,2*k+1),/noer

end
stop
end

qitmy3b
end
