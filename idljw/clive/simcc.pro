
function func, r, theta,time


freq=1000.
m = 5
r0=cos(r*!pi/2)

amp=sin(r*!pi)*0.5

z=r0 + amp * cos(m * theta - 2*!pi*freq*time)
return,z
end

nr=10
ntheta=30
nt=100
r=linspace(0,1,nr)
theta=linspace(-50*!dtor,50*!dtor,ntheta)
time=linspace(0,1e-2,nt)

r3=fltarr(nr,ntheta,nt) & for i=0,nr-1 do r3(i,*,*)=r(i)
theta3=fltarr(nr,ntheta,nt) & for i=0,ntheta-1 do theta3(*,i,*)=theta(i)
time3=fltarr(nr,ntheta,nt) & for i=0,nt-1 do time3(*,*,i)=time(i)

z=func(r3,theta3,time3)
imgplot,z(*,*,0),/cb

ia=[1,15]
ib=[1,20]
sa=z(ia(0),ia(1),*)
sb=z(ib(0),ib(1),*)

plot,sa,pos=posarr(3,1,0)
oplot,sb,col=2

lag=findgen(10)
cor=myc_correlate(sa,sb,lag,ipar=1)
corb=myc_correlate(sa,sb,lag,ipar=0)

plot,lag,cor,/noer,col=3,pos=posarr(/next)
plot,lag,corb,/noer,pos=posarr(/next),col=4

end
