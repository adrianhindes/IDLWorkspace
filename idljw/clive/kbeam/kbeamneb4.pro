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


;restore,file='~/idl/clive/nleonw/kmse2/irset.sav',/verb
restore,file='~/idl/clive/nleonw/kmse_7345/irset.sav',/verb
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

ang=view.tor*!dtor - 90*!dtor;;-165.5*!dtor;43.25*!dtor ; minus 1 for some reason???
r=view.rad*1e2;2180.
z=view.hei*1e2;0;219.06
yaw=-view.yaw*!dtor;20.66*!dtor;18.5671*!dtor
ang2=ang+yaw-!pi
pit=view.pit*!dtor;0.84*!dtor;3.93*!dtor
rol=view.rol*!dtor;-0.19*!dtor;14.35*!dtor

;stop

;rol= 7.87*!dtor
;print,'roll=',rol*!radeg

;stop
p0=[r*cos(ang),r*sin(ang),z]

zhat=[cos(ang2)*cos(pit),sin(ang2)*cos(pit),sin(pit)] & zhat=zhat/norm(zhat)
xhat=-crossp([0,0,1],zhat) & xhat=xhat/norm(xhat)
yhat=-crossp(zhat,xhat) & yhat=yhat/norm(yhat)

; ah ! xhat and y hat did not include any "roll" of camera about its
; axis.  This is defined by xhat2,yhat2

xhat2=xhat * cos(rol) + yhat * sin(rol)
yhat2=-xhat*sin(rol) +  yhat * cos(rol)

;stop
xhat=xhat2 ; and overwrite the orinal array
yhat=yhat2

;stop

end

;pro kbeam1
;goto,af



;uc = get_kstar_mse_images_cached(5955, camera=camera, time=timec, tree=tree)
;uc = get_kstar_mse_images_cached(7345, camera=camera, time=timec, tree=tree)

;save,uc,file='~/rsphy/im1.sav',/verb
;return

;restore,file='~/im1.sav',/verb & uc=uc(*,*,16) ; 7345,number 16

restore,file='~/im7485.sav',/verb & uc=uc(*,*,52) &uc=rotate(uc,0); 7485,number 52 (2500ms)
szz=size(uc,/dim)
;stop
hdfrestoreext,getenv('HOME')+'/_7485_52.hdf',dum
;uc=abs(dum.c4)
;ff=12
uc=congrid(abs(dum.c4),szz(0),szz(1)) &uc=rotate(uc,7)
;stop


;;uc=read_tiff('~/idl/clive/nleonw/kmse2/7241_100.tif')&uc=rotate(uc,0)



bin=8;0


;sz=[688,520] / bin

sz=[688,512] / bin

nx=sz(0)
ny=sz(1)
ix1=indgen(nx)
iy1=indgen(ny)
ix1r=ix1*bin
iy1r=iy1*bin


