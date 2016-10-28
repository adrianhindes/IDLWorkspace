pro initbeam,beam=beam
common cbbeam, nh, ductp, srcp, zhat,xhat,yhat, div,hfoc,vfoc

kbpars,mastbeam=beam,str=str
ductp=str.ductpoint/100. ;[0.539, -1.926, 0.0] ; duct position (where nb comes out into mast tank)
zhat = str.chat;[cos(ducta),sin(ducta),0] ; direction vector along beam
yhat=[0,0,1.] ; perp to
xhat=crossp(zhat,yhat) ; perp to

distduct=str.distduct/100. ; distance that source is behind duct
hfoc=str.horiz_foc/100. ; focal length horiz
vfoc=str.vert_foc/100. ; and vert
div=str.div;
srcp=ductp - zhat * distduct ; calc source position

end

pro beam, xg, yg, pos,s, dir

; xg,yg grid pos, s, intensity, dir-direction(vector)
; xp,yp,zp - position (world coord)


common cbbeam, nh, ductp, srcp, zhat,xhat,yhat, div,hfoc,vfoc
posr=pos-srcp
x1=total(posr*xhat)
y1=total(posr*yhat)
z1=total(posr*zhat)

s = exp(- ($
        ( (x1 - xg) / z1 + xg / hfoc )^2 + $
        ( (y1 - yg) / z1 + yg / vfoc )^2 ) / div^2 )
dir0=[x1-xg,y1-yg,z1] 
dir=dir0(0) * xhat + dir0(1) * yhat + dir0(2) * zhat

dir=dir/sqrt(total(dir^2))

end




pro tst ; this routine simply plots tests the beam velocity distribution function f(x,v) as documented. NOT NEEDED

initbeam,beam='k1'
common cbbeam, nh, ductp, srcp, zhat,xhat,yhat, div,hfoc,vfoc

pos=srcp+zhat*7 + xhat * 0.1 + yhat * 0.1 ; assume a particular location 7 m from source of beam and along beam axis

nx=7
ny=9
xg=linspace(-0.07,0.07,nx)
yg=linspace(-0.2,0.2,ny)
s=fltarr(nx,ny)
dx=s
dy=s
for i=0,nx-1 do for j=0,ny-1 do begin
    beam,xg(i),yg(j),pos,s2,dir 
    s(i,j)=s2
    dx(i,j)=total(xhat * dir)
    dy(i,j)=total(yhat * dir)
    print,dx(i,j),dy(i,j)
endfor

contourn2, s,xg,yg,/cb
stop
end


function interpolatec, f, xa,ya,x,y
fli=(x-xa(0))/(xa(1)-xa(0))
flj=(y-ya(0))/(ya(1)-ya(0))
i=floor(fli) & mi=fli-i
j=floor(flj) & mj=flj-j
g = f(i,j) * (1-mi) * (1-mj) + $
    f(i+1,j) * mi * (1-mj) + $
    f(i,j) * (1-mi) * mj + $
    f(i+1,j+1) * mi * mj
return,g
end



pro calcb, pos, ib
common cbb, a,br,bt,bz,r,z
;shw=19514
;tw=1.0
;shw=18501
;tw=0.29
if n_elements(a) eq 0 then begin

    fil=getenv('HOME')+'/g005594.02150'
    a=readg(fil)
    calculate_bfield,bp,br,bt,bz,a
    r=a.r
    z=a.z
;    a=read_flux(shw,/nofc) 
;    t=a.taxis.vector
;    b=a.bfield.vector
;    r=a.xaxis.vector
;    z=a.yaxis.vector
;    iw=value_locate(t,tw)
;    br=b(*,*,iw,0)
;    bt=b(*,*,iw,1)
;    bz=b(*,*,iw,2)

;psi=a.fluxcoordinates.psin(*,*,iw)
endif

rpos=sqrt(pos(0)^2 + pos(1)^2)
zpos=pos(2)
phipos=atan(pos(1),pos(0))
cp=cos(phipos)
sp=sin(phipos)

