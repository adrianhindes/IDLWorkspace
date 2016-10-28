

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

pro makes, s1, kr2,kth2,kr0=kr0,kth0=kth0,dkr=dkr,dkth=dkth,init=init,amp=amp
default,dkr,0.1
default,dkth,0.1
default,amp,1.
if (n_elements(s1) eq 0) or keyword_set(init) then begin
    print,'h'
    s1=kr2 & s1(*)=0.
endif
s1=s1+amp*exp(- (kr2-kr0)^2/dkr^2 - (kth2-kth0)^2/dkth^2 )
end

pro cartpol, proj, ang,mag

ang=atan(proj(*,1),proj(*,0))
mag=sqrt(proj(*,1)^2 + proj(*,0)^2)
idx=where(ang gt !pi/2)
if idx(0) ne -1 then begin
    ang(idx)=ang(idx)-!pi
    mag(idx)=-mag(idx)
endif

idx=where(ang le -!pi/2)
if idx(0) ne -1 then begin
    ang(idx)=ang(idx)+!pi
    mag(idx)=-mag(idx)
endif

end



pro plottraj,z,pr,x,y,over=over,color=color,ig=ig,_extra=_extra
if not keyword_set(ig) then x=pr(*,0)
if not keyword_set(ig) then y=pr(*,1)
np=5
n=n_elements(z)
ip=linspace(0,n-1,np)
if not keyword_set(over) then $
  plot,x,y,xr=[-1,1],yr=[-1,1],color=color,_extra=_extra else $
  oplot,x,y,color=color,_extra=_extra

oplot,x(ip),y(ip),psym=4,color=color
for i=0,np-1 do xyouts, x(ip),y(ip),string(z(ip),format='(G0.2)'),color=color,ali=0.5,charsize=0.8
end



function phase_jump,x
n=n_elements(x)
x2=x
idx=where(finite(x) eq 0)
if idx(0) ne -1 then x2(idx)=0.
y=phs_jump(x2)

z = y - y(n*0.6) + x(n*0.6)
return,z
end




pro plotvect,x,z,num=num,az=az,ax=ax,xr=xr,yr=yr,over=over,id=id,color=col,zlim=zlim,len=len
default,num,5
default,zlim,1.
y=fltarr(num,3)
n=n_elements(x(*,0))
zwant=linspace(-zlim,zlim,num)
iv=value_locate(z,zwant)
for i=0,2 do y(*,i)=x(iv,i)

z1=zwant
x1=fltarr(num)
y1=fltarr(num)

default,len,0.4
z2=z1+y(*,2)*len
y2=y1+y(*,1)*len
x2=x1+y(*,0)*len

;plot_3dbox,[x1,x2],[y1,y2],[z1,z2]
idx=where(finite(z2) eq 1)
z2=z2(idx)
y2=y2(idx)
x2=x2(idx)

z1=z1(idx)
y1=y1(idx)
x1=x1(idx)
num=n_elements(x1)

zr=minmax(z1)
default,yr,zr
default,xr,zr


if not keyword_set(over)  then iplot,x1,y1,z1,identifier=id,$
    xtitle='X',ytitle='Y',ztitle='Z',$
    xrange=xr,yrange=yr,zrange=zr

for i=0,num-1 do begin
    iplot,[x1(i),x2(i)],[y1(i),y2(i)],[z1(i),z2(i)],overplot=id,color=col,thick=2

endfor



;plot_3dbox,x1,y1,z1,xr=xr,yr=yr,zr=zr,thick=2,xtitle='x',ytitle='y',ztitle='z',$
;           az=az,ax=ax
;for i=0,num-1 do begin
;    plots,[x1(i),x2(i)],[y1(i),y2(i)],[z1(i),z2(i)],color=i+1,/t3d
;    plots,[x2(i)],[y2(i)],[z2(i)],color=i+1,/t3d,psym=4
;endfor




end


pro plot3,x,title=title
plot,x(*,0),yr=minmax(x(where(finite(x) eq 1))),title=title
oplot,x(*,1),col=2
oplot,x(*,2),col=3
end

function vabs,v
return,sqrt(v(0)^2 + v(1)^2 + v(2)^2)
end





