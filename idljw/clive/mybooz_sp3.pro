

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
;stop
;close,lun
;free_lun,lun

end



if n_elements(rhogrid3) ne 0 then goto,ee

rdflx,rmn,zmn,par,fil=fil


phir=(352.8+[-0.05,0.05]*40.)*!dtor - 2*!pi
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



readpatch,99997,db='greg',str,nfr=1
str.mapstr[5] -= 0.015;rout by
getptsnew,pts=pts,str=str,bin=1,/pptsonly,lene=[0,200.],nl=201,nx=nx,ny=ny,ix=ix1,iy=iy1,detx=detx,dety=dety



str0=str
pts*=0.01 ; cm to m

;stop
;plot,xax3,yax3,xr=[-2,2],yr=[-2,2],/iso
;oplot,pts(*,*,0),pts(*,*,1),col=2
;oplot,xax3,yax3

;for i=0,nphi-1 do oplot,rout*cos(phiarr(i)),rout*sin(phiarr(i)),col=3

;stop

ptsc=pts*0
ptsc(*,*,0)=sqrt(pts(*,*,0)^2+pts(*,*,1)^2)
ptsc(*,*,1)=atan(pts(*,*,1),pts(*,*,0))
ptsc(*,*,2)=pts(*,*,2) ;r,phi,z

np=10
;for i=0,np-1 do oplot,ptsc(i,*,0),ptsc(i,*,2)
;stop

ir=interpol(findgen(n_elements(rout)),rout,ptsc(*,*,0));>0<(n_elements(rout)-1)
iz=interpol(findgen(n_elements(zout)),zout,ptsc(*,*,2));>0<(n_elements(zout)-1)
ip=interpol(findgen(n_elements(phiarr)),phiarr,ptsc(*,*,1));>0<(n_elements(phiarr)-1)
rhopts=interpolate(rhogrid3,ir,iz,ip,missing=!values.f_nan)
ix=where(finite(rhopts) eq 0)

;inten=exp(-rhopts^2/wid^2)
;inten=exp(-(rhopts-0.8)^2 / 0.1^2)
a0=30*!dtor & dw=5*!dtor
inten=rhopts le 0.8 ;and rhopts ge 0.2
;inten=exp( - (rhopts-0.7)^2 / 0.2^2 ) * (rhopts le 0.99)

inten=exp( - (rhopts-0.6)^2 / 0.1^2 ) * (rhopts le 0.8)
idx=where(finite(inten) eq 0) & if idx(0) ne -1 then inten(idx)=0.
linten=total(inten,2)
;plot,linten
;linten=rebin(linten,20)

;read_spe,'~cmichael/share/greg/ipad_1000ms_717nm.spe',l,t,d
;read_spe,'~cmichael/share/greg/ipad_500ms_portwin_wed.spe',l,t,d
read_spe,'~cmichael/share/greg/tshot  32.spe',l,t,d,str=str
;stop
spawn,'mv ~/footer.xml ~/footer_pw.xml'
factor1=totaldim(d(512,*,*),[0,0,1])/21.
factor1/=max(factor1)
factor=factor1;rebin(factor1,20)
;read_spe,'~cmichael/share/greg/shaun_84063.spe',l,t,d & lc0=[706,728.,726.]
;read_spe,'~cmichael/share/greg/shaun_83996.spe',l,t,d & lc0=[706,728.,726.]
;read_spe,'~cmichael/share/greg/shaun_84071.spe',l,t,d & lc0=[706,728.,726.]
;read_spe,'~cmichael/share/greg/shaun_900001.spe',l,t,d,st=str &lc0=[488,488,484]
;read_spe,'~cmichael/share/greg/shaun_900001.spe',l,t,d,st=str &lc0=[488,488,484]
;sh=84165 &lc0=[487.5,487.5,491]

;sh=mdsvalue('current_shot("h1data")') &lc0=[656,657.8,660]

;sh=mdsvalue('current_shot("h1data")') 
;sh=84198
;sh=84212
;sh=84211
;sh=84201
sh=84198
typ='norm'

;lc0=[504.8-0.1,502.4,502.4] & wid=0.3

;lc0=[471.3-0.1,468,468] & wid=0.3

;sh=84193
;sh=84197
;lc0=[656,657.8,660]
print,'shot is ',sh

;read_sp,'~cmichael/share/greg/shaun_84180.spe',l,t,d,st=str
;&lc0=[706,696,700]

;read_spe,'~cmichael/share/greg/shaun_84172 2014 September 25 12_34_15.spe',l,t,d,st=str &lc0=[487.5,487.5,491]

read_spe,'~cmichael/share/greg/shaun_'+string(sh,format='(I0)')+'.spe',l,t,d,st=str
if sh ge 86570 then l=l-0.4
if str.cwl eq '717' then begin
lc0=[706.5,728,726.5] & wid=1.
endif
if str.cwl eq '677' then begin
lc0=[667.8,667.8,669.5] & wid=1.
endif
if str.cwl eq 656 or str.cwl eq 657 then begin
lc0=[656.,656.,660] & wid=1.
endif

