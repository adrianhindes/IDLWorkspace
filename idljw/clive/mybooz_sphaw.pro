

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
;rho2=(linspace(0,sqrt(1.4),n2))^2
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
    rmn2(*,i)=interpol(rmn(par.jlist,i),par.rho,rho2)
    zmn2(*,i)=interpol(zmn(par.jlist,i),par.rho,rho2)

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

nrho=n_elements(par.rho) < 20; /4 > 10
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



r1a=r1(nrho-1,*)
z1a=z1(nrho-1,*)
rexpan=0.08
makebiggerby,r1a,z1a,r1b,z1b,rexpan

p=[[r1(nrho-2:nrho-1,0)],[z1(nrho-2:nrho-1,0)]]
d=p(1,*)-p(0,*)
dist=norm(d)
delrho=rho1(nrho-1,0)-rho1(nrho-2,0)



r1=[r1,transpose(r1b)]
z1=[z1,transpose(z1b)]
router= rexpan / dist * delrho + 1

rho1=rho1 * max(rho1) / router
rho1=[rho1,transpose(replicate(1.,nth))]
theta1=[theta1,transpose(theta)]
plot,r1,z1,psym=3,/iso,title=phi*!radeg


triangulate,r1,z1,tri
gs=[0.03,0.03]/3.
default,limits,[0.6,-0.4,1.4,0.4]
if n_elements(rout) eq 0 then $
  rhogrid=trigrid(r1,z1,rho1,tri,gs,limits,xgrid=rout,ygrid=zout,missing=1.) else $
    rhogrid=trigrid(r1,z1,rho1,tri,gs,xout=rout,yout=zout,missing=1.)
rcthgrid=trigrid(r1,z1,rho1*cos(theta1),tri,gs,xout=rout,yout=zout)
rsthgrid=trigrid(r1,z1,rho1*sin(theta1),tri,gs,xout=rout,yout=zout)
print,'gs',gs,n_elements(rout),n_elements(zout)
;bxgrid=trigrid(r1,z1,bx1,tri,gs,xout=rout,yout=zout)
;bygrid=trigrid(r1,z1,by1,tri,gs,xout=rout,yout=zout)
;bzgrid=trigrid(r1,z1,bz1,tri,gs,xout=rout,yout=zout)

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
jlist=par.jlist(0:n_elements(par.jlist)-9)

nrho=n_elements(jlist)


nmod=n_elements(par.ixm_b)

;rmn=fltarr(nrho,nmod)
;zmn=fltarr(nrho,nmod)
narr=par.ixn_b;fltarr(nmod)
marr=par.ixm_b;fltarr(nmod)
jr=fltarr(nrho)
tmp=linspace(0,1,par.ns_b)
rho=tmp(jlist)
rho=linspace(0,1,nrho)
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
     n:narr,m:marr,jlist:jlist}
;close,lun
;free_lun,lun

end



goto,ee

rdflx,rmn,zmn,par,fil=fil
; interpolmn,rmn,zmn,par


phir=(352.8+[-0.05/5,0.05/5]*40.)*!dtor - 2*!pi
   ;[0,2*!pi/3.]
nphi=3;32;8;2;5.;*2

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
        rax3=fltarr(nphi)
        zax3=fltarr(nphi)
    endif
;    stop
    rhogrid3(*,*,i)=rhogrid
    rax3(i)=mean(r1a(0,*))
    zax3(i)=mean(z1a(0,*))

print,i
endfor


ee:
xax3=rax3* cos(phiarr)
yax3=rax3* sin(phiarr)



readpatch,99996,db='greg',str,nfr=1;9998
getptsnew,pts=pts,str=str,bin=1,/pptsonly,lene=[0,200.],nl=201,nx=nx,ny=ny,ix=ix1,iy=iy1,detx=detx,dety=dety
pts*=0.01 ; cm to m
dl = 0.01 ; 1cm dl
;stop
;plot,xax3,yax3,xr=[-2,2],yr=[-2,2],/iso
;oplot,pts(*,*,0),pts(*,*,1),col=2
;oplot,xax3,yax3

;for i=0,nphi-1 do oplot,rout*cos(phiarr(i)),rout*sin(phiarr(i)),col=3

ptsc=pts*0
ptsc(*,*,0)=sqrt(pts(*,*,0)^2+pts(*,*,1)^2)
ptsc(*,*,1)=atan(pts(*,*,1),pts(*,*,0))
ptsc(*,*,2)=pts(*,*,2) ;r,phi,z

np=10
;mkfig,'~/chord1.eps',xsize=8,ysize=10,font_size=10
contourn2,rhogrid3(*,*,1),rout,zout,/iso,xr=[1,1.6],xtitle='R (m)',ytitle='Z(m)'
for i=0,np-1 do oplot,ptsc(i,*,0),ptsc(i,*,2),col=4,thick=4
endfig,/gs,/jp
;stop

