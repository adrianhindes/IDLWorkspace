

@trgrid
function amod2, x

y=x mod (!pi)

idx=where(y gt !pi/2)
if idx(0) ne -1 then y(idx)=y(idx)-!pi

idx=where(y lt -!pi/2)
if idx(0) ne -1 then y(idx)=y(idx)+!pi


return, y
end


pro interpolmn,rmn,zmn,par
;stop
n2=100
;rho2=(linspace(0,sqrt(1.2),n2))^2
rho2=linspace(0,1.0,n2)
par2={$
     jr:interpol(par.jr,par.rho,rho2),$
     rho:rho2,$
     iota:interpol(par.iota,par.rho,rho2),$
     vp:interpol(par.vp,par.rho,rho2),$
     b0:interpol(par.b0,par.rho,rho2),$
     et:interpol(par.et,par.rho,rho2),$
     eh:interpol(par.eh,par.rho,rho2),$
     m:par.m,n:par.n,nrho:n2,nmod:par.nmod}
nn=n_elements(rmn(0,*))
rmn2=fltarr(n2,nn)
zmn2=rmn2
for i=0,nn-1 do begin
    rmn2(*,i)=interpol(rmn(*,i),par.rho,rho2)
    zmn2(*,i)=interpol(zmn(*,i),par.rho,rho2)
endfor
rmn=rmn2
zmn=zmn2
par=par2
end






function fgauss,x,c,w
return,exp(- (x-c)^2/w^2/2)
end



pro invmap,rmn,zmn,par,rout,zout,rhogrid,$
           rcthgrid,rsthgrid,bxgrid,bygrid,bzgrid,phi=phi,r1=r1,z1=z1,$
           rho1=rho1,theta1=theta1,nrho=nrho,ntheta=nth

default,nth,30;100
default,phi,0.

nrho=n_elements(par.rho)
irhoarr=findgen(nrho);fix(linspace(0,n_elements(par.rho)-1,nrho))
r1=fltarr(nrho,nth)
z1=fltarr(nrho,nth)
rho1=fltarr(nrho,nth)
theta1=fltarr(nrho,nth)
theta=linspace(0,2*!pi,nth)
bx1=r1
by1=r1
bz1=r1

for i=0,nrho-1 do begin

    evalsurfb,rmn,zmn,par,rt,zt,irhoarr(i),bxt,byt,bzt,phi=phi,theta=theta
    r1(i,*)=rt
    z1(i,*)=zt
    bx1(i,*)=bxt
    by1(i,*)=byt
    bz1(i,*)=bzt

    rho1(i,*)=par.rho(irhoarr(i))
    theta1(i,*)=theta
endfor

plot,r1,z1,psym=3,/iso,title=phi*!radeg
;stop
triangulate,r1,z1,tri
gs=[0.03,0.03]/3.
default,limits,[0.6,-0.4,1.4,0.4]
if n_elements(rout) eq 0 then $
  rhogrid=trigrid(r1,z1,rho1,tri,gs,limits,xgrid=rout,ygrid=zout,missing=1.) else $
    rhogrid=trigrid(r1,z1,rho1,tri,gs,xout=rout,yout=zout,missing=1.)
rcthgrid=trigrid(r1,z1,rho1*cos(theta1),tri,gs,xout=rout,yout=zout)
rsthgrid=trigrid(r1,z1,rho1*sin(theta1),tri,gs,xout=rout,yout=zout)
print,'gs',gs,n_elements(rout),n_elements(zout)
bxgrid=trigrid(r1,z1,bx1,tri,gs,xout=rout,yout=zout)
bygrid=trigrid(r1,z1,by1,tri,gs,xout=rout,yout=zout)
bzgrid=trigrid(r1,z1,bz1,tri,gs,xout=rout,yout=zout)

;  contour,bygrid,rout,zout,nl=20,/iso

;  !p.multi=[0,3,3]
;  !p.charsize=1
;  isel=15
;  plot,zout,rhogrid(isel,*),title='rho'
;  plot,zout,rcthgrid(isel,*),title='rcth'
;  plot,zout,rsthgrid(isel,*),title='rsth'
;  plot,zout,atan(rsthgrid(isel,*),rcthgrid(isel,*))*!radeg,title='pol'
;  plot,zout,bxgrid(isel,*),title='bx'
;  plot,zout,bygrid(isel,*),title='by'
;  plot,zout,bzgrid(isel,*),title='bz'


;  !p.multi=0
; plot,zout,atan(bxgrid(isel,*),bygrid(isel,*))*!radeg,title='mag pitch'
;stop
;stop
end

pro evalsurfb,rmn,zmn,par,r,z,i,dx,dy,dz,phi=phi,theta=theta
nth=n_elements(theta)
r=fltarr(nth)
z=fltarr(nth)
r2=fltarr(nth)
z2=fltarr(nth)
dphi=2*!pi/3. * 0.01

