




pro calcb,x,y,z,bx,by,bz,br,bphi

;ix=where((z ge min(z1)) and (z le max(z1)))
;x=x(ix)
;y=y(ix)
;z=z(ix)


r=sqrt(x^2+y^2)
phi=atan(y,x)

calcbc,r,phi,z,br,bphi,bz

bx = br * cos(phi) - bphi * sin(phi)
by = br * sin(phi) + bphi * cos(phi)


end

pro calcbc,r,phi,z,br,bphi,bz,grid=grid

common cbmag,br1,bz1,bphi1,r1,z1,phi1,raxb

phiper=2*!pi/3.
phimod = modb(phi,phiper)
;phimod = 60*!dtor + phimod*0.
i3=interpol(findgen(n_elements(phi1)),phi1,phimod)
i1=interpol(findgen(n_elements(r1)),r1,r)
i2=interpol(findgen(n_elements(z1)),z1,z)



br=interpolate(br1,i1,i2,i3,grid=grid)
bz=interpolate(bz1,i1,i2,i3,grid=grid)
bphi=interpolate(bphi1,i1,i2,i3,grid=grid)
;velovect,br,bz
;stop
end









pro calcmag, xsel,ysel,zsel,bx1,by1,bz1;,rax=rax

rax=0.9
;default,rax,3.6
;dat={br:br,bz:bz,bphi:bphi,r:r,z:z,phi:phi}
common cbmag,br,bz,bphi,r,z,phi,raxb
if (n_elements(br) ne 0) then  goto,sk
raxb=rax
;raxs=string(rax*100,format='(I0)')
;hdfrestoreext,'c:\b'+raxs+'.hdf',dat
restore,file='~/idl/clive/bvec2.sav',/verb
;stop
r/=100.
z/=100.

phi=p
nphi=n_elements(phi)
nr=n_elements(r)
nz=n_elements(z)

;dat.phi=(linspace(0,2*!pi/10,37))(0:35)

;br=fltarr(nr,nz,nphi+1)
;bz=fltarr(nr,nz,nphi+1)
;bphi=fltarr(nr,nz,nphi+1)
;phi=[dat.phi,dat.phi(0)+2*!pi/10]
;br(*,*,0:nphi-1)=dat.br
;bz(*,*,0:nphi-1)=dat.bz
;bphi(*,*,0:nphi-1)=dat.bphi
;br(*,*,nphi)=dat.br(*,*,0)
;bz(*,*,nphi)=dat.bz(*,*,0)
;bphi(*,*,nphi)=dat.bphi(*,*,0)
;r=dat.r
;z=dat.z



sk:

; xt  = -(3900e-3 - 280e-3)
; yt = 0;400.e-3
; zt  = 4031e-3
; ;bottom
; xb = -(3900e-3 - 284e-3)
; yb  = 0;-414.7e-3
; zb  = -3921.e-3

; np=100

; xsel=linspace(xb,xt,np)
; ysel=linspace(yb,yt,np)
; zsel=linspace(zb,zt,np)

calcb,xsel,ysel,zsel,bx1,by1,bz1

end





function vabs,x
return,sqrt( x(0)^2 + x(1)^2 + x(2)^2 )
end



function bhatdir,x,yp
calcb,yp(0),yp(1),yp(2),bx,by,bz
bhat=[bx,by,bz]
bhat=bhat/vabs(bhat)
return, bhat
end



pro calcsurf,phisel=phisel

calcmag, [0.],[0.],[0.]
default,phisel,0.01

i=0L
nx=6
x0arr=linspace(1.35,1.25,nx)
for i=0,nx-1 do begin
    calcline,x0arr(i),0.,0.,rpoi,zpoi,phisel=phisel
    if i eq 0 then plot,rpoi,zpoi,psym=3,/iso else $
      oplot,rpoi,zpoi,col=i+1,psym=3
    theta=atan(zpoi,rpoi-3.6)
    nb=36
    hg=histogram(theta,min=-!pi,max=!pi,nbins=nb)
    hgx=linspace(-!pi,!pi,nb)
;    plot,hgx,hg
;    stop

  endfor

end

pro calcline,x0,y0,z0,rpoi,zpoi,phisel=phisel,rarr=rarr,parr=phiarr,zarr=zarr

;;; dy / dt == B/modb

; dy(0)/dt = Bhat(0)
; dy(1)/dt = Bhat(1)
; dy(2)/dt = Bhat(2)


nlim=6000L*20L/10L
dstep = 0.5e-2*20;*10.
;x0=3.8
;y0=0.
;z0=0.
xarr=fltarr(nlim)
yarr=fltarr(nlim)
zarr=fltarr(nlim)

rpoi=xarr
zpoi=xarr
ppoi=xarr
yp=[x0,y0,z0]
tmp=fltarr(3,nlim)
len=0.
for i=0L,nlim-1 do begin
    dydx=bhatdir(0.,yp)
    yp1=rk4(yp,dydx,len,dstep,'bhatdir',/double)
;    yp1=yp+dydx*dstep/10.
;    stop
    yp=yp1
    xarr(i)=yp(0)
    yarr(i)=yp(1)
    zarr(i)=yp(2)
    tmp(*,i)=yp
    if i mod 1000 eq 0 then print,i,nlim
 endfor

;plot,tmp(0,*),tmp(1,*)

;stop
rarr=sqrt(xarr^2+yarr^2)
phiarr=atan(yarr,xarr)
;stop
phimod=modb(phiarr,(2*!pi/3))
;phimod=phiarr
ipoi=0L
;default,phisel,3.*!dtor
print,phisel
for i=0L,nlim-2 do begin

    if ((phimod(i) - phisel)*(phimod(i+1)-phisel) lt 0.) $
      and (phimod(i+1)-phimod(i) lt 0) then begin
       rpoi(ipoi)=interpol(rarr(i:i+1),phimod(i:i+1),phisel)
       zpoi(ipoi)=interpol(zarr(i:i+1),phimod(i:i+1),phisel)
       ppoi(ipoi)=phimod(i)
       ipoi=ipoi+1
   endif
endfor
rpoi=rpoi(0:ipoi-1)
zpoi=zpoi(0:ipoi-1)
ppoi=ppoi(0:ipoi-1)

tarr=atan(zarr,rarr-3.6)

;plot,phiarr,tarr
;plot,rpoi,zpoi,psym=3,/iso
;stop




;stop
end
pro test
restore,file='~/rz.sav'
p=60*!radeg
x=rout2*cos(p)
z=zout2
y=rout2*sin(p)
calcmag,x,y,z,bx,by,bz
imgplot,bz,rout,zout,/cb

;calcmag,
end


;calcsurf
;end