ix=reform(ix1 # replicate(1,ny),nx*ny)
iy=reform(replicate(1,nx) # iy1,nx*ny)
np=nx*ny


getax,xhat,yhat,zhat,p0,flen=flen,distt=dist,distcx=distcx,distcy=distcy
;flen=flen*0.5

;flen=27.e-3

;flen=17.e-3
psiz=6.5e-6*2 * bin


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
nl=100
lene=[50,400]
len=linspace(lene(0),lene(1),nl)
dl=(len(1)-len(0) ) * 0.01 ; cm to m
pts=fltarr(np,nl,3)
for i=0,np-1 do begin
    for j=0,2 do pts(i,*,j)=p0p(j,i) + cdir(j,i) * len
endfor
;stop

;stop
;calcbsnew2,p0p,cdir,ssum,prof,ductdst,beam=bm,dstmin=dstmin,dstchord=dstchord,cutdown=cutdown

barr=['k1','k2']
nb=2
for i=0,nb-1 do begin


nebula_kbps,dens,rarr,zarr,dum3,dum4,n2pop,xx=xx,yy=yy,zz=zz,rotangle=rotangle,bemis_arr=bemiss,dens=eldens,rpsi=rpsi,zpsi=zpsi,mastbeam=barr(i),psi=psi

mycheap,cx1,cx2 & cx1=cx1(0) * 1e-6 & cx2=cx2(0) * 1e-6


;stop

;stop
dens=transpose(dens,[1,0,2,3,4])
dens=dens(*,*,*,0,0)

bemiss=transpose(bemiss,[1,0,2,3,4])
bemiss=bemiss(*,*,*,0,0)

n2pop=transpose(n2pop,[1,0,2,3,4])
n2pop=n2pop(*,*,*,0,0)

ptsr=pts
ptsr(*,*,0) = pts(*,*,0) * cos(rotangle) - pts(*,*,1) * sin(rotangle)
ptsr(*,*,1) = pts(*,*,1) * cos(rotangle) + pts(*,*,0) * sin(rotangle)

;contourn2,bemiss(*,*,10),xx,yy,/cb
;plot,[-1,1]*500,[-1,1]*500,/nodata
;for i=0,np-1 do oplot,ptsr(i,*,0),ptsr(i,*,1)

ix=interpol(findgen(n_elements(xx)),xx,ptsr(*,*,0))
iy=interpol(findgen(n_elements(yy)),yy,ptsr(*,*,1))
iz=interpol(findgen(n_elements(zz)),zz,ptsr(*,*,2))

ix1=interpol(findgen(n_elements(rpsi)),rpsi,rarr)
iy1=interpol(findgen(n_elements(zpsi)),zpsi,zarr)

eldens1=transpose(interpolate(eldens(*,*,0),ix1,iy1,missing=0),[1,0,2])

psi1=transpose(interpolate(psi(*,*,0),ix1,iy1,missing=0),[1,0,2])
denscarb = eldens1* 0.03 ; 1e19 



bemissr=interpolate(bemiss,ix,iy,iz,missing=0)
psir=interpolate(psi1,ix,iy,iz,missing=0)
psirf=reform(psir,sz(0),sz(1),nl)
bemissrl=total(bemissr,2)*dl
bemissrlr=reform(bemissrl,nx,ny)


densr=interpolate(dens,ix,iy,iz,missing=0)
n2popr=interpolate(n2pop,ix,iy,iz,missing=0)

denscarbr=interpolate(denscarb, ix,iy,iz,missing=0)

cxeff=(cx1* (1-n2popr) + cx2*n2popr)
cxr = densr * cxeff * denscarbr 

cxrl=total(cxr,2)*dl/4/!pi

cxrlr=reform(cxrl,nx,ny)
densrl=total(densr,2)*dl


bemissrf=reform(bemissr,sz(0),sz(1),nl)




pos=posarr(2,1,0)
imgplot,uc,/cb,xsty=1,ysty=1,pos=pos;,zr=[0,1600]

contourn2,bemissrlr,ix1r,iy1r,/cb,pos=posarr(/next),/noer,xr=!x.crange,yr=!y.crange,xsty=1,ysty=1

;if i eq 0 then bemissrlr1=bemissrlr
;if i eq 1 then bemissrlr2=bemissrlr
;if i eq 0 then bemissrlr1=bemissrlr
if i eq 0 then bemissrf1=bemissrf
if i eq 1 then bemissrf2=bemissrf
;if i eq 0 then plotm,transpose(bemissr)
;if i eq 1 then plotm,transpose(bemissr),/over,thick=2
stop
endfor
bemissrfs=bemissrf1+bemissrf2       
imgplot,reform(bemissrfs(*,65/2,*)),/cb     
;plot,densrl
;oplot,cxrl,col=2
;stop
;172.17.102.225 is the ip number
af:
ppsirf=sqrt(psirf)
ia=86*0.2
ib=65/2
plot,ppsirf(ia,ib,*),abs(1/deriv(ppsirf(ia,ib,*))) * bemissrf1(ia,ib,*),yr=[0,1e19]*500,xr=[0,1]
 oplot,ppsirf(ia,ib,*),abs(1/deriv(ppsirf(ia,ib,*))) * bemissrf2(ia,ib,*),col=2

stop


;rr=sqrt(pts(*,*,0)^2+pts(*,*,1)^2)
;rt=fltarr(np)
;for i=0,np-1 do rt(i)=min(rr(i,*))
;stop
;stop
;pos=posarr(2,1,0)
;imgplot,uc,/cb,xsty=1,ysty=1,pos=pos

;contourn2,bemissrlr,ix1r,iy1r,/cb,pos=posarr(/next),/noer,xr=!x.crange,yr=!y.crange,xsty=1,ysty=1


stop

fac=3.6e14
plot,iy1r,densrlr(sz(0)-1,*)/fac
suc=size(uc,/dim)
oplot,uc(suc(0)-1,*),col=2

fac=1.2e14
plot,ix1r,densrlr(*,sz(1)/2)/fac
suc=size(uc,/dim)
oplot,uc(*,suc(1)/2),col=2

;contour,densrlr,nl=10,/noer,xsty=1,ysty=1
stop
end






;kbeam1
;end