dtheta=3. * par.iota(i) * dphi
for j=0,par.nmod-1 do begin
    r=r  + rmn(i,j)*cos(par.m(j)*theta-par.n(j)*phi)
    z=z  + zmn(i,j)*sin(par.m(j)*theta-par.n(j)*phi)
    r2=r2+ rmn(i,j)*cos(par.m(j)*(theta+dtheta)-par.n(j)*(phi+dphi))
    z2=z2+ zmn(i,j)*sin(par.m(j)*(theta+dtheta)-par.n(j)*(phi+dphi))
endfor
x=r*cos(phi)
y=r*sin(phi)
x2=r2*cos(phi+dphi)
y2=r2*sin(phi+dphi)
dx=x2-x
dy=y2-y
dz=z2-z
mag=sqrt(dx^2+dy^2+dz^2)
dx=dx/mag
dy=dy/mag
dz=dz/mag
;xa=reform(transpose([[x],[x2]]),200)
;ya=reform(transpose([[y],[y2]]),200)
;za=reform(transpose([[z],[z2]]),200)
;plot_3dbox,xa,ya,za
;stop

end

pro evalsurf,rmn,zmn,par,r,z,i,phi=phi,nth=nth,theta=theta
default,phi,0.
default,nth,100.
theta=linspace(0,2*!pi,nth)
r=fltarr(nth)
z=fltarr(nth)
for j=0,par.nmod-1 do begin
    r=r+rmn(i,j)*cos(par.m(j)*theta-par.n(j)*phi)
    z=z+zmn(i,j)*sin(par.m(j)*theta-par.n(j)*phi)
endfor
;plot,r,z,title=i,/iso
end









;, Z=sum(m,n)zmn*sin(m*theta-n*phi)

function strsplit2,str,spl
nspl=n_elements(spl)
p=fltarr(nspl)
for i=0,nspl-1 do begin
    p(i)=strpos(str,spl(i))
endfor
l=[p(1:nspl-1)-p(0:nspl-2),999]
val=strarr(nspl)
for i=0,nspl-1 do val(i)=strmid(str,p(i),l(i))
return,val
end


function extreq,str,name=name
a=strsplit(strtrim(str,2),'=',/extr)
val=float(strtrim(a(1),2))
name=a(0)
;print,name,val
return,val
end

pro rdflx, rmn,zmn, pars,file=file

;file='/home/cam112/boozmn_h1ass027v1_0p02.nc'
;file='/home/cam112/boozmn_h1ass027v1_0p83.nc'
file='/home/cam112/vmout/./kh0.850-kv1.000fixed/boozmn_wout_kh0.850-kv1.000fixed.nc'
;file='/home/cmichael/vmout/kh0.450-kv1.000fixed/boozmn_wout_kh0.450-kv1.000fixed.nc'

id=ncdf_open(file)
;dum=hdf_browser();file)

inq=ncdf_inquire(id)
;help,/str,inq
for i=0,inq.nvars-1 do begin
   tmp=ncdf_varinq(id,i) ;& print,tmp.name,tmp.dim
   ;if tmp.name eq 'rmnc_b' then 
   ncdf_varget,id,i,tvar
   if i eq 0 then par=create_struct(tmp.name,tvar) else par=create_struct(par,tmp.name,tvar)
endfor


rmn=transpose(par.rmnc_b)
zmn=transpose(par.zmns_b)


;dum=findfile(fil,count=cnt)
;if cnt eq 0 then return
;openr,lun,fil,/get_lun
;str=''
;for i=1,7 do readf,lun,str
;readf,lun,str
;spl=strsplit(str,'  ',/extr,/reg)
jlist=par.jlist
;jlist=par.jlist(0:n_elements(par.jlist)-7)
nrho=n_elements(jlist)
nmod=n_elements(par.ixm_b)

;rmn=fltarr(nrho,nmod)
;zmn=fltarr(nrho,nmod)
narr=par.ixn_b;fltarr(nmod)
marr=par.ixm_b;fltarr(nmod)
jr=fltarr(nrho)
tmp=linspace(0,1,par.ns_b)
rho=tmp(jlist)
iota=par.iota_b(jlist);fltarr(nrho)
vp=fltarr(nrho)
b0=fltarr(nrho)
et=fltarr(nrho)
eh=fltarr(nrho)

