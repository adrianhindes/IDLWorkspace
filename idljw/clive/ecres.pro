pro ecres,rx,ry,want=want,nostop=nostop

dirmod=''
dirbase='/home/cam112/ikstarcp/my2'
zaim=0
harmno=2 & gyfreq=170.
if want eq '11003' then begin
   sh=11003 & btscal=1. & npar=0.2
endif

if want eq '9323' then begin
   sh=9323 & btscal=1. & npar=0.2
endif


if want eq '11004' then begin
sh=11003 & btscal=31.5/28.5 & npar=-0.2
endif

if want eq '10997b' then begin
sh=11003 & btscal=27./28.5 & npar=0.2 
endif

if want eq '10997c' then begin
sh=11003 & btscal=27./28.5 & npar=0.2 & zaim=50.;0;15.
endif


if want eq '11433c' then begin
   harmno=3& gyfreq=170.
   sh=11433 & btscal=1. & npar=0.2
endif
if want eq '11433a' then begin
   harmno=2 & gyfreq=110.
   sh=11433 & btscal=1. & npar=0.2
endif

if want eq '11434a' then begin
   harmno=2 & gyfreq=110.
   sh=11433 & btscal=1. & npar=-0.2
endif


;harmno=3 & gyfreq=170.

if sh eq 11003 then dirmod=''

dir=dirbase+'/EXP'+string(sh,format='(I6.6)')+'_k'+dirmod
if sh eq 11433 then tw=5.345
if sh eq 11003 then tw=3.45
if sh eq 9323 then tw=4.6
twr=((round(tw*1000/5)*5)) / 1000.
fspec=string(sh,twr*1000,format='(I6.6,".",I6.6)')
gfile=dir+'/g'+fspec
g=readg(gfile)
g.fpol = -g.fpol +  2*g.fpol(64)
psi=(g.psirz-g.ssimag)/(g.ssibry-g.ssimag) & psi2=sqrt(psi)

contour,psi2,g.r*100,g.z*100,/iso,xr=[120,220],yr=[-80,80],lev=[0.2,.4,.6,.8,1],xsty=1,ysty=1
;idx=where(psi2 gt 1)
;rho1=linspace(0,1,65)
;fpol2 = interpolo(g.fpol,rho1,psi)
;;fpol2(idx)=0
;r2=g.r # replicate(1,n_elements(g.z))*100
zz2=replicate(1,n_elements(g.r)) # g.z*100

r2=findgen(n_elements(g.r)) # replicate(1,n_elements(g.z))
z2=replicate(1,n_elements(g.r)) # findgen(n_elements(g.z))

;bt=
calculate_bfield,bp,br,bt,bz,g
bt=bt*btscal
freq = 2.8e6 * bt*1e4 * harmno / 1e9

 vth=sqrt(2*1.6e-19 * 3000. / 9.1e-31)
fac=1-vth/3e8 * abs(npar) ;npalalleel
lev0=[1,1*fac]*gyfreq
lev=lev0
clinesty=[0,2]
idx=sort(lev)
lev=lev(idx)
clinesty=clinesty(idx)
contour,freq,g.r*100,g.z*100,lev=lev,/overplot,c_linesty=clinesty
if not keyword_set(nostop) then stop
wrad=6. ; cm

triangulate, freq, z2,tri

rn=trigrid(freq,z2,r2,tri,xgrid=fnewg,ygrid=znewg,ny=1000)
fnewg=[1,1.01]*gyfreq*fac
rn=trigrid(freq,z2,r2,tri,xout=fnewg,yout=znewg)
zn=trigrid(freq,z2,z2,tri,xout=fnewg,yout=znewg)
zzn=trigrid(freq,z2,zz2,tri,xout=fnewg,yout=znewg)

psi2n=interpolate(psi2,rn,zn,cubic=-0.5)

z1=zzn(0,*)
psi1=psi2n(0,*)

rwid=10.

dum=min(psi1,imin)
idx=where(psi1 gt 1)
psi1(idx)=1.


psi1a=psi1(0:imin)
psi1b=psi1(imin:*)
z1a=z1(0:imin)
z1b=z1(imin:*)
;f1a=f1[0:imin]
;f1b=f1[imin:*]


npsir=1000
psir=linspace(0,0.99,npsir)

zga=interpolo(z1a,psi1a,psir,oval=!values.f_nan)
zgb=interpolo(z1b,psi1b,psir,oval=!values.f_nan)

jaca=abs(deriv(psir,zga))
jacb=abs(deriv(psir,zgb))

fga=exp(-(zga-zaim)^2 / rwid^2)
fgb=exp(-(zgb-zaim)^2 / rwid^2)

ftot = fga * jaca + fgb * jacb
idx=where(finite(ftot) eq 0)
ftot(idx)=0.
fs=smooth(ftot,40)
plot,psir,fs
if not keyword_set(nostop) then stop
fsi=interpol(fs,psir,psi2)

iz0=value_locate(g.z,0)
fsi0=fsi(*,iz0)
plot,-g.r*100,fsi0,psym=-4,xr=[-220,-165]
rx=-g.r*100
ry=fsi0




end