;irpos=interpol(findgen(n_elements(r)),r,rpos)
;izpos=interpol(findgen(n_elements(z)),z,zpos)
;ibr=interpolate(br,irpos,izpos)
;ibt=interpolate(bt,irpos,izpos)
;ibz=interpolate(bz,irpos,izpos)
;if abs(zpos - 4.4642372) lt 1d-5 then stop
ibr=interpolatec(br,r,z,rpos,zpos)
ibt=interpolatec(bt,r,z,rpos,zpos)
ibz=interpolatec(bz,r,z,rpos,zpos)

;ipsi=interpolate(psi,irpos,izpos)

ibx=cp * ibr - sp * ibt
iby=sp * ibr + cp * ibt

ib=[ibx,iby,ibz]

end


pro initkern,nwav656=nwav656s,beam=beam,bvolt=bvolt,radb1=radb1,zedb1=zedb1

common kernp, flt_x0,flt_xfwhm,velscal,plens0, $
  poffs,pzhat,pxhat,pyhat,$
  plensx,plensy,plensz,im0,im1, lensdia, xpext,ypext,zpext,xgext,ygext,$
  iscos,nwav656,kdisp

im0=0
;im1=2
;im0=3
im1=8

; first&last values of im
;flt_l0=6561.+30.19 ; 33.03+1.+1.4 ;35.3491 ; prescribe filter tranfer function
;flt_fwhm=0.1;1. ; and fwm
;
nwav656=nwav656s
ccrystal,{crystal:'bbo',lambda:656e-9,facetilt:0},n_e,n_o,kappa=kappa
kdisp=kappa

;bvolt=92e3 ; requested parameters


lensdia=.02


dcharge=1.602e-19
dmass=1.6726e-27*2.0135532127 
c=2.99768e8
velscal=sqrt(2*dcharge * (bvolt)/dmass) / c
; the scalar velocity in units of c
l0=6561.0 ; the dalpha unshifted line wavelength angstroms

;flt_x0=-(flt_l0-l0)/l0 ; convert filter parameters to normalized units
; minus sign because xi is frequency difference coordinate not
; wavelenth so in the derivative there is a minus sign
;flt_xfwhm = flt_fwhm/l0 ; 

;setup_dirs
;defsysv,'!spath',!demodsettingspath+'/backlight_2008_7_7'
;restore,file=!spath+'/pos.sav';,/verb

;plensz=zhat ; z dir vector on lens from restore file
;plensx=xhat
;plensy=yhat

;plens0=p0/1e3 ; p0 from restore file
;xpa=total(x0,2)/19.
;ypa=total(y0,2)/19. ; from restore file
;fdia=0.5
;xf1 = (max(x0(k,*))-min(x0(k,*))+fdia )/2. ; 0.5mm for fib dia
;yf1 = (max(y0(k,*))-min(y0(k,*))+fdia)/2. ; 0.5mm for fib dia

efl=28e-3
xf1 = 10*6.5e-6 ; 10pix
yf1 = xf1

plens0=[2753,-82,285.]/1000. ; window point

default,zedb1,0.
point1=[sqrt(radb1^2 - 1.48^2),-1.48,zedb1]


pzhat=point1-plens0 & pzhat/=norm(pzhat)



;pzhat = zhat + xhat * xpa(k) / efl + yhat * ypa(k) / efl
;pzhat=pzhat/norm(pzhat)
pyhat=[0,0,1]
pxhat=crossp(pyhat,pzhat) & pxhat/=norm(pxhat)
pyhat=crossp(pxhat,pzhat) & pyhat/=norm(pyhat)

plensx=pxhat
plensy=pyhat  ; make them the same because assume ray is axial along lens but genetrally will not be the case

kbpars,mastbeam=beam,str=str


b0pos=str.ductpoint/100.;[0.539, -1.926, 0.0]
;B_xi=85.16*!dtor
b0dir = str.chat;[cos(B_xi), sin(B_xi), 0]
b0dir=b0dir/norm(b0dir)

