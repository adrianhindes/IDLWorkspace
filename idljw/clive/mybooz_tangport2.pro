

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
           rcthgrid,rsthgrid,bxgrid,bygrid,bzgrid,phi=phi,r1=r1,z1=z1

default,nth,30;100
default,phi,0.

nrho=5;n_elements(par.rho)
irhoarr=fix(linspace(0,n_elements(par.rho)-1,nrho))
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
  rhogrid=trigrid(r1,z1,rho1,tri,gs,limits,xgrid=rout,ygrid=zout,missing=1.) else $ ;,nx=121,ny=121
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

goto,ee

rdflx,rmn,zmn,par,fil=fil


phir=[-!pi,!pi]
nphi=32*4;*4;8;2;5.;*2

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
           rcthgrid,rsthgrid,bxgrid,bygrid,bzgrid,phi=phi,r1=r1a,z1=z1a

    
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
        bxgrid3=fltarr(nr,nz,nphi)
        bygrid3=fltarr(nr,nz,nphi)
        bzgrid3=fltarr(nr,nz,nphi)
        rax3=fltarr(nphi)
        zax3=fltarr(nphi)
    endif
;    stop
    rhogrid3(*,*,i)=rhogrid
    rcthgrid3(*,*,i)=rcthgrid
    rsthgrid3(*,*,i)=rsthgrid
    bxgrid3(*,*,i)=bxgrid
    bygrid3(*,*,i)=bygrid
    bzgrid3(*,*,i)=bzgrid
    rax3(i)=mean(r1a(0,*))
    zax3(i)=mean(z1a(0,*))

print,i
endfor


ee:
xax3=rax3* cos(phiarr)
yax3=rax3* sin(phiarr)

;readpatch,9999,db='h1up',str,nfr=1
;readpatch,9999,db='h1ant',str,nfr=1
;readpatch,9999,db='h1an2',str,nfr=1
if n_elements(ix1) ne 0 then dum=temporary(ix1)
if n_elements(iy1) ne 0 then dum=temporary(iy1)
nl=201
;str=(myrest2('~/idl/clive/nleonw/tang_port/irset_mod.sav')).(0)
;str=(myrest2('~/idl/clive/nleonw/tang_port/irset3.sav')).(0) 

;str=(myrest2('~/idl/clive/nleonw/timg28/irset.sav')).(0) 
;str=(myrest2('~/idl/clive/nleonw/timgtry1/irset.sav')).(0) 
str=(myrest2('~/idl/clive/nleonw/timgtry2/irset.sav')).(0) 

;str=(myrest2('~/idl/clive/nleonw/timg200/irset.sav')).(0) 

;str.rad=1.800;1.670 - .150
;str.rad=2.05
;str.rad=1.8
;str.flen/=2
;str.rad=1.55
;str.tor+=1.5
;str.hei-=0.03
;str.yaw=0
;str.pit=0
;str.hei=0
;str.rad=2.0
;str.hei=-0.05
view=str

mapstr=fltarr(14)
x=[0,0,0,0,$
       str.flen,str.rad,str.tor,str.hei,str.yaw,str.pit,str.rol,str.dist,str.distcx,str.distcy]

mapstr=x

;str={roir:4000,roil:1,roit:3000,roib:1,pixsizemm:6.17/4000,binx:1,biny:1,mapstr:mapstr} & bin=50

str={roir:1376,roil:1,roit:1160,roib:1,pixsizemm:6.5e-3,binx:1,biny:1,mapstr:mapstr} & bin=32

nl=201
getptsnew,pts=pts,str=str,bin=bin,/pptsonly,lene=[0,300],nl=nl,nx=nx,ny=ny,detx=detx,dety=dety,ix=ix1,iy=iy1,leno=len1
dl = 0.01

len1 = len1* 10;compatible with zb

ptst=transpose(pts,[2,0,1])*10.
refl_t,ptst,ptsr;,/doplot
;ptsr=ptst

pts=0.1 * transpose(ptsr,[1,2,0])


efl=str.mapstr(4)
thx1=atan(detx/efl)
thy1=atan(dety/efl)
;thx2=thx1 # replicate(1,ny)
;thy2 = replicate(1,nx) # thy1




pts*=0.01 ; cm to m


