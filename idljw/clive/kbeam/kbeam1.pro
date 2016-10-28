@calcbsnew2
function fracof,v,n
nv=n_elements(v)
nv2=nv/n
ix=indgen(nv2)*n
return,v(ix)
end

pro gfitmom,x,a,f

f=a(0) * exp( - (x-a(1))^2 / 2 / a(2)^2 ) + a(3)

end


pro calcmom,vec,ia,ib,ic,fit=fit,vecf=res
ix=findgen(n_elements(vec))


ia=total(vec)
ib=total(vec*ix)/ia
ic=sqrt(total( vec* (ix-ib)^2 ) / ia)
res=vec
if keyword_set(fit) then begin
    a=[max(vec),ib,ic,0.]
    w=replicate(1,n_elements(ix))
    res=curvefit(ix,vec,w,a,function_name='gfitmom',/noder)
    ia=a(0)*a(2)
    ib=a(1)
    ic=a(2)

endif
end


pro getax,xhat,yhat,zhat,p0,flen=flen,distt=dist,distcx=distcx,distcy=distcy

;view={tor:134.35,$
;      rad:2.208,$
;      hei:0.2,$
;      yaw:0.,$
;      pit:-14.,$
;      rol:0.}

;view={tor:134.935,$
;      rad:2.22626,$
;      hei:0.199349,$
;      yaw:-0.939619,$;
;      pit:-13.0344,$
;      rol:-0.562990}
;flen=4.81661e-3
;dist=0.239977


restore,file='~/nleonw/kmse/irset.sav',/verb
view=str
flen=str.flen*1e-3
dist=str.dist
distcx=str.distcx
distcy=str.distcy
;stop



;focal length: 4.81661
; dist1/rad2 = 0.239977
;centx=0.5
;centy=0.7

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

pro kbeam1
bin=80
sz=[1392,1024] / bin

nx=sz(0)
ny=sz(1)
ix1=indgen(nx)
iy1=indgen(ny)

ix=reform(ix1 # replicate(1,ny),nx*ny)
iy=reform(replicate(1,nx) # iy1,nx*ny)
np=nx*ny


getax,xhat,yhat,zhat,p0,flen=flen,distt=dist,distcx=distcx,distcy=distcy


psiz=6.5e-6 * bin


cdir=fltarr(3,np)
p0p=cdir
for i=0,np-1 do begin


    thx=((ix(i)-sz(0)/2) * psiz/flen)
    thy=((iy(i)-sz(1)/2) * psiz/flen)

;    print,"thx,thy",thx,thy
    thxc=((sz(0)*distcx-sz(0)/2) * psiz/flen)
    thyc=((sz(1)*distcy-sz(1)/2) * psiz/flen)

    thx=atan(thx-thxc)
    thy=atan(thy-thyc)

;    print,thx*!radeg,thy*!radeg
    thr = sqrt((thx)^2+(thy)^2)
    fac=(1 - dist * thr^2 + 3 * dist^2 * thr^4)
;    print,'fac=',1-fac,i,np
;    stop
    thx = (thx )* fac
    thy = (thy )* fac
    
    thx=thx+atan(thxc)
    thy=thy+atan(thyc)


    cdir1=zhat + xhat * tan(thx) + yhat * tan(thy)
    cdir1=cdir1/norm(cdir1)
    cdir(*,i)=cdir1
    p0p(*,i)=p0

;    pv=[ -1196.07   ,   918.184   ,  -364.050]/10.

;    tmp=(pv-p0)/cdir1
;    print,tmp/tmp(0)
;    stop

endfor

calcbsnew2,p0p,cdir,ssum,prof,ductdst,beam=bm,dstmin=dstmin,dstchord=dstchord,cutdown=cutdown


uc = get_kstar_mse_images_cached(5955, camera=camera, time=timec, tree=tree)
uc=uc(*,*,10)
imgplot,uc,/cb,xsty=1,ysty=1

contour,reform(ssum,nx,ny),nl=10,/noer,xsty=1,ysty=1
stop
end






kbeam1
end