pro invmap,rmn,zmn,par,rout,zout,rhogrid,$
           rcthgrid,rsthgrid,bxgrid,bygrid,bzgrid,phi=phi

default,nth,100
default,phi,0.

nrho=n_elements(par.rho)
r1=fltarr(nrho,nth)
z1=fltarr(nrho,nth)
rho1=fltarr(nrho,nth)
theta1=fltarr(nrho,nth)
theta=linspace(0,2*!pi,nth)
bx1=r1
by1=r1
bz1=r1

for i=0,nrho-1 do begin
    evalsurfb,rmn,zmn,par,rt,zt,i,bxt,byt,bzt,phi=phi,theta=theta
    r1(i,*)=rt
    z1(i,*)=zt
    bx1(i,*)=bxt
    by1(i,*)=byt
    bz1(i,*)=bzt

    rho1(i,*)=par.rho(i)
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
xa=reform(transpose([[x],[x2]]),200)
ya=reform(transpose([[y],[y2]]),200)
za=reform(transpose([[z],[z2]]),200)
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




pro evalsurf3,rmn,zmn,par,i,r,z,p,x,y,phi=phi,nth=nth,nphi=nphi,$
              partheta=partheta,$
              parphi=parphi
default,partheta,1.
default,parphi,0.
default,phi,0.
default,nth,36.
default,nphi,18.
theta1=(linspace(0,2*!pi,nth))
phi1=linspace(0,2*!pi/3.,nphi)
theta0=theta1 # replicate(1,nphi)
phi = replicate(1,nth) # phi1

theta =partheta * theta0 + parphi * phi


common cb,x1,y1,z1,b1
r=fltarr(nth,nphi)
z=fltarr(nth,nphi)
b=fltarr(nth,nphi)
b=par.b0(i) + par.eh(i) * cos(2*theta - 3*phi) + $
              par.et(i) * cos(1*theta - 0*phi)

for j=0,par.nmod-1 do begin
    r=r+rmn(i,j)*cos(par.m(j)*theta-par.n(j)*phi)
    z=z+zmn(i,j)*sin(par.m(j)*theta-par.n(j)*phi)
endfor
x=r*cos(phi)
y=r*sin(phi)
x1=x
y1=y
z1=z
b1=b

;surface,x,y,z

;isurface,z,x,y
;stop
;plot,r,z,title=i,/iso
end


pro plotsurf,rmn,zmn,par,phi=phi,nth=nth
default,nth,100
r=fltarr(nth,par.nrho)
z=fltarr(nth,par.nrho)
for i=0,par.nrho-1 do begin
    evalsurf,rmn,zmn,par,r1,z1,i,phi=phi,nth=nth
    r(*,i)=r1
    z(*,i)=z1
endfor
plot,r,z,psym=3,/iso,/nodata
for i=0,par.nrho-1 do oplot,r(*,i),z(*,i),col=i+1

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

pro rdflx, rmn,zmn, pars,file=fil

;file='/home/cam112/boozmn_h1ass027v1_0p02.nc'
file='/home/cam112/boozmn_h1ass027v1_0p83.nc'

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
jlist=par.jlist(0:n_elements(par.jlist)-7)
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

pro auto
;goto,aa

;rax=3.70
;raxmag=3.75
rax=3.75
raxmag=3.75
;betas=1.3
;path='\\egftp1.lhd.nifs.ac.jp\ftp\pub\geom\flx\r'
path='C:\Documents and Settings\cmichael\Desktop\flx\r'+string(rax*100,format='(I0)')+'\'

