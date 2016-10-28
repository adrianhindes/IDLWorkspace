pro initbeam
common cbbeam, nh, ductp, srcp, zhat,xhat,yhat, div,hfoc,vfoc


ductp=[0.539, -1.926, 0.0] ; duct position (where nb comes out into mast tank)
ducta=85.16*!dtor ; angle of beam with respect to horiz.
zhat = [cos(ducta),sin(ducta),0] ; direction vector along beam
yhat=[0,0,1.] ; perp to
xhat=crossp(zhat,yhat) ; perp to

distduct=5.17 ; distance that source is behind duct
hfoc=14.0 ; focal length horiz
vfoc=5.17 ; and vert
div=0.7*!dtor ; divergence angle
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

initbeam
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
shw=18501
tw=0.29
if n_elements(a) eq 0 then begin
    a=read_flux(shw,/nofc) 
    t=a.taxis.vector
    b=a.bfield.vector
    r=a.xaxis.vector
    z=a.yaxis.vector
    iw=value_locate(t,tw)
    br=b(*,*,iw,0)
    bt=b(*,*,iw,1)
    bz=b(*,*,iw,2)
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
ibr=interpolatec(br,r,z,rpos,zpos)
ibt=interpolatec(bt,r,z,rpos,zpos)
ibz=interpolatec(bz,r,z,rpos,zpos)

;ipsi=interpolate(psi,irpos,izpos)

ibx=cp * ibr - sp * ibt
iby=sp * ibr + cp * ibt

ib=[ibx,iby,ibz]

end


pro initkern,nwav656=nwav656s

common kernp, flt_x0,flt_xfwhm,velscal,plens0, $
  poffs,pzhat,pxhat,pyhat,$
  plensx,plensy,plensz,im0,im1, lensdia, xpext,ypext,zpext,xgext,ygext,$
  iscos,nwav656,kdisp

im0=0
im1=8; first&last values of im

;flt_l0=6561.+30.19 ; 33.03+1.+1.4 ;35.3491 ; prescribe filter tranfer function
;flt_fwhm=0.1;1. ; and fwm
;
nwav656=nwav656s
kdisp=1.5;5

bvolt=50e3 ; requested parameters
k=30 ; fib index  30

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

setup_dirs
defsysv,'!spath',!demodsettingspath+'/backlight_2008_7_7'
restore,file=!spath+'/pos.sav';,/verb

plensz=zhat ; z dir vector on lens from restore file
plensx=xhat
plensy=yhat

plens0=p0/1e3 ; p0 from restore file
xpa=total(x0,2)/19.
ypa=total(y0,2)/19. ; from restore file
fdia=0.5
xf1 = (max(x0(k,*))-min(x0(k,*))+fdia )/2. ; 0.5mm for fib dia
yf1 = (max(y0(k,*))-min(y0(k,*))+fdia)/2. ; 0.5mm for fib dia

pzhat = zhat + xhat * xpa(k) / efl + yhat * ypa(k) / efl
pzhat=pzhat/norm(pzhat)
pyhat=[0,0,1]
pxhat=crossp(pyhat,pzhat) ; pzhat,pxhat,pyhat are dir vectors of position and poffs is origin nearest to beam

b0pos=[0.539, -1.926, 0.0]
B_xi=85.16*!dtor
b0dir = [cos(B_xi), sin(B_xi), 0]
b0dir=b0dir/norm(b0dir)

solint, b0pos, b0dir, plens0, pzhat, tmp,poffs,dum,dst ; poffs is point on los nearest to beam
print,'r=',sqrt(poffs(0)^2+poffs(1)^2)
xpext=xf1/efl * dst
ypext=yf1/efl * dst ; extents perp to beam in plasma (+/-)

bw = 0.3 ;  beam full width
ang=acos(total(pzhat * b0dir))

zpext=bw / sin(ang) / 2 ; half of it for convention

xgext=0.07
ygext=0.2 ; beam grid extents



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
rma=[46,16.5,16.5,6,6,19.2,19.2,14,14] ; the coresponding intensities

common cbrr2, evec1,ds
beam,xg,yg,pos,s,dir
vel=dir*velscal
ds=total(vel * lhatz) ; compute doppler shift
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
    if iscos eq 1 then lorfunc = .5*(1+cos(2*!pi*(0+arg)*nwav656*kdisp))
    if iscos eq 0 then lorfunc = .5*(1+sin(2*!pi*(0+arg)*nwav656*kdisp))
;    print,im,arg


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
endfor

;stop
end

pro kern3,nwav656=nwav656s,zeta=zeta
initbeam ; initialize nb grid positions
initkern,nwav656=nwav656s


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
s0s=0. & s1s=0. & s2s=0.
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

lpf=sqrt(s1^2+s2^2)/s0
lpfs=sqrt(s1s^2+s2s^2)/s0s

;pa=atan(s2,s1)/2*!radeg
print,'nwav656=',nwav656s
print,'lpf=',lpf
print,'lpfs=',lpfs
;print,'pa=',pa
zeta=sqrt(lpf^2+lpfs^2);stop
print,'rms=',zeta
end

pro loop
na=10
aarr=linspace(0,4000,na)
z=fltarr(na)
for i=0,na-1 do begin
    kern3,nwav656=aarr(i),zeta=zeta1
    z(i)=zeta1
endfor
plot,aarr,z
;kern3,nwav656=1000.25

end

pro fig
kern3,nwav656=2000
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
    if iscos eq 1 then lorfunc = .5*(1+cos(2*!pi*(0+arg)*nwav656*kdisp))
    if iscos eq 0 then lorfunc = .5*(1+sin(2*!pi*(0+arg)*nwav656*kdisp))
;    print,im,arg


    gm =  rm      ; compute kernel function
    ya(im)=gm
endfor
plot,arga,ya,psym=4
arg2=linspace(min(arga),max(arga),100)
func=.5*(1+cos(2*!pi*(0-arg2)*nwav656*kdisp))
plot,arg2,func,/noer,col=2
stop
end