kern=fltarr(1,1,10)+0.1
;d=convol(d*1.0,kern)

l=reverse(l)



;stop
if sh lt 84366 then begin
if typ eq 'puf' then begin
   iframe=4                     ;7
   iframe0=3                    ;10;l3;10
endif else begin
   iframe=4;4
   iframe0=0;1
endelse
endif 
if sh ge 84366 and sh lt 84388 then begin
iframe=1;7
iframe0=0;10;l3;10
endif

if sh ge 84388 and sh lt 99999 then begin
if typ eq 'puf' then begin
   iframe=3
   iframe0=2
endif else begin
   iframe=2
   iframe0=0
endelse
endif
;iframe=3
;iframe0=1



nl=n_elements(lc0)
nch=20
sig=fltarr(nch,nl)
for i=0,nl-1 do begin
   ix=where(l ge lc0(i)-wid/2 and l le lc0(i)+wid/2)
   sig(*,i) = total(d(ix,*,iframe),1) - total(d(ix,*,iframe0),1)
   sig(*,i) = sig(*,i) / factor

endfor

for j=0,1 do sig(*,j) = sig(*,j)-sig(*,2)
if str.cwl eq '717' then sig(*,1) = sig(*,1) / 0.6 ;; boost 728 for lower sensitivity

r1=max(sig(*,0),imax)
r2=(sig(imax,1))


save,sig,lc0,file='~/an_'+string(sh,format='(I0)')+typ+'.sav'


rat1=sig(*,1)/sig(*,0) 

;84516
;84517 1ms not 3
;84518 n right
;84519 n left
;84520 n left twice (pointing up)
;84521 n left 3 tims (pointing right) left meaning clockwise
;84522 n left 4 times (back to orig) clockwise
;84523 back to orig then n right twice (top)
;524 3 times
;525 back to orig

;526 slit to 150micron, cwl to 717
;527 open slit, cwl 706 puff 3ms clockwise 4 turns
;528 back to orig pos, cwl 717 150micron slit
;529 677nm


sig(*,1) = sig(*,1) * r1/r2

temp=interpol([10.,50.],[.15,.35],rat1)

;sig(*,2)=0.
;sig(*,1) = sig(*,1) / 0.6 ;; boost 728 for lower sensitivity
mkfig,'~/sp'+string(sh,typ,format='(I0,A)')+'.eps',xsize=10,ysize=13,font_size=9


ipar=fltarr(nch)
for i=0,nch-1 do begin
idx=where(finite(rhopts(i,*)))
if idx(0) ne -1 then ipar(i)=min(rhopts(i,idx)) else ipar(i)=!values.f_nan
endfor
idx=where(finite(ipar))
dum=min(ipar(idx),imin)
imin=idx(imin)
ipar(0:imin-1)*=-1

ipar2=fltarr(nch)
dstsq = ( ptsc(*,*,0) - rax3(1) )^2 + $
        ( ptsc(*,*,2) - zax3(1) )^2


for i=0,nch-1 do begin
dum=min(dstsq(i,*),imin)
ipar2(i)=sqrt(dum)
endfor
dum=min(ipar2,imin)
ipar2(0:imin-1)*=-1




plotm,ipar2,sig/1e5>0,xtitle='Impact parameter (m)',ytitle='signal',title=string(sh,typ eq ''  ? ' passive' : ' '+typ,r2/r1,format='("#",I0,A,", ratio @ peak=",G0.2)'),pos=posarr(1,2,0,cnx=0.1,cny=0.1),thick=2

legend,['728nm','706nm (scaled)'],textcol=[1,2],/right,box=0

;plot,ipar2,(linten),/noer,col=4,ysty=4,xsty=4,pos=posarr(/curr)

;plot,rat1,ytitle='ratio 728/706',yr=[0,.6],pos=posarr(/next),/noer
plot,ipar2,temp,yr=[0,50],xtitle='Impact parameter (m)',ytitle='Te (eV)',pos=posarr(/next),/noer,thick=2
;axis,!x.crange(1),!y.crange(0),yaxis=1,col=2,ytitle='temp eV'

;plotm,l,reform(d(*,3,[iframe0,iframe])) ,/noer,pos=posarr(/next),xtitle=textoidl('\lambda (nm)')
;for i=0,nl-1 do begin
;   for j=0,1 do begin
;      js=[-1,1]
;      oplot, (lc0(i)+js(j)*wid/2)*[1,1],!y.crange,col=2
;   endfor
;endfor

endfig,/gs,/jp
if total(t) eq 0 then t=findgen(n_elements(t))
contourn2,reform(d(*,*,iframe)),l,findgen(20),/cb,/bo,title=string(sh,chan)

stop
contour,rhogrid3(*,*,1),rout,zout,lev=[0.5,0.75,0.8],xr=[1,1.5],/iso
oplot,ptsc(*,*,0),ptsc(*,*,2),psym=3,col=2
endfig,/gs,/jp
t=-22+findgen(11)*11.
;stop
end