;ss=myrest2('~/idl/clive/nleonw/midport/objhidden_zb.sav')
;ss=myrest2('~/idl/clive/nleonw/antport/objhidden_zb.sav')
;ss=myrest2('~/idl/clive/nleonw/timgtry1/objhidden_zb.sav')
ss=myrest2('~/idl/clive/nleonw/timgtry2/objhidden_zb.sav')

iiix=interpol(findgen(n_elements(ss.x1)),ss.x1,thx1)
iiiy=interpol(findgen(n_elements(ss.y1)),ss.y1,thy1)

zb=interpolate(ss.zb,iiix,iiiy,/grid)
zb2=reform(zb,nx*ny)
zb3=zb2 # replicate(1,nl)

ixx = len1 le zb3

;plot,xax3,yax3,xr=[-2,2],yr=[-2,2],/iso
;oplot,pts(*,*,0),pts(*,*,1),col=2
;oplot,xax3,yax3

for i=0,nphi-1 do oplot,rout*cos(phiarr(i)),rout*sin(phiarr(i)),col=3

ptsc=pts*0
ptsc(*,*,0)=sqrt(pts(*,*,0)^2+pts(*,*,1)^2)
ptsc(*,*,1)=atan(pts(*,*,1),pts(*,*,0))
ptsc(*,*,2)=pts(*,*,2) ;r,phi,z
ir=interpol(findgen(n_elements(rout)),rout,ptsc(*,*,0));>0<(n_elements(rout)-1)
iz=interpol(findgen(n_elements(zout)),zout,ptsc(*,*,2));>0<(n_elements(zout)-1)
ip=interpol(findgen(n_elements(phiarr)),phiarr,ptsc(*,*,1));>0<(n_elements(phiarr)-1)
rhopts=interpolate(rhogrid3,ir,iz,ip,missing=!values.f_nan)
rcpts=interpolate(rcthgrid3,ir,iz,ip,missing=!values.f_nan)
rspts=interpolate(rsthgrid3,ir,iz,ip,missing=!values.f_nan)
thpts=atan(rspts,rcpts)

bxpts=interpolate(bxgrid3,ir,iz,ip,missing=!values.f_nan)
bypts=interpolate(bygrid3,ir,iz,ip,missing=!values.f_nan)
bzpts=interpolate(bzgrid3,ir,iz,ip,missing=!values.f_nan)

nlines=n_elements(pts(*,0,0))
lvec=fltarr(nlines,3)
bdot=fltarr(nlines,nl)
bdotmax=fltarr(nlines)

dodot=0
if dodot eq 1 then begin
for i=0,nlines-1 do begin
   tmp=reform(pts(i,nl-1,*)-pts(i,nl-2,*))
   tmp=tmp/norm(tmp)
   lvec(i,*)=tmp
   for j=0,nl-1 do begin
      bvec=reform([bxpts(i,j),bypts(i,j),bzpts(i,j)])
      bvec=bvec / norm(bvec)
      bdot(i,j)=total(bvec * tmp)
   endfor
   bdotmax(i)=max(bdot(i,*),/nan)

endfor
endif
ix=where(finite(rhopts) eq 0)
wid=0.2
;inten=exp(-rhopts^2/wid^2)
;inten=exp(-(rhopts-0.8)^2 / 0.1^2)
a0=150*!dtor & dw=2*!dtor * 1000
;a0=113.*!dtor & dw=45.*!dtor
a0r=0.35
a0w=0.4
;inten=rhopts le 0.9 and rhopts ge 0.7 and ptsc(*,*,1) ge a0-dw/2 and ptsc(*,*,1) le a0+dw/2
;inten=(rhopts le 0.99) * 1e17 ;* exp(-(rhopts - a0r)^2 / a0w^2) * exp(- (ptsc(*,*,1)-a0)^2/dw^2)

;mm=8.*2 & nn=6.*2
;mm=
;mm=3.
;nn=2.
;mm=7.
;nn=5.

mm=3
nn=4
inten=exp(-(rhopts - a0r)^2 / a0w^2) * cos(mm*thpts +nn* ptsc(*,*,1)) * (rhopts lt 0.99) * exp(- (ptsc(*,*,1)-a0)^2/dw^2)

;inten=float(rhopts le 0.9  and ptsc(*,*,1) ge a0-dw/2 and ptsc(*,*,1) le a0+dw/2)

