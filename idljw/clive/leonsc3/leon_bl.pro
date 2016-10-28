pro itransc, fcb3,view
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
p02=fcb3 & for j=0,2 do p02(j,*,*)=p0(j)
v2=fcb3
fcb2=fcb3

;zh2=fcb3 & for j=0,2 do zh2(j,*,*)=zhat(j)
;xh2=fcb3 & for j=0,2 do xh2(j,*,*)=xhat(j)
;yh2=fcb3 & for j=0,2 do yh2(j,*,*)=yhat(j)



fcb2(2,*,*)=fcb3(2,*,*)/ $
  sqrt(tan(fcb3(0,*,*))^2 + tan(fcb3(1,*,*))^2 + 1)
fcb2(0,*,*)=tan(fcb3(0,*,*))*fcb2(2,*,*)
fcb2(1,*,*)=tan(fcb3(1,*,*))*fcb2(2,*,*)

for j=0,2 do v2(j,*,*)=$
  fcb2(0,*,*)*xhat(j) + $
  fcb2(1,*,*)*yhat(j) + $
  fcb2(2,*,*)*zhat(j)

fcb=v2+p02

;stop
fcb3=fcb
end

pro leon_bl,xclick,yclick,view

common czb, x2,y2,x1,y1,zb ;  common block containing z buffer.  x1,y1 are 1 1d arrays and x2,y2 are 2d arrays

;common cbsrch,smask,swt,nmask
common cbleon, sim,sobj;img,imset
common cbleon3, spts

;ln=sobj.lns(*,*,spts.ifnd2(smask))
;transc, ln,view
;ix=indgen(nmask)
;px1=(reform(ln(0,*,*))*view.flen/sim.del(0)+ sim.sz(0)/2 ) 
;py1=(reform(ln(1,*,*))*view.flen/sim.del(1) + sim.sz(1)/2) 

;distort,px1,py1,view,sim.sz,sim.del

xclick2=xclick*sim.sz(0)
yclick2=yclick*sim.sz(1)
angle_x2=(xclick2-sim.sz(0)*view.distcx)*sim.del(0)/view.flen
angle_y2=(yclick2-sim.sz(1)*view.distcy)*sim.del(1)/view.flen
ix=value_locate(x1,angle_x2)
iy=value_locate(y1,angle_y2)

;print,ix,iy
;print,zb(ix,iy)

pvec=[x1(ix),y1(iy),zb(ix,iy)]
pvec2=reform(pvec,[3,1,1])
;help,pvec2
;print,'--'

;tvec=[1809,80,0.]
;tvec2=reform(tvec,[3,1,1])
;transc,tvec2,view
;stop
itransc, pvec2,view
print,pvec2,format='("[",G0,",",G0,",",G0,"],$")'
;stop
end