fils=findfile(path+'*a8020.flx')
srt=sort(fils)
fils=fils(srt)
nf=n_elements(fils)
tk=fltarr(nf)
beta=fltarr(nf)
for i=0,nf-1 do begin
    spl=strsplit(fils(i),'\',/extr)
    nspl=n_elements(spl)
    tf=spl(nspl-1)
    nlen=strlen(tf)
    tk(i)=1
    beta(i)=float(strmid(tf,strpos(tf,'b')+1,3))/100.
endfor

for i=0,nf-1 do begin
    rdflux_new2g,fils(i),beta(i),rax,raxmag
endfor

end


;pro mybooz2
;pro rdflux_new2g, fil,beta,rax,raxmag
;print,'beta=',beta
rdflx,rmn,zmn,par,fil=fil
;interpolmn,rmn,zmn,par

;;par.n=-par.n


;xt  = 1250e-3
;yt = 50e-3
;zt  = 500e-3
;bottom
;xb = 1250e-3
;yb  =-50e-3
;zb  = -500e-3









xb  = 1590e-3
yb = 0e-3
zb  = 0e-3

xt = 1000e-3*1/sqrt(2)
yt  =1000e-3*1/sqrt(2)
zt  = 300e-3

lhat=[xt,yt,zt]-[xb,yb,zb]
lhat=lhat/vabs(lhat)

xt=xb + lhat(0) * 1.5
yt=yb + lhat(1)* 1.5
zt=zb + lhat(2)* 1.5

ang=atan((yt-yb)/(zt-zb))
print,ang*!radeg




np=1000

xsel=linspace(xb,xt,np)
ysel=linspace(yb,yt,np)
zsel=linspace(zb,zt,np)

lhat=[xt,yt,zt]-[xb,yb,zb]
lhat=lhat/vabs(lhat)

ix=where(abs(zsel) lt 1.5)
xsel=xsel(ix) & ysel=ysel(ix) & zsel=zsel(ix) & nsel=n_elements(ix)

rsel=sqrt(xsel^2+ysel^2)
phisel = phs_jump(atan(ysel,xsel))


;nsel=100
;rsel=replicate(4.0,nsel)
;zsel=linspace(-1,1,nsel)
r0=rsel
z0=zsel
p0=phisel


;goto,aaa

phir=minmax(phisel)

;stop

nphi=8;2;5.;*2

phiarr=linspace(phir(0),phir(1),nphi)
dphi=phiarr(1)-phiarr(0)
if n_elements(rout) ne 0 then begin
    dum=temporary(rout)
    dum=temporary(zout)
endif

for i=0,nphi-1 do begin
    phi=phiarr(i)
    del=2*!pi/3*0.01
;    stop
    invmap,rmn,zmn,par,rout,zout,rhogrid,$
           rcthgrid,rsthgrid,bxgrid,bygrid,bzgrid,phi=phi

    invmap,rmn,zmn,par,rout,zout,rhogrid2,$
       rcthgrid2,rsthgrid2,bxgrid2,bygrid2,bzgrid2,phi=phi+del
    
    nz=n_elements(zout)
    nr=n_elements(rout)
    rout2 = rout # replicate(1,nz)
    zout2 = replicate(1,nr) # zout
    
    xout2 = rout2 * cos(phi)
    yout2 = rout2 * sin(phi)
    calcmag,xout2,yout2,zout2,bxgrid2,bygrid2,bzgrid2;,rax=raxmag
    n1=sqrt(bxgrid^2+bygrid^2+bzgrid^2)
    bxgrid/=n1
    bygrid/=n1
    bzgrid/=n1
    n2=sqrt(bxgrid2^2+bygrid2^2+bzgrid2^2)
    bxgrid2/=n2
    bygrid2/=n2
    bzgrid2/=n2

;    stop
    bxgrid=bxgrid2
    bygrid=bygrid2
    bzgrid=bzgrid2

;    bxgrid=xout2*0
;    bygrid=bxgrid
;    bzgrid=bxgrid


    nr=n_elements(rout)
    nz=n_elements(zout)
    gr_r=fltarr(nr,nz)
    gr_z=fltarr(nr,nz)
    gr_phi=fltarr(nr,nz)
    
    r2 = rout # replicate(1,nz)

    for j=0,nz-1 do gr_r(*,j)=deriv(rout,rhogrid(*,j))
    for j=0,nr-1 do gr_z(j,*)=deriv(zout,rhogrid(j,*))
    gr_phi = (rhogrid2-rhogrid)/del/r2
    gr_x= gr_r * cos(phi) - gr_phi * sin(phi)
    gr_y= gr_r * sin(phi) + gr_phi * cos(phi)

    if i eq 0 then begin
        rhogrid3=fltarr(nr,nz,nphi)
        bxgrid3= fltarr(nr,nz,nphi)
        bygrid3= fltarr(nr,nz,nphi)
        bzgrid3= fltarr(nr,nz,nphi)
        gr_x3= fltarr(nr,nz,nphi)
        gr_y3= fltarr(nr,nz,nphi)
        gr_z3= fltarr(nr,nz,nphi)
    endif

    rhogrid3(*,*,i)=rhogrid
    bxgrid3(*,*,i)=bxgrid
    bygrid3(*,*,i)=bygrid
    bzgrid3(*,*,i)=bzgrid
    gr_x3(*,*,i)=gr_x
    gr_y3(*,*,i)=gr_y
    gr_z3(*,*,i)=gr_z
print,i
endfor

aaa:
;stop

rhogridm=fltarr(nr,nz)
i1a=fltarr(nr,nz)
i2a=fltarr(nr,nz)
i3a=fltarr(nr,nz)
for i=0,nr-1 do i1a(i,*)=i
for i=0,nz-1 do i2a(*,i)=i

phiofz=interpol(phisel,zsel,zout)
iphiofz=interpol(findgen(nphi),phiarr,phiofz)

for i=0,nr-1 do i3a(i,*)=iphiofz


rhogridm=interpolate(rhogrid3,i1a,i2a,i3a)


i1=interpol(findgen(n_elements(rout)),rout,rsel)
i2=interpol(findgen(n_elements(zout)),zout,zsel)
i3=interpol(findgen(n_elements(phiarr)),phiarr,phisel)


;stop

dotp=fltarr(nsel)
bhat=fltarr(nsel,3)
rhat=fltarr(nsel,3)
thhat=fltarr(nsel,3)
dotp=fltarr(nsel)
mag1=fltarr(nsel)
mag2=fltarr(nsel)
bhat(*,0)=interpolate(bxgrid3,i1,i2,i3)
bhat(*,1)=interpolate(bygrid3,i1,i2,i3)
bhat(*,2)=interpolate(bzgrid3,i1,i2,i3)
rho1=interpolate(rhogrid3,i1,i2,i3,missing=1.)
rhat(*,0)=interpolate(gr_x3,i1,i2,i3)
rhat(*,1)=interpolate(gr_y3,i1,i2,i3)
rhat(*,2)=interpolate(gr_z3,i1,i2,i3)


;stop
;for i=0,nsel-1 do dotp(i)=total(bhat(i,*)*rhat(i,*))/ $
;                              sqrt(total(bhat(i,*)^2))/$
;                              sqrt(total(rhat(i,*)^2))

;stop
       
ix=where(rho1 lt 1.09)
rho1=rho1(ix)
z0=z0(ix)
n0=n_elements(ix)
nsel=n0
bhat=bhat(ix,*)
thhat=thhat(ix,*)
rhat=rhat(ix,*)


bigx = [1.,0.,0.]
bigz=  lhat;[0.,0.,1.]
bigx = bigx - total(bigx * lhat) * lhat
bigy=crossp(lhat,bigx)


;bigy = [0.,1.,0.]

n0=nsel
projth=fltarr(n0,3)
projr =fltarr(n0,3)
projb =fltarr(n0,3)
projr_p=fltarr(n0)
projth_p=fltarr(n0)
a_projth=fltarr(n0)
a_projr=fltarr(n0)
a_projb=fltarr(n0)
m_projth=fltarr(n0)
m_projr=fltarr(n0)
m_projb=fltarr(n0)


for i=0,nsel-1 do begin
    bhat(i,*)=bhat(i,*)/vabs(bhat(i,*))
    rhat(i,*)=rhat(i,*)/vabs(rhat(i,*))
;    dotp(i)=total(bhat(i,*) * rhat(i,*))
    mag1(i)=vabs(bhat(i,*))
    mag2(i)=vabs(rhat(i,*))
    thhat(i,*)=crossp(bhat(i,*),rhat(i,*)) ;* rhat(i,2)/abs(rhat(i,2))

    projth(i,0) = total(thhat(i,*) * bigx)
    projth(i,1) = total(thhat(i,*) * bigy)
    projth(i,2) = total(thhat(i,*) * bigz)

    projr(i,0) = total(rhat(i,*) * bigx)
    projr(i,1) = total(rhat(i,*) * bigy)
    projr(i,2) = total(rhat(i,*) * bigz)

    projb(i,0) = total(bhat(i,*) * bigx)
    projb(i,1) = total(bhat(i,*) * bigy)
    projb(i,2) = total(bhat(i,*) * bigz)
    
    phat=crossp(projb(i,*),[0,0,1])
    phat=phat/vabs(phat)
    projth_p(i)=total(projth(i,*) * phat)
    projr_p(i)=total(projr(i,*) * phat)

endfor

a:

cartpol,projr,ar,mr
cartpol,projth,ath,mth

;projbp(*,1)=-1/projb(*,0)
;projbp(*,0)=projb(*,1)
;cartpol,projbp,abp,mbp
cartpol,projb,ab,mb

ab=amod2(ab-!pi/2)

plot,rho1
plot,ab,/noer,col=2

stop
mat=fltarr(3,2,n0)
mats=fltarr(2,2,n0)
for i=0,n0-1 do begin

    mats(0,0,i)=projr_p(i)
    mats(0,1,i)=projth_p(i)
    mats(1,0,i)=projr(i,2)
    mats(1,1,i)=projth(i,2)

    mat(*,0,i)=projr(i,*)
    mat(*,1,i)=projth(i,*)
;    mat(*,2,i)=projb(i,*)

endfor

;plot,projr(*,2),projth(*,2),psym=4,/iso,xtit='r',ytit='th'
;plot,zsel,atan(projr(*,2)/projth(*,2))*!radeg,psym=4

matw=mat(*,*,10)
matws=(mats(*,*,10))

;i=2
;!p.multi=[0,1,2]
;plot,[-1,1],[-1,1],/nodata,/iso
;for i=0,2 do oplot,[0,matw(i,0)],[0,matw(i,1)],col=i+1;;
plot,[-1,1],[-1,1],/nodata,/iso
for i=0,1 do oplot,[0,matws(i,0)],[0,matws(i,1)],col=i+1
;!p.multi=0
;stop

aa:


;mkfig,'c:\flx1c.eps',xsize=12,ysize=12
endfig


;stop


nr=30
nth=30
kr=linspace(-1,1,nr)
kth=linspace(-1,1,nth)

kr2=kr # replicate(1,nth)
kth2=replicate(1,nr) # kth
makes, s, kr2,kth2,kr0=-0.5, kth0=0.5,dkr=0.3,dkth=0.3,/init
makes, s, kr2,kth2,kr0=0.5, kth0=0.5,dkr=0.3,dkth=0.3


pos0=[0.3,0.3,0.7,0.7]
pos1=[.3,.7,.7,.9]
pos2=[.7,.3,.9,.7]
pos3=[.7,.7,1.0,1.0]
;!p.multi=[0,1,2]
;mkfig,'c:\f1.eps',xsize=12,ysize=12
contour, s, kr,kth,pos=pos0,xtitle=textoidl('k_r'),ytitle=textoidl('k_{\theta}')
plot,kr,total(s,2),pos=pos1,/noer,xtickname=replicate(' ',5),ytitle=textoidl('S(k_r)')
plot,total(s,1),kth,pos=pos2,/noer,ytickname=replicate(' ',5),xtitle=textoidl('S(k_{\theta})')
endfig


;stop

kx=kr
ky=kth
;th=30*!dtor
;rotmat=[[cos(th),sin(th)],[-sin(th),cos(th)]]
;rotmat=mat(*,*,20)
;rhatz=projr(iw,2)
;thhatz=projr(iw,2)


;
;mat= [[rhatz, thhatz],[rhatp,thhatp]]

angarr=fltarr(n0)
angarr2=fltarr(n0)
ratarr=angarr
for ii=0,n0-1 do begin
    matws=mats(*,*,ii)
    ratarr(ii)=matws(0,0)/matws(0,1)
    angarr(ii)=atan(matws(0,0)/matws(0,1))
    angarr2(ii)=atan(matws(0,1)/matws(0,0))
endfor

;bpitch=atan(projb(*,2)/sqrt(projb(*,1)^2 + projb(*,0)^2 ) )
bpitch=atan(-projb(*,0), -projb(*,1) )
bpitch2=atan(projb(*,0), projb(*,1) )

;mkfig,'c:\a1c.eps',xsize=12,ysize=12,font_size=14


!p.multi=[0,1,2]
plot,zsel,bpitch2*!radeg
plot,rho1,bpitch2*!radeg
!p.multi=0

;plot,bpitch*!radeg,angarr2*!radeg,xtitle='horiz. pitch',ytitle='ang. kr/kth',$
;     xr=[-10,20],yr=[-40,40],title=string('R=',bigr)
;getsl

rhocrit=0.99
idx=where(rho1 lt rhocrit)
thlim=max(abs(bpitch2(idx)))
thlim=70*!dtor
ni=200
bpitchi=linspace(-thlim,thlim,ni)
rhoi=interpol(rho1(idx),bpitch2(idx),bpitchi)
z0i=interpol(z0(idx),bpitch2(idx),bpitchi)

!p.multi=[0,2,1]
tit=string(rax,beta,format='("rax=",G0," beta=",G0)')
contour,rhogridm,rout,zout,lev=[0.2,.4,.6,.8,0.95,0.99],/follow,/iso,$
        xtitle='R',ytitle='Z',c_lab=replicate(1,5),title=tit

oplot,r0,z0,thick=2,col=2

plot,bpitchi*!radeg,rhoi
oplot,bpitch2*!radeg,rho1,thick=2,col=2
!p.multi=0
;stop
save,bpitchi,rhoi,z0i,file=string(rax*100,beta*100,format='("c:\bpitch_r",I3.3,"b",I3.3,".sav")'),/verb

return

;stop


plot,rho1,angarr*!radeg,xtitle=textoidl('\rho'),$
     ytitle=textoidl('tan^{-1}(k_{\theta}/k_{r}) (deg)'),xr=[0,1],yr=[-90,90],$
     title=tit
;oplot,-rho1*z0/abs(z0),angarr*!radeg,col=2
endfig
stop


for ii=0,n0-1 do begin
    matws=mats(*,*,ii)
;    s2=trgrid( s, kr, kth, kx, ky, matws,xw=xw,yw=yw)


;if ii eq 5 then mkfig,'c:\f2a.eps',xsize=12,ysize=12
;if ii eq fix(n0*0.4) then mkfig,'c:\f2b.eps',xsize=12,ysize=12
;if ii eq n0/2 then mkfig,'c:\f2c.eps',xsize=12,ysize=12

contour, s2, kx,ky,pos=pos0,xtitle=textoidl('k_p'),ytitle=textoidl('k_{z}')
for i=0,1 do oplot,[0,matws(i,0)],[0,matws(i,1)],col=i+2
plot,kr,s2(*,value_locate(ky,0)),pos=pos1,/noer,xtickname=replicate(' ',5),ytitle=textoidl('S(k_p,k_z=0)')
plot,total(s2,1),kth,pos=pos2,/noer,ytickname=replicate(' ',5),xtitle=textoidl('S(k_{z})')
endfig

;stop

;contour, s2, kx,ky,pos=pos0,xtitle='kp',ytitle='kz',title=ii
;plot,kx,s2(*,value_locate(ky,0)),pos=pos1,/noer ;total(s2,2)
;plot,total(s2,1),ky,pos=pos2,/noer

;plot,[-1,1],[-1,1],/nodata,/iso,pos=pos3,/noerase
;for i=0,1 do oplot,[0,matws(i,0)],[0,matws(i,1)],col=i+1

endfig


plot,angarr
;stop
;wait,0.1

endfor






;,/t3d,position=[0,0,1,1],/iso
;         ,/t3d ;
;axis,0,0,xaxis=0;,xtitle=textoidl('k_{r}')
;axis,0,0,yaxis=0;,ytitle=textoidl('k_{\theta}')


;         xticklen=1,yticklen=1,xticks=2,xtickv=[0,0],yticks=2,ytickv=[0,0],$
         

end



