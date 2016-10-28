;iota=par.iota_b(jlist(i)-1)
;iota=2.;1./3.;1./3.


;b_rpos=240&f_rpos=285&f_thpos=1.4&rhowant=0.95

;b_rpos=240&f_rpos=140&f_thpos=10&rhowant=0.95


;b_rpos=240&f_rpos=270&f_thpos=-10&rhowant=0.95

;b_rpos=210+45 & f_rpos=270 & f_thpos=4. & rhowant=0.98

b_rpos=210+45 & f_rpos=240 & f_thpos=4. & rhowant=0.98

;b_rpos=180 & f_rpos=280. & f_thpos=0& rhowant=(.98)

b_rpos=240 & f_rpos=250. & f_thpos=0.& rhowant=.98;^2


;b_rpos=173+45 & f_rpos=240 & f_thpos=4. & rhowant=.98;sqrt(.8)
;b_rpos=193+45 & f_rpos=265 & f_thpos=4. & rhowant=.98;sqrt(.8)


;goto,aaf

;87383=190 fp
;87384=195 ln added
;87385=200
;87386=205 
;87387=210 
;87388=190
;87389=185 
;87390=180 
;87391=175 running
;87392=170
;87393=160
;87394=150 running
;87395=220 running
;87396=230
;87397=240
;87398=250... somewhere here it wasn't moving any more

;87399=260
;87400=270




;file='/home/cam112/vmout/kh0.450-kv1.000fixed/boozmn_wout_kh0.450-kv1.000fixed.nc'
;file='/home/cam112/boozmn_h1ass027v1_0p02.nc'
;file='/home/cam112/boozmn_h1ass027v1_0p83.nc' ;;mine are all nr 32 of .89
;       1.3288984       1.2969668
;   -0.0017268400      0.15138510

;;file='/home/cam112/boozmn_h1ass027v1_0p83.nc'

file='/home/cam112/vmout/./kh0.850-kv1.000fixed/boozmn_wout_kh0.850-kv1.000fixed.nc'

;file='/home/cmichael/vmout/kh0.450-kv1.000fixed/boozmn_wout_kh0.450-kv1.000fixed.nc'

;fil='/h1kstar/VMEC_h1/./kh0.830-kv1.000fixed/boozmn_wout_kh0.830-kv1.000fixed.nc'

id=ncdf_open(file)
;dum=hdf_browser();file)

inq=ncdf_inquire(id)
help,/str,inq
for i=0,inq.nvars-1 do begin
   tmp=ncdf_varinq(id,i) & print,tmp.name,tmp.dim
   ;if tmp.name eq 'rmnc_b' then 
   ncdf_varget,id,i,tvar
   if i eq 0 then par=create_struct(tmp.name,tvar) else par=create_struct(par,tmp.name,tvar)
endfor
print,'__'
for i=0,inq.ndims-1 do begin
   ncdf_diminq,id,i,name,sz & print,name,sz
endfor
;stop


;default,partheta,1.
;default,parphi,0.
;default,phi,0.
nth=18.*3
nphi=36.;*3
theta1=(linspace(0,2*!pi,nth))
phi1=linspace(0,2*!pi,nphi)
theta0=theta1 # replicate(1,nphi)
phi = replicate(1,nth) # phi1

theta =theta0;partheta * theta0 + parphi * phi



r=fltarr(nth,nphi)
z=fltarr(nth,nphi)
;b=fltarr(nth,nphi)

jlist=par.jlist;(0:n_elements(par.jlist)-7)
nrho=n_elements(jlist)

;i=n_elements(jlist)-1




tmp=linspace(0,1,par.ns_b)
rho=tmp(jlist-1)
;i=value_locate(rho,0.29);65)
i=value_locate(rho,rhowant)
;i=value_locate(rho,0.825);0.65)

;i=value_locate3(rho,0.95);0.65)
;stop
iota=par.iota_b(jlist(i)-1)

;stop


p=z + par.phi_b(jlist(i)-1)

;stop
fact=1;2*!pi/3.
sg=-1.;/3.;1.
for j=0,par.mnboz_b-1 do begin
    r=r+par.rmnc_b(j,i)*cos(par.ixm_b(j)*theta+sg*par.ixn_b(j)*phi)
    z=z+par.zmns_b(j,i)*sin(par.ixm_b(j)*theta+sg*par.ixn_b(j)*phi)
    p=p+ fact* par.pmns_b(j,i)*sin(par.ixm_b(j)*theta+sg*par.ixn_b(j)*phi)
 endfor