solint, b0pos, b0dir, plens0, pzhat, tmp,poffs,dum,dst ; poffs is point on los nearest to beam
print,'r=',sqrt(poffs(0)^2+poffs(1)^2)
;stop
xpext=xf1/efl * dst
ypext=yf1/efl * dst ; extents perp to beam in plasma (+/-)
;stop
bw = 0.6 ;  beam full width
ang=acos(total(pzhat * b0dir))

zpext=bw / sin(ang) / 2 ; half of it for convention

xgext=max(str.holp(*,0))*2

ygext=max(str.holp(*,1))*2



end



pro kern,xl,yl,zl,xg,yg,rl,thl, s0s,s1s,s2s,quad=quad
common kernp, flt_x0,flt_xfwhm,velscal,plens0, $
  poffs,pzhat,pxhat,pyhat,$
  plensx,plensy,plensz,im0,im1, lensdia, xpext,ypext,zpext,xgext,ygext,$
  iscos,nwav656,kdisp

if quad eq 'cos' then iscos=1 else iscos=0

pos = poffs + xl*pxhat + yl * pyhat + zl * pzhat
plens=plens0 + plensx * rl * cos(thl) + plensy * rl * sin(thl)
lhatz = plens-pos & lhatz=lhatz/sqrt(total(lhatz^2))
lhaty=[0,0,1] 
lhatx=crossp(lhaty,lhatz)
lhaty=crossp(lhatz,lhatx)
prj=transpose([[lhatx],[lhaty],[lhatz]]) ;  construct a projection matrix


pma=[-1,-1,-1,1,1,1,1,1,1] ; array of sign of stokes vectors
ma=[0,1,-1,2,-2,3,-3,4,-4] ; the corresponding values of m
lrma=[46,16.5,16.5,6,6,19.2,19.2,14,14] ; the coresponding intensities
rma=[45.4,16.5,16.5,6,6,19.2,19.2,14,14] ; this ones sums to zero but may not be correct

common cbrr2, evec1,ds
beam,xg,yg,pos,s,dir
vel=dir*velscal
ds=total(vel * lhatz) ; compute doppler shift
;if abs(pos(2)  - 4.4642372) lt 1d-5 then stop
calcb,pos,bvec ; calc b
evec1=crossp(vel,bvec) ;  compute e field vector
evec=prj#evec1
s0s=0. & s1s=0. & s2s=0.
for im=im0,im1 do begin
    pm=pma(im)
    rm=rma(im)                  ; an assign pm and rm
    m=ma(im)
    c=2.99768e8
    km = m * 0.277e-6/6561. * c ; compute the value of km as in latex document
    ss=sqrt(total(evec1^2)) * km         ;  compute stark shift
    arg=ds+ss                   ; argument of lorentzian function


;    a=flt_xfwhm/2               ; half width at half maximum


;    lorfunc = a^2 / ((arg-flt_x0)^2 + a^2) ; lorentizan function
    if iscos eq 1 then lorfunc = cos(2*!pi*(0+arg)*nwav656*kdisp)
    if iscos eq 0 then lorfunc = sin(2*!pi*(0+arg)*nwav656*kdisp)
;    print,im,arg
;    stop


    gm = s * lorfunc *  rm      ; compute kernel function
    a2 = evec(0)^2 + evec(1)^2 + evec(2)^2
    s1 = pm * (evec(0)^2 - evec(1)^2) / a2
    s2 = pm * 2 * evec(0) * evec(1) / a2
    if pm eq 1 then s0 = (evec(0)^2 + evec(1)^2) / a2
    if pm eq -1 then s0= 1.     ; sigma includes pol+unpol part
    s0=s0* s * rm ; no lorfunc because unpolarized no fringes 
    s1=s1*gm & s2=s2*gm
    s0s=s0s+s0 & s1s=s1s+s1 & s2s=s2s+s2
;    print,s0/gm,gm,s0s

;    print,im,pm,rm,'___',s1s,lorfunc

endfor

;stop
end

pro kern3,nwav656=nwav656s,zeta1=zeta,zeta2=zeta2,radb1=radb1,barr=barr,bvoltarr=bvoltarr,zedb1=zedb1