;; for i=0,nrho-1 do begin
;;     readf,lun,str
;;     jr(i)=extreq(str)
;;     for j=0,nmod-1 do begin
;;         readf,lun,str
;;         spl=strsplit2(str,['m=','n=','rmn=','zmn='])
;;         marr(j)=extreq(spl(0))
;;         narr(j)=extreq(spl(1))
;;         rmn(i,j)=extreq(spl(2))
;;         zmn(i,j)=extreq(spl(3))
;;     endfor
;;     readf,lun,str
;;     spl=strsplit2(str,['rho=','1/q=','Vp='])
;;     rho(i)=extreq(spl(0))
;;     iota(i)=extreq(spl(1))
;;     vp(i)=extreq(spl(2))
;;     readf,lun,str
;;     spl=strsplit2(str,['b0=','et=','eh='])
;;     b0(i)=extreq(spl(0))
;;     et(i)=extreq(spl(1))
;;     eh(i)=extreq(spl(2))
;; ;    print,'done line ',i
;; endfor

pars={nrho:nrho,nmod:nmod,jr:jr,rho:rho,iota:iota,vp:vp,b0:b0,et:et,eh:eh,$
     n:narr,m:marr}
;close,lun
;free_lun,lun

end

;;goto,ee

rdflx,rmn,zmn,par,fil=fil


;phir=[-7.2,7.2*3]*!dtor
;nphi=6

phiarr=[-7.2,0,7.2,7.2*2,7.2*3,-105.44,60.,105.,167.5,225.]*!dtor
nphi=n_elements(phiarr)

;linspace(phir(0),phir(1),nphi-1)
;dphi=phiarr(1)-phiarr(0)
if n_elements(rout) ne 0 then begin
    dum=temporary(rout)
    dum=temporary(zout)
endif

for i=0,nphi-1 do begin
    phi=phiarr(i)
    del=2*!pi/3*0.01
;    stop
    invmap,rmn,zmn,par,rout,zout,rhogrid,$
           rcthgrid,rsthgrid,bxgrid,bygrid,bzgrid,phi=phi,r1=r1a,z1=z1a,rho1=rho1,theta1=theta1,nrho=nrho,ntheta=ntheta

    
    nz=n_elements(zout)
    nr=n_elements(rout)
    rout2 = rout # replicate(1,nz)
    zout2 = replicate(1,nr) # zout
    
    xout2 = rout2 * cos(phi)
    yout2 = rout2 * sin(phi)

    nr=n_elements(rout)
    nz=n_elements(zout)
    
    r2 = rout # replicate(1,nz)

    if i eq 0 then begin
        rhogrid3=fltarr(nr,nz,nphi)
        rcthgrid3=fltarr(nr,nz,nphi)
        rsthgrid3=fltarr(nr,nz,nphi)
        rax3=fltarr(nphi)
        zax3=fltarr(nphi)
        

        r1=fltarr(nrho,ntheta,nphi)
        z1=fltarr(nrho,ntheta,nphi)
    endif
;    stop
    rhogrid3(*,*,i)=rhogrid
    rcthgrid3(*,*,i)=rcthgrid
    rsthgrid3(*,*,i)=rsthgrid
    rax3(i)=mean(r1a(0,*))
    zax3(i)=mean(z1a(0,*))
    r1(*,*,i)=r1a
    z1(*,*,i)=z1a

print,i
endfor

;ee:

alpha=linspace(0,2*!pi,100)*0.001+!pi/2

c0=281.
c1=-2
fppos2, c0, c1, rlong,zlong,plong,alpha=alpha
fppos2, c0, c1, rshort,zshort,pshort,alpha=alpha,/short

rr2=[[rlong],[rshort]]*1e-3
zz2=[[zlong],[zshort]]*1e-3
pp2=[[plong],[pshort]]



ir=interpol(findgen(n_elements(rout)),rout,rr2);>0<(n_elements(rout)-1)
iz=interpol(findgen(n_elements(zout)),zout,zz2);>0<(n_elements(zout)-1)
ip=interpol(findgen(n_elements(phiarr)),phiarr,pp2);>0<(n_elements(phiarr)-1)

rhopts=interpolate(rhogrid3,ir,iz,ip,missing=!values.f_nan)
rcpts=interpolate(rcthgrid3,ir,iz,ip,missing=!values.f_nan)
rspts=interpolate(rsthgrid3,ir,iz,ip,missing=!values.f_nan)
thpts=atan(rspts,rcpts)


contour,sqrt(rhogrid3(*,*,2)),rout,zout,lev=[.5,.9],/iso
oplot,rr2,zz2,col=4,psym=4
;plot,rhopts
print,sqrt(rhopts(0,*))

ee:
spl=strsplit(fil,'/',/extract) & fna=spl(n_elements(spl)-1) 
fn=fna+'.sav'
base='/home/cmichael/idl/'
file=base+fn
save,rhogrid3,rcthgrid3,rsthgrid3,rout,zout,phiarr,r1,z1,rho1,theta1,file=file

end
