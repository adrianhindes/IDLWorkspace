pro cosfit, x, a, f

f = (1+a(0))/2 + cos(2*!pi*1/a(1)*x) * (1-a(0))/2
f = ((1+a(0))/2 + cos(2*!pi*1/a(1)*x) * (1-a(0))/2)*a(2)

;stop
end

pro getit, ifr, wy,ex,ph

;ifr=0
fil1='stb9'
;fil2='sta95'

im1=getimgnew(fil1,ifr,db='i')
;im2=getimgnew(fil2,0,db='i')
im=im1*1.; - im2*1.
stop
newdemod,im,cars,sh=fil1,db='i',str=str,demodtype='basicht',kx=kx,ky=ky,kz=kz,/doplot

stop
common cbbb, carsref
if ifr eq 0 then begin
   carsref=cars
   carsref(*,*,0)=1.
   carsref(*,*,1) = carsref(*,*,1)/abs(carsref(*,*,1))
   return
endif

cars=cars/carsref

kern=fltarr(5,5) + 1 & kern/=total(kern)
;for i=0,1 do cars(*,*,i)=convol(cars(*,*,i),kern)
;stop
carsx=cars & for i=1,1 do carsx(*,*,i)*=2. / abs(cars(*,*,0))
carsx(*,*,0)=0.


;stop
;erase

imgplot,abs(carsx(*,*,1)),/cb,pos=posarr(2,1,0)
imgplot,abs(cars(*,*,0)),/cb,pos=posarr(/next),/noer

stop

ex=reform(abs(kz(1:1)))
sz=size(cars,/dim)
nnx=sz(0)/2
nny=sz(1)/2
wy=reform(abs(carsx(nnx,nny,1:1)))
ph=reform(atan2(carsx(nnx,nny,1:1)))
;plot,ex,wy,psym=4
end


n=60
arr=fltarr(1,n)
ph=arr
   getit,0,dum,ex,dum2

for i=1,n-1 do begin
   getit,i,dum,ex,dum2
   arr(*,i-1)=dum
   ph(*,i-1)=dum2
   if i gt 0 then begin
      plot,transpose(ph(0:i-1))*!radeg,psym=-4,pos=posarr(1,2,0),title='phase/red',/yno
      plot,transpose(arr(0:i-1)),psym=-4,pos=posarr(/next),/noer,title='contrast',/yno

   endif
endfor
end