;barr=['k1','k2']
;bvoltarr=[94e3,82e3]
;bvoltarr=[94e3,94e3]
nb=n_elements(barr)
s0s=0. & s1s=0. & s2s=0.


for ib=0,nb-1 do begin
initbeam,beam=barr(ib) ; initialize nb grid positions
initkern,beam=barr(ib),nwav656=nwav656s,bvolt=bvoltarr(ib),radb1=radb1,zedb1=zedb1



common kernp, flt_x0,flt_xfwhm,velscal,plens0, $
  poffs,pzhat,pxhat,pyhat,$
  plensx,plensy,plensz,im0,im1, lensdia, xpext,ypext,zpext,xgext,ygext,$
  iscos,nwav656,kdisp



xl=0. & yl=0. & zl=0. & xg=0. & yg=0. & rl=0. & thl=0. 
    kern,xl,yl,zl,xg,yg,rl,thl, s0t,s1t,s2t,quad='cos'
print,s0t,s1t,s2t
;stop

nxl=3l
nyl=5l
nzl=10l
nxg=5l
nyg=8l
nr=2l
nth=4l

nxl=3l
nyl=3l
nzl=3l
nxg=3l
nyg=3l
nr=2l
nth=4l

xl=linspace(-xpext,xpext,nxl)
yl=linspace(-ypext,ypext,nyl)
zl=linspace(-zpext,zpext,nzl)
xg=linspace(-xgext,xgext,nxg)
yg=linspace(-ygext,ygext,nyg)
rl=linspace(lensdia/2/nr,lensdia/2,nr)
thl=linspace(2*!pi/nth,2*!pi,nth)

tot=nxl*nyl*nzl*nxg*nyg*nr*nth
print,tot
s0=0. & s1=0. & s2=0.

cnt=0l
for i0=0,nxl-1 do for i1=0,nyl-1 do for i2=0,nzl-1 do $
  for i3=0,nxg-1 do for i4=0,nyg-1 do for i5=0,nr-1 do for i6=0,nth-1 do begin
;    kern,xl,yl,zl,xg,yg,rl,thl, s0t,s1t,s2t
    kern, xl(i0),yl(i1),zl(i2),xg(i3),yg(i4),rl(i5),thl(i6),s0t,s1t,s2t,quad='cos'
    s0=s0+s0t*rl(i5)
    s1=s1+s1t*rl(i5)
    s2=s2+s2t*rl(i5)

    kern, xl(i0),yl(i1),zl(i2),xg(i3),yg(i4),rl(i5),thl(i6),s0t,s1t,s2t,quad='sin'
    s0s=s0s+s0t*rl(i5)
    s1s=s1s+s1t*rl(i5)
    s2s=s2s+s2t*rl(i5)
    cnt=cnt+1
;    if cnt mod 1000 eq 0 then print,cnt,tot
endfor

endfor


lpf=sqrt(s1^2+s2^2)/s0
lpfs=sqrt(s1s^2+s2s^2)/s0s

pa=atan(s2,s1)/2*!radeg
print,'nwav656=',nwav656s
print,'lpf=',lpf
print,'lpfs=',lpfs
print,'pa=',pa
;zeta=sqrt(lpf^2+lpfs^2);stop
;print,'rms=',zeta
zeta=sqrt(s1^2+s1s^2)/s0s;sqrt(s1^2+s2^2)/s0
zeta2=sqrt(s2^2+s2s^2)/s0s;s2s/s0


;zeta2=atan(s1s,s1)/2/!pi+0.5
;stop
end

pro loop
na=10*2.5*3
aarr=linspace(0,2000,na)
z=fltarr(na)
z2=z
for i=0,na-1 do begin
;    if j eq 2 then
    barr=['k1','k2']
;    bvoltarr=[94e3,94e3]
    bvoltarr=[94e3,82e3]

    kern3,nwav656=aarr(i),zeta1=zeta1,zeta2=zeta2,radb1=1.8,barr=barr,bvoltarr=bvoltarr
    z(i)=zeta1
    z2(i)=zeta2
endfor
plot,aarr,z
oplot,aarr,z2,col=2
;kern3,nwav656=1000.25

end