ir=interpol(findgen(n_elements(rout)),rout,ptsc(*,*,0));>0<(n_elements(rout)-1)
iz=interpol(findgen(n_elements(zout)),zout,ptsc(*,*,2));>0<(n_elements(zout)-1)
ip=interpol(findgen(n_elements(phiarr)),phiarr,ptsc(*,*,1));>0<(n_elements(phiarr)-1)
rhopts=interpolate(rhogrid3,ir,iz,ip,missing=!values.f_nan)
ix=where(finite(rhopts) eq 0)
wid=0.2
;inten=exp(-rhopts^2/wid^2)
;inten=exp(-(rhopts-0.8)^2 / 0.1^2)
a0=30*!dtor & dw=5*!dtor
inten=rhopts le 0.99 +0.*1;and rhopts ge 0.2


;inten=exp( - (rhopts-0.)^2 / 0.8^2 ) * (rhopts le 0.99)




;inten=exp( - (rhopts-0.7)^2 / 0.2^2 ) * (rhopts le 0.99)





;;here;;;

shot=88533
;stop
iframe=3 & radiance_model= 1e17;''5.5e17

iframe=7 & radiance_model = 3e17


iframe0=0

inten = inten * radiance_model



;inten0=(rhogrid3 le 0.99) * .1e17


idx=where(finite(inten) eq 0) & if idx(0) ne -1 then inten(idx)=0.
linten=total(inten,2) * dl
plot,linten
linten=rebin(linten,20)

;read_spe,'~/share/greg/ipad_1000ms_717nm.spe',l,t,d
;read_spe,'~/share/greg/calib  13.spe',l,t,d,str=strcal

read_spe,'~/calib  13.spe',l,t,d,str=strcal
lcal=reverse(l)
;this is 660nm

s=myrest2('~/ipad_radiance.sav')
s.rad=smooth(s.rad, 10)


spawn,'mv ~/footer.xml ~/footer_pw.xml'
factor0=totaldim(d(*,*,0),[0,0,1])/1. / strcal.texp / strcal.avgain
;stop
;factor0=rebin(factor0a,1024,20)*0.5 ; half for each one

rad0=interpol(s.rad,s.l,lcal) # replicate(1,20)
iradpercntrate= factor0/rad0

plot,lcal,iradpercntrate(*,10)  ; count rate per radiance

factor1 = iradpercntrate(512,*)

;factor=rebin(factor1,20) * 0.5 ;make half for eachone


;factor1=totaldim(d(512,*,50:70),[0,0,1])/21. / strcal.texp / strcal.avgain
;factor=rebin(factor1,20) * 0.5 ;make half for eachone

;read_spe,'~/share/greg/shaun_84063.spe',l,t,d & lc0=[706,728.,726.]
;read_spe,'~/share/greg/shaun_83996.spe',l,t,d & lc0=[706,728.,726.]
;read_spe,'~/share/greg/shaun_84071.spe',l,t,d & lc0=[706,728.,726.]
;read_spe,'~/share/greg/shaun_83982.spe',l,t,d,str=str &lc0=[658,668,656];667


;read_spe,'~/share/greg/shaun_88533.spe',l,t,d,str=str &lc0=[658,658,656.3];667

read_spedb,shot,l,t,d,str=str &lc0=[658,658,656.3];667

tspec=(gettiming(sh,nameunit='greg')  -1400.) / 1000.

;stop
d=d*1. / str.texp / str.avgain
l=reverse(l)





wid=1.
nl=n_elements(lc0)
nch=20
sig=fltarr(nch,nl)
dl=abs(l(1)-l(0))
for i=0,nl-1 do begin
   ix=where(l ge lc0(i)-wid/2 and l le lc0(i)+wid/2)
   sig(*,i) = (total(d(ix,*,iframe),1)*1. - total(d(ix,*,iframe0),1)*1.  ) * dl
   sig(*,i) = sig(*,i) / factor1
;   print,i,lc0(i)
   contourn2,d(ix,*,iframe),l(ix),indgen(20),/cb,title=i
   for j=0,19 do begin
      plot,d(ix,j,iframe)
      oplot,d(ix,j,iframe0),col=2
      oplot,d(ix,j,iframe)-d(ix,j,iframe0),col=3
;      if i eq 2 then stop
   endfor


endfor

;mkfig,'~/ha1.eps',xsize=11,ysize=9,font_size=10
plot,sig(*,2)>0,xtitle='channel #',ytitle=textoidl('radiance (ph/str/m^2/s)'),$
     title=textoidl('H_{\alpha} emissivity profile')
;linten=shift(linten,-1)

oplot,reverse(linten),col=4
legend,['measurement','model'],textcol=[1,4],/right,box=0
endfig,/gs,/jp



;assume path length of 1m -> emissiv is about 1e17 ph/s/m^3/str
;time 4pi -> 1e18 ph/s/m^3

;sxb order of 10 -> 1e19 /s/m^3
; flux is 0.5 * r * S
; which for r=0.1 makes 1e18 /s /m^2
;above 10eV sxbdoesn't changemuch from 10

flux = radiance_model * 4*!pi * 10 * 0.5 * 0.1

print,'the flux is',flux



stop
;plot,reverse(linten),/noer,col=4,xsty=4,ysty=4
;y
end