; *1e17;* exp(- (ptsc(*,*,1)-a0)^2/dw^2)


; and ge a0-dw/2 and ptsc(*,*,1) le a0+dw/2) 
;inten = (0.5 + rhopts*0.5) * (rhopts le 0.95)
inten(ix)=0.

intenb = inten ;* ixx ; mask where path length is less than obstruction

linten=total(intenb,2) * dl
linten2=reform(linten,nx,ny)

bdotmax2=reform(bdotmax,nx,ny)

;lintenb=total(intenb,2) * dl
;lintenb2=reform(lintenb,nx,ny)

;fname='~/idl/clive/nleonw/tang_port/DSCF2382.PNG'
;d0=read_png(fname)
;imgplot,d0,zr=[0,30],pos=posarr(1,1,0),/rev

imgplot,linten2,ix1,iy1,/cb,pal=-2,/iso;,pos=posarr(2,1,0)
;imgplot,acos(bdotmax2)*!radeg,ix1,iy1,/cb,/iso,pos=posarr(/next),/noer

;lns0=(myrest2('~/idl/clive/nleonw/tang_port/objhidden_mirr_6.sav')).(0)
;lns1=(myrest2('~/idl/clive/nleonw/tang_port/objhidden6.sav')).(0)

;lns0=(myrest2('~/idl/clive/nleonw/tang_port/objhidden_mirr_5.sav')).(0)
;lns1=(myrest2('~/idl/clive/nleonw/timgtry1/objhidden.sav')).(0)
lns1=(myrest2('~/idl/clive/nleonw/timgtry2/objhidden.sav')).(0)


;lns0=(myrest2('~/idl/clive/nleonw/tang_port/objhidden_mirr_5.sav')).(0)
;lns1=(myrest2('~/idl/clive/nleonw/timg200/objhidden4.sav')).(0)

;lns=[[[lns0]],[[lns1]]]
lns=lns1 & lns0=lns1
nn2=n_elements(lns0(0,0,*))
;lns=lns0
nn=n_elements(lns(0,0,*))
transcl, lns,view
lns=lns(0:1,*,*)
lns=tan(lns) * efl /str.pixsizemm 
lns(0,*,*)+=str.roir/2
lns(1,*,*)+=str.roit/2
for i=0,nn-1 do begin
cond=1
for j=0,1 do begin
   for k=0,1 do begin
   for lim=0,1 do begin
      if lim eq 0 and j eq 0 then cond1 = lns(j,k,i) ge 0
      if lim eq 1 and j eq 0 then cond1 = lns(j,k,i) lt str.roir
      if lim eq 0 and j eq 1 then cond1 = lns(j,k,i) ge 0
      if lim eq 1 and j eq 1 then cond1 = lns(j,k,i) lt str.roit
      cond=cond and cond1
   endfor
endfor
endfor
if i le nn2-1 then cond=1
if i le nn2-1 then col=4 else col=3
if cond eq 1 then  oplot,lns(0,0:1,i),lns(1,0:1,i),col=col,thick=3
for k=0,1 do plots,lns(0,k,i),lns(1,k,i),col=col,psym=4
;contour,linten2,ix1,iy1,pos=posarr(/cur),/noer,c_col=replicate(2,100),nl=30
endfor


;   /usr/local/exelis/idl85/lib/xmanager.pro
;IDL> cursor,dx,dy,/down & print,dx,dy
;     -0.24115082      0.79795120
;IDL> cursor,dx,dy,/down,/device & print,dx,dy
;         218         875
;IDL> cursor,dx,dy,/down,/device & print,dx,dy
;         409         252
;IDL> cursor,dx,dy,/down,/device & print,dx,dy
;         831         846

;pts=[$
;[         218     ,    875],$
;[         409     ,    252],$
;[         831     ,    846]] ; for try1

pts=[$
[         291,         257],$
[         555,         862],$
[         875,         301]] ; for try2

findcirc, pts,cen,diam

th=linspace(0,360,100)*!dtor

xx=cen(0)+diam/2*cos(th)
yy=cen(1)+diam/2*sin(th)
oplot,xx,yy

;for i=0,nn-1 do begin
;   oplot,lns0(0,0:1,i),lns0(1,0:1,i),col=4,thick=3




end
