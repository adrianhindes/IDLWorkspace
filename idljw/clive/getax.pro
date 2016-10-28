pro getax,xhat,yhat,zhat,p0,flen=flen,distt=dist,distcx=distcx,distcy=distcy,$
          folder=folder
default,folder,'~/nleonw/kmse2'
restore,file=folder+'/irset.sav',/verb
view=str
flen=str.flen*1e-3
dist=str.dist
distcx=str.distcx
distcy=str.distcy

ang=view.tor*!dtor;-165.5*!dtor;43.25*!dtor ; minus 1 for some reason???
r=view.rad*1e2;2180.
z=view.hei*1e2;0;219.06
yaw=view.yaw*!dtor;20.66*!dtor;18.5671*!dtor
ang2=ang+yaw-!pi
pit=view.pit*!dtor;0.84*!dtor;3.93*!dtor
rol=view.rol*!dtor;-0.19*!dtor;14.35*!dtor
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