x=r*cos(phi)
y=r*sin(phi)
aaf:
;;
phibi = phi + p
;contourn2,phibi,theta(*,0)*!radeg,phi(0,*)*!radeg,xtitle='theta',ytitle='phi'
;stop
triangulate,theta,phibi,tri
phiv2=trigrid(theta,phibi,phi,tri,xout=theta(*,0),yout=phi(0,*));vmec as function of theta and phi boozer
iy=interpol(findgen(nphi),phi(0,*),phiv2)
ix=findgen(nth) # replicate(1,nphi)

x2=interpolate(x,ix,iy)
y2=interpolate(y,ix,iy)
z2=interpolate(z,ix,iy)

;dum=surface(z2,y2,x2,style='mesh')



;stop




;surface,x,y,z

;iota=1
;bline=theta*0 - (0*p+phi) * iota
delta=40*!dtor;0;2;0.5
bline=theta - (p+phi) * iota+delta
contourn2,bline,theta(*,0)*!radeg,phi(0,*)*!radeg,xtitle='theta',ytitle='phi'
stop
triangulate,bline,theta,tri
blineg=linspace(-12,12,101)
thetag=linspace(0,2*!pi,51)
phib=trigrid(bline,theta,phi,tri,xout=blineg,yout=thetag,missing=!values.f_nan)
;isel=25
;isel=value_locate2(phib(*,0),delta)
itheta=0
idx=where(finite(phib(*,itheta)) eq 1)
dum=min(abs(phib(idx,itheta)),imin)
isel=idx(imin)
isel=53;value_locate2(blineg,0)

oplot,thetag*!radeg,phib(isel,*)*!radeg,thick=3
ix=interpol(findgen(nth),theta(*,0),thetag)
iy=interpol(findgen(nphi),phi(0,*),phib(isel,*))

ths=interpolate(theta,ix,iy)
phis=interpolate(phi,ix,iy)
;stop
;i1=interpol(findgen(nphi),nphi,14.67)
oplot,ths*!radeg,phis*!radeg,col=1,thick=3
;stop
stop
;
zs=interpolate(z,ix,iy)
rs=interpolate(r,ix,iy)
xs=interpolate(x,ix,iy)
ys=interpolate(y,ix,iy)
ia=indgen(n_elements(phis)-1)
tt=[0,14.67*!dtor,60*!dtor,120*!dtor]
tt=[0,7.2*!dtor,60*!dtor,120*!dtor]
rofit=interpol(rs(ia),phis(ia),tt)
zofit=interpol(zs(ia),phis(ia),tt)

;print,rofit
;print,zofit


ii=0
xr=[1,1.36]
yr=[-0.25,0.25]
plot,r(*,ii),z(*,ii),/iso,pos=posarr(2,1,0),xr=xr,yr=yr,xsty=1,ysty=1,title=string('R_bp=',b_rpos,format='(A,G0)')
plots,rofit(0),zofit(0),psym=4,col=2
ibar=interpol(findgen(nphi),phi1,tt(1))
ibar2=indgen(nth)




rb = (1112-45 + b_rpos)*1e-3
plots,rb,0,psym=4

plot,interpolate(r,ibar2,ibar,/grid),interpolate(z,ibar2,ibar,/grid),/iso,pos=posarr(/next),/noer,xr=xr,yr=yr,xsty=1,ysty=1,title=string('R_fp=',f_rpos,' th_fp=',f_thpos,format='(A,G0,A,G0)')
plots,rofit(1),zofit(1),psym=4,col=2

;pro fppos2, Dm, theta1, r2, z2,phi2,short=short,new=new,alpha=alpha

fppos2,f_rpos,f_thpos,ra,Za,/new,alpha=!pi/2 & ra*=1e-3 & za*=1e-3
plots,ra,za,psym=4



stop
isurface,z,x,y,identifier=id,transparency=5
ff=1.
iplot,xs*ff,ys*ff,zs*ff,overplot=id


stop



;xt  = 1250e-3
;yt = 50e-3
;zt  = 500e-3
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

;iplot,xsel,ysel,zsel,overplot=id


ix=where(abs(zsel) lt 1.5)
xsel=xsel(ix) & ysel=ysel(ix) & zsel=zsel(ix) & nsel=n_elements(ix)


;stop
;plot,r,z,title=i,/iso

end



