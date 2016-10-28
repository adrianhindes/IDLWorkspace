;pro fqdemod2, sh, test=test,nocal=nocal

sh=10402


demodtype='basicqcell'
db='cnewl'
lam=529.e-9

if keyword_set(nocal) then goto,af
if keyword_set(test) then begin
   cal=getimgnew(47,0,db='calnew')*1.
   calblack=cal*0
endif else begin
   cal=getimgnew(sh,0,db='calnewl')*1.
   calblack=getimgnew(sh,0,db='calbgnewl')*1.
endelse
cal=cal-calblack
newdemod, cal,carscal,sh=sh,db=db,lam=lam,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy,doplot=0,kx=kx,ky=ky,kz=kz
carscal(*,*,1)/=carscal(*,*,0)/2;contrast

;stop
af:



dum=getimgnew(sh,0,db=db,info=info,/getinfo)
nfr=info.num_images
;if keyword_set(test) then nfr=2

img=getimgnew(sh,1,db=db)*1. - getimgnew(sh,0,db=db)*1.
newdemod,img,cars,sh=sh,db=db,lam=lam,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy, doplot=0
;stop

cars(*,*,1)/=cars(*,*,0)/2      ;contrast
if not keyword_set(nocal) then cars(*,*,1) /= carscal(*,*,1)
imgplot,abs(cars(*,*,1)),/cb,zr=[0,1]

end

