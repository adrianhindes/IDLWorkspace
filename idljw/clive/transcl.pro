pro transcl, fcb,view,xhat=xhat,yhat=yhat,zhat=zhat
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
; now make these 1d arays p0,xhat,yhat,zhat 3d so that they can be
; manipulated as propoper array objects
p02=fcb & for j=0,2 do p02(j,*,*)=p0(j)
zh2=fcb & for j=0,2 do zh2(j,*,*)=zhat(j)
xh2=fcb & for j=0,2 do xh2(j,*,*)=xhat(j)
yh2=fcb & for j=0,2 do yh2(j,*,*)=yhat(j)

; define v2 as the vector between each point and the origin point
v2=fcb-p02
;stop
fcb2=fcb
; then take the dot product with respect to each direction vector
; (xh2==xhat, yh2,zh2 etc)

fcb2(0,*,*)=total(v2 * xh2,1)
fcb2(1,*,*)=total(v2 * yh2,1)
fcb2(2,*,*)=total(v2 * zh2,1)
; now fcb2 is the coordinates in the translated frame
fcb=fcb2
;print,'fcb2=',fcb2

fcb3=fcb
;; now use the proper nonlinear transformation to calculate the x and
;; y angles as elements 0,1 and the distance as element 2
fcb3(0,*,*)=atan(fcb(0,*,*),fcb(2,*,*))
fcb3(1,*,*)=atan(fcb(1,*,*),fcb(2,*,*))
fcb3(2,*,*)=sqrt(fcb(0,*,*)^2+fcb(1,*,*)^2+fcb(2,*,*)^2)
;stop
fcb=fcb3

;fcb2t=fcb
;fcb2t(2,*,*)=fcb3(2,*,*)/ $
;  sqrt(tan(fcb3(0,*,*))^2 + tan(fcb3(1,*,*))^2 + 1)
;fcb2t(0,*,*)=tan(fcb3(0,*,*))*fcb2t(2,*,*)
;fcb2t(1,*,*)=tan(fcb3(1,*,*))*fcb2t(2,*,*)
;print,'fcb2t=',fcb2t

; finished
end
