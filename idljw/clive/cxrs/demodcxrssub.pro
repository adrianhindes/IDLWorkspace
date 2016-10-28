pro demodcxrssub, img, cars,carscal5,sh=sh,db=db,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy,ns=ns,just=just,kz=kz,yfac=yfac
default,ns,4

lam=532.e-9
newdemod,img,cars,sh=sh,db=db,lam=lam,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy,kz=kz;/doplot
for i=0,4 do if i ne 1 then cars(*,*,i)=cars(*,*,i)/cars(*,*,1)
if keyword_set(just) then return
;stop
;carstmp=cars
carscal51=carscal5 & carscal51(*,*,1)=1.
cars = cars / (carscal51)
if ns gt 1 then begin
   default,yfac,2
   kern=fltarr(ns,ns*yfac,1) + 1./ (ns*ns*yfac)
   for i=0,4 do cars(*,*,i)=convol(cars(*,*,i),kern) ; smooth it 
endif
;stop
end
