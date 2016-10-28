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
pro applyp0,fcb,p0
; now make these 1d arays p0,xhat,yhat,zhat 3d so that they can be
; manipulated as propoper array objects
p02=fcb & for j=0,2 do p02(j,*,*)=p0(j)

fcb=fcb-p02
end

pro applyrot,fcb,xhat,yhat,zhat
zh2=fcb & for j=0,2 do zh2(j,*,*)=zhat(j)
xh2=fcb & for j=0,2 do xh2(j,*,*)=xhat(j)
yh2=fcb & for j=0,2 do yh2(j,*,*)=yhat(j)

; define v2 as the vector between each point and the origin point
;stop

; then take the dot product with respect to each direction vector
; (xh2==xhat, yh2,zh2 etc)
fcb2=fcb
fcb2(0,*,*)=total(fcb * xh2,1)
fcb2(1,*,*)=total(fcb * yh2,1)
fcb2(2,*,*)=total(fcb * zh2,1)
; now fcb2 is the coordinates in the translated frame
fcb=fcb2
end

fil='ralphcamn';'RalphCam_displaced'
path='~/rsphy/newwrl/'
restore,file=path+fil+'show.sav',/verb
path2='~/idl/clive/nleonw/gregside2/'
;path2='~/idl/clive/nleonw/gregdown/'
restore,file=path2+'irset2.sav',/verb & viewcsys=str
restore,file=path2+'irsetmirra.sav',/verb & viewbfit=str

transc, viewcsys,xhat=xhatcsys,yhat=yhatcsys,zhat=zhatcsys,p0=p0csys


transc, viewbfit,xhat=xhatbfit,yhat=yhatbfit,zhat=zhatbfit,p0=p0bfit

invrot,xhatcsys,yhatcsys,zhatcsys,ixhatcsys,iyhatcsys,izhatcsys

fcb0=fcb

;applyp0,fcb,p0csys
;applyrot,fcb,xhatcsys,yhatcsys,zhatcsys
;applyrot,fcb,ixhatcsys,iyhatcsys,izhatcsys
;applyp0,fcb,-p0csys
;dev=max(fcb-fcb0)
;print,'dev =',dev


applyp0,fcb,p0bfit
applyrot,fcb,xhatbfit,yhatbfit,zhatbfit
applyrot,fcb,ixhatcsys,iyhatcsys,izhatcsys
applyp0,fcb,-p0csys

applyp0,lns,p0bfit
applyrot,lns,xhatbfit,yhatbfit,zhatbfit
applyrot,lns,ixhatcsys,iyhatcsys,izhatcsys
applyp0,lns,-p0csys


save,lns,fcb,file=path+fil+'2ab'+'show.sav',/verb

end
