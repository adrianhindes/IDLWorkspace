
pro make_p0_cdir,p0p,cdir,ix,iy,folder=folder,bin=bin,sz=sz,ix1=ix1,iy1=iy1,type=type,wid=wid
default,bin,16
;1392=2^4 * 3^1 * 29
;1024=2^10

if wid eq 1392 then szu=[1392,1024]
if wid eq 1600 then szu=[1600,1644]
sz=szu / bin

nx=sz(0)
ny=sz(1)
ix1=indgen(nx)*bin
iy1=indgen(ny)*bin

ix=reform(ix1 # replicate(1,ny),nx*ny)
iy=reform(replicate(1,nx) # iy1,nx*ny)
np=nx*ny


getax,xhat,yhat,zhat,p0,flen=flen,distt=dist,distcx=distcx,distcy=distcy,$
  folder=folder


psiz=6.5e-6 


cdir=fltarr(3,np)
p0p=cdir
for i=0,np-1 do begin


    thx=((ix(i)-szu(0)/2) * psiz/flen)
    thy=((iy(i)-szu(1)/2) * psiz/flen)

;    print,"thx,thy",thx,thy
    thxc=((szu(0)*distcx-szu(0)/2) * psiz/flen)
    thyc=((szu(1)*distcy-szu(1)/2) * psiz/flen)

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


end
