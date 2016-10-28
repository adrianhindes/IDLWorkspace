pro getaxnew,xhat,yhat,zhat,p0,str=x,flen=flen,distcx=distcx,distcy=distcy,doback=doback,kdist=dist,view=view

cont=fltarr(2)
    i=0
    sh=x(i++)
    frnum=x(i++)
    cont(0)=x(i++)
    cont(1)=x(i++)
    flen=x(i++)
    rad=x(i++)
    tor=x(i++)
    hei=x(i++)
    yaw=x(i++)
    pit=x(i++)
    rol=x(i++)
    dist=x(i++)
    distcx=x(i++)
    distcy=x(i++)


ang=tor*!dtor
r=rad*1e2
z=hei*1e2
yaw=yaw*!dtor

if keyword_set(doback) then begin
    ang=ang-90*!dtor
    yaw=-yaw
endif

ang2=ang+yaw-!pi
pit=pit*!dtor
rol=rol*!dtor

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
