pro fittoit, kzv,dx,dy,jj,nn,a,cars,function_name,apar,carsfit,carsfit0,carswhite1,fita,doplot=doplot
common cbmgf2, xtrue2,cohwhite

if nn eq 6 then del=[reform(kzv(dx,dy,jj(0:2)))]
if nn eq 8 then  del=[reform(kzv(dx,dy,jj(0:2))),0]
del2=reform(transpose([[del],[del]]),nn)
xtrue2=del2

if nn eq 6 then cohwhite1=[reform(carswhite1(dx,dy,jj(0:2)))]
if nn eq 8 then cohwhite1=[reform(carswhite1(dx,dy,jj(0:2))),1]
cohwhite=reform(transpose([[cohwhite1],[cohwhite1]]),nn)

x=findgen(nn)
ystart=(call_function(function_name,x,a))(0,*)

if nn eq 6 then  y=[(reform(cars(dx,dy,jj(0:2))))]
if nn eq 8 then  y=[(reform(cars(dx,dy,jj(0:2)))),1]

y2c=reform(transpose([[y],[y]]),nn)
y2=ri(y2c,x)
;dy2=reform(transpose([[abs(y)*0+1],[1/abs(y)]]),nn)
;dy2=dy2*0+1
ainit=a
yfit = LMFIT( x, y2, A , CHISQ=chisq , CONVERGENCE=convergence , FUNCTION_NAME=function_name, ITER=iter, SIGMA=sigma ,itmax=1000,/double,fita=fita)
if convergence eq 0 then begin
   print,'no convergence'
   a(*)=0.
endif
if function_name eq 'mygaussfit' or function_name eq 'mygaussbgfit' then if a(2) eq ainit(2) then a(2)=0
apar(dx,dy,*)=a
carsfit(dx,dy,*)=cars(dx,dy,*)
carsfit0(dx,dy,*)=cars(dx,dy,*)

carsfit(dx,dy,jj)=(ir(yfit))(0:2)
carsfit0(dx,dy,jj)=(ir(ystart))(0:2)


if keyword_set(doplot) then begin
   plot,del^2,alog10(abs(ir(y2))),yr=[-2,0],pos=posarr(2,1,0),title=string(dx,dy),psym=4
   oplot,del^2,alog10(abs(ir(ystart))),col=2,psym=4
   oplot,del^2,alog10(abs(ir(yfit))),col=3,psym=4
   
   plot,del,(atan2(ir(y2))),pos=posarr(/next),/noer,yr=[-!pi,!pi],psym=4
   oplot,del,(atan2(ir(ystart))),col=2,psym=4
   oplot,del,(atan2(ir(yfit))),col=3,psym=4
   print,'fitting ',function_name,dx,dy
   print,'initial a=',ainit
   print,'fitted a=',a
   stop
endif

end
