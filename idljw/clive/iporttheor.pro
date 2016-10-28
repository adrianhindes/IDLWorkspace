function rotd,th,ix
if ix eq 2 then begin&i1=0&i2=1&end
if ix eq 1 then begin&i1=0&i2=2&end
if ix eq 0 then begin&i1=1&i2=2&end
mat=identity(3)
mat(i1,i1)=cos(th)
mat(i1,i2)=sin(th)
mat(i2,i1)=-sin(th)
mat(i2,i2)=cos(th)
return,mat
end

;p=[1123,-2531,30] ;is positino f port
;p=[2531,1123,30] ;is positino f port ; clive
p=[2618., 1066., 230. ] ; mark
p=[2524, 1270, 230.] ; clive again

;9.24 bank and tilt of 23.5 deg
ang=atan(p(1),p(0))
mvec=[0.,1.,0.]
mvec = rotd(23.5*!dtor,2) # mvec
mvec=rotd(9.24*!dtor,0) # mvec
mvec=rotd(-ang,2) # mvec
print,'mvec',mvec

zhat=[-1,0,0]
zhat=rotd(-ang,2) # zhat
print,'zhat',zhat

xhat=[0,1,0]
xhat=rotd(9.24*!dtor,0) # xhat
xhat=rotd(-ang,2) # xhat
print,'xhat',xhat


zhatr = zhat - 2 * (total(zhat*mvec)) * mvec & zhatr/=norm(zhatr)
print,'zhatr',zhatr
xhatr = xhat - 2 * (total(xhat*mvec)) * mvec & xhatr/=norm(xhatr)
xhatr=-xhatr
print,'xhatr',xhatr

n1=30
n2=30
n3=30
yaw=linspace(-10,10,n1)-43.
pitch=linspace(-10,10,n2)-2.
roll=linspace(-10,10,n3)
map=[9240,127,500,1500,60.8177,2.77,23.8,0.03,-43.6982,-1.94847,-6.39776,0,0.5,0.5]
map(6)=ang*!radeg
cs=fltarr(n1,n2)
for i=0,n1-1 do for j=0,n2-1 do begin
   map(8)=yaw(i) & map(9)=pitch(j)
   getaxnew,xhat1,yhat1,zhat1,p0,str=map,flen=135e-3
   cs(i,j)=total( (zhat1 - zhatr)^2 )
endfor
dum=min(cs,imin)
map(8)=yaw(imin mod n1)
map(9)=pitch(imin/ n1)

print,map(8:9)
getaxnew,xhat1,yhat1,zhat1,p0,str=map,flen=135e-3

n3=30
csb=fltarr(n3)
for i=0,n3-1 do begin
   map(10)=roll(i)
   getaxnew,xhat1,yhat1,zhat1,p0,str=map,flen=135e-3
   csb(i)=total( (xhat1 - xhatr)^2 )
endfor
dumb=min(csb,ibmin)
map(10)=roll(ibmin)
print,map(8:10)
getaxnew,xhat1,yhat1,zhat1,p0,str=map,flen=135e-3




;print,'zhat1=',zhat1
;print,'xhat1=',xhat1


end
