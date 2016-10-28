;pro fqdemod2, sh, test=test,nocal=nocal

;sh=11078
;t1=1.99
;t0=2.01

t0=6.015
t1=5.995
sh=11107


demodtype='basicd'
db='cnew'
lam=529.e-9


cal=getimgnew(sh,0,db='calnew')*1.
calblack=getimgnew(sh,0,db='calbgnew')*1.

cal=cal-calblack

newdemod, cal,carscal,sh=sh,db=db,lam=lam,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy,doplot=0,kx=kx,ky=ky,kz=kzd
carscal(*,*,1)/=carscal(*,*,0)/2;contrast

;stop
af:



img1=getimgnew(sh,twant=t1,db=db)*1.  
img0=getimgnew(sh,twant=t0,db=db)*1.
img=img1-img0
imgplot,img,/cb,zr=[0,200]
stop
newdemod,img,cars,sh=sh,db=db,lam=lam,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy, doplot=1
stop

cars(*,*,1)/=cars(*,*,0)/2      ;contrast
if not keyword_set(nocal) then cars(*,*,1) /= carscal(*,*,1)
imgplot,abs(cars(*,*,1)),/cb,zr=[0,1]

end

