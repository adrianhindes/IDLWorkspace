

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
dum=min(abs(par.rho-0.85),imin)
plot,r1(imin,*)*1000,z1(imin,*)*1000,psym=3,title=phi*!radeg,xr=[0,4000.]
oplot,3812./2 *[1,1],!y.crange,col=2 ; tank outer
oplot, (3812/2+650)*[1,1],!y.crange,col=3 ; flange outer
oplot, (3812/2+650-280)*[1,1],!y.crange,col=4 ; probe outer
plots,[3812/2+135,75],psym=4,thick=5
print,'when probe is out most, position is at R=',(3812/2+650-280)
oplot,!x.crange,75*[1,1]

dy=150-75
dx=3812/2+135 - 1200.
theta=atan(dy/dx)*!radeg
print,'theta=',theta

poswant=1300.;1240
print,'put it by into',poswant-2276
print,'the length to the mark when ou tis',1237
print,'therefore put into position such that distance is ',1237- (2276-poswant)

;oplot,r1,z1,psym=3

stop
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
;file='/home/cam112/boozmn_h1ass027v1_0p83.nc'
file='/home/cam112/vmout/kh0.850-kv1.000fixed/boozmn_wout_kh0.850-kv1.000fixed.nc'
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
stop
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
;-search-

rdflx,rmn,zmn,par,fil=fil
    invmap,rmn,zmn,par,rout,zout,rhogrid,$
           rcthgrid,rsthgrid,bxgrid,bygrid,bzgrid,phi=7.2*!dtor;0;14.37*!dtor

end