pro loopr
na=10
rad=linspace(1.7,2.3,na)
;aarr=800

wv= opd(0,0,par={crystal:'bbo',thickness:5e-3,facetilt:30*!dtor,lambda:656e-9},delta0=0,kappa=kappa)/2/!pi
;stop
aarr=wv

z=fltarr(na)
z2=z
for j=0,2 do begin
    if j eq 0 then barr=['k1']
    if j eq 1 then barr=['k2']
    if j eq 2 then barr=['k1','k2']
    bvoltarr=[94e3,94e3]
;    bvoltarr=[94e3,82e3]

    for i=0,na-1 do begin
    kern3,nwav656=aarr,zeta1=zeta1,zeta2=zeta2,radb1=rad(i),barr=barr,bvoltarr=bvoltarr

    z(i)=zeta1
    z2(i)=zeta2
endfor
ang=atan(z2,z)/2*!radeg
if j eq 0 then plot,rad,ang,col=j+1,yr=[0,15] else oplot,rad,ang,col=j+1
endfor

stop
;oplot,rad,z2,col=2
;kern3,nwav656=1000.25

end

pro loopz
na=10
rad=linspace(1.7,2.3,na)
;aarr=800

wv= opd(0,0,par={crystal:'bbo',thickness:5e-3,facetilt:30*!dtor,lambda:656e-9},delta0=0,kappa=kappa)/2/!pi
;stop
aarr=wv

z=fltarr(na)
z2=z

zedarr=[0.,0.25,-0.25]*2
; barr=['k1']
 barr=['k2']
    bvoltarr=[94e3,94e3]

for j=0,2 do begin

    for i=0,na-1 do begin
    kern3,nwav656=aarr,zeta1=zeta1,zeta2=zeta2,radb1=rad(i),barr=barr,bvoltarr=bvoltarr,zedb1=zedarr(j)

    z(i)=zeta1
    z2(i)=zeta2
endfor
ang=atan(z2,z)/2*!radeg
if j eq 0 then plot,rad,ang,col=j+1,yr=[0,15] else oplot,rad,ang,col=j+1
endfor
legend,['z=0','z=+0.25m','z=-0.25m'],textcol=[1,2,3]
stop
;oplot,rad,z2,col=2
;kern3,nwav656=1000.25

end


pro fig
kern3,nwav656=800
common kernp, flt_x0,flt_xfwhm,velscal,plens0, $
  poffs,pzhat,pxhat,pyhat,$
  plensx,plensy,plensz,im0,im1, lensdia, xpext,ypext,zpext,xgext,ygext,$
  iscos,nwav656,kdisp

common cbrr2, evec1,ds

arga=fltarr(im1+1)
ya=arga
pma=[-1,-1,-1,1,1,1,1,1,1] ; array of sign of stokes vectors
ma=[0,1,-1,2,-2,3,-3,4,-4] ; the corresponding values of m
rma=[46,16.5,16.5,6,6,19.2,19.2,14,14] ; the coresponding intensities

for im=im0,im1 do begin
    pm=pma(im)
    rm=rma(im)                  ; an assign pm and rm
    m=ma(im)
    c=2.99768e8
    km = m * 0.277e-6/6561. * c ; compute the value of km as in latex document
    ss=sqrt(total(evec1^2)) * km         ;  compute stark shift
    arg=ds+ss                   ; argument of lorentzian function
    arga(im)=arg

;    a=flt_xfwhm/2               ; half width at half maximum


;    lorfunc = a^2 / ((arg-flt_x0)^2 + a^2) ; lorentizan function
    if iscos eq 1 then lorfunc = (cos(2*!pi*(0+arg)*nwav656*kdisp))
    if iscos eq 0 then lorfunc = (sin(2*!pi*(0+arg)*nwav656*kdisp))
;    print,im,arg


    gm =  rm      ; compute kernel function
    ya(im)=gm
endfor
plot,arga,ya,psym=4
arg2=linspace(min(arga),max(arga),100)
func=.5*(1+cos(2*!pi*(1-arg2)*nwav656*kdisp))
plot,arg2,func,/noer,col=2
stop
end
