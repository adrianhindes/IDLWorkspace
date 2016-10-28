function cart2pol, p
return,[sqrt(p(0)^2+p(1)^2),atan(p(1),p(0)),p(2)]
end
function pol2cart,p
return,[p(0) * cos(p(1)),p(0)*sin(p(1)),p(2)]
end

function cart2pol, p
return,[sqrt(p(0)^2+p(1)^2),atan(p(1),p(0)),p(2)]
end
function pol2cart,p
return,[p(0) * cos(p(1)),p(0)*sin(p(1)),p(2)]
end





pro invrot,x,y,z,x2,y2,z2
mat=[[reform(x)],[reform(y)],[reform(z)]]
imat=invert((mat))
x2=imat(*,0)
y2=imat(*,1)
z2=imat(*,2)
end

pro transc, view,xhat=xhat,yhat=yhat,zhat=zhat,p0=p0
;; this transforms the array fcb (3,indexinface(from 0 to
;; 2),indexofface) according to line of sight or perhaps the other way around

; define observer: angle, major radius r, hieght z, yaw, p0 as the
; position, pitch and roll which define the dip of the axes.
; xhat,yhat,zhat define the direction vectors of the line of sight so
; that zhat is the line of sight [at the middle] and xhat and y hat
; are the directions of the camera image.  so that p0,xhat,yhat,zhat
; define completely this.


ang=view.tor*!dtor;-165.5*!dtor;43.25*!dtor ; minus 1 for some reason???
r=view.rad*1e3;2180.
z=view.hei*1e3;0;219.06
yaw=view.yaw*!dtor;20.66*!dtor;18.5671*!dtor
ang2=ang+yaw-!pi
pit=view.pit*!dtor;0.84*!dtor;3.93*!dtor
rol=view.rol*!dtor;-0.19*!dtor;14.35*!dtor
;stop
;ang=-250*!dtor;43.25*!dtor ; minus 1 for some reason???
;r=2420.
;z=245.
;yaw=-22*!dtor;18.5671*!dtor
;ang2=-ang+yaw
;pit=1.6*!dtor;3.93*!dtor
;rol=-0.3*!dtor;14.35*!dtor



p0=[r*cos(ang),r*sin(ang),z]

zhat=[cos(ang2)*cos(pit),sin(ang2)*cos(pit),sin(pit)] & zhat=zhat/norm(zhat)
xhat=-crossp([0,0,1],zhat) & xhat=xhat/norm(xhat)
yhat=-crossp(zhat,xhat) & yhat=yhat/norm(yhat)

; ah ! xhat and y hat did not include any "roll" of camera about its
; axis.  This is defined by xhat2,yhat2

xhat2=xhat * cos(rol) + yhat * sin(rol)
yhat2=-xhat*sin(rol) +  yhat * cos(rol)
xhat=xhat2 ; and overwrite the orinal array
yhat=yhat2


end

;fil='h1aEbulge'
fil='h1aE'
fil='helical_full'
;;fil='C1h'
fil='C4'
path='~/newwrl/'
restore,file=path+fil+'show.sav',/verb
path2='~/idl/clive/nleonw/tang_port/'

dum=myrest2(path2+'objhidden_mirr_5.sav')

p1=dum.lns(*,0,0)
p2=dum.lns(*,0,1)
p3=dum.lns(*,0,3)

;stop

;0.536, -178.95, 18 is the "good mirror" fir irset3.

;p1=[      1628.96  ,   -208.469  ,    724.656]
;p2=[      1384.84 ,    -125.908  ,    402.802]
;p3=[      1637.05,     -109.500 ,     712.832]
;n2

;p1=[  1686.17,     -278.716,      631.557]
;p2=[      1377.65  ,   -138.945,      396.443]
;p3=[      1365.11  ,   -238.157 ,     396.443]
;old


;p1=[     1570.66   ,  -252.158  ,    747.483]
;p2=[     1337.40   ,  -130.853  ,    429.870]
;p3=[     1581.82   ,  -152.798  ,    745.748]


;p1=[      1638.34,     -280.233,      640.028]
;p2=[      1337.04,     -137.506,      398.091]
;p3=[      1325.82,     -236.798,      394.178]
;frim mirra

;p1=[      1641.06,     -288.670,      637.169]
;p2=[      1343.68,     -126.539,      402.055]
;p3=[      1323.69,     -224.521,      402.308]


;
; 0.596644,178.998,16.8084

pc=p1;(p1+p2)/2.
vec1=p2-p1
vec2=p3-p1

kay=crossp(vec1,vec2) & kay/=norm(kay)
kay=-kay
print,pc,kay

refmirr=[total(pc*kay)*1e-3, atan(kay(1),kay(0))*!radeg,atan(kay(2),sqrt(kay(1)^2+kay(0)^2))*!radeg]
print,refmirr
stop
ang=atan(pc(1),pc(0))
kr=sqrt(kay(0)^2+kay(1)^2)
kay2=[kr*cos(ang),kr*sin(ang),kay(2)]
print,kay
print,kay2
print,'___'
kay2=kay
print,cart2pol(pc)*[1,!radeg,1]
print,atan(-kay(2)/sqrt(kay(0)^2+kay(1)^2))*!radeg - 90.

;pc=[0,0,0]
;kay=[-1/sqrt(2.),0,1/sqrt(2.)]
fcb0=fcb

applyp0,fcb,pc
applyref,fcb,kay
applyp0,fcb,-pc

applyp0,lns,pc
applyref,lns,kay
applyp0,lns,-pc


save,lns,fcb,file=path+fil+'reft5'+'show.sav',/verb
plot,fcb0(0,*,*),fcb0(1,*,*),psym=3,/iso
oplot,fcb(0,*,*),fcb(1,*,*),psym=3,col=2

end
