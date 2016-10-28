function calccurr,g,rho=rhoi,jay=avgjayi,dcur=avgcuri
;@lkece,
;g=readg('/home/cam112/ikstarcp/my2/EXP011003_k/g011003.003450')
;g=readg('/home/cam112/g009324.001900')

psi2d=(g.psirz-g.ssimag)/(g.ssibry-g.ssimag) ;& psi=sqrt(psi)
npsi=n_elements(g.pprime)
pprime2 = interpol(g.pprime,findgen(npsi)/npsi,psi2d)
ffprime2 = interpol(g.ffprim,findgen(npsi)/npsi,psi2d)
idx=where(psi2d gt 1)
r2=g.r # replicate(1,n_elements(g.z)) * 1 ; cm to m
z2=replicate(1,n_elements(g.r)) # g.z * 1 ; cm to m


pprime2(idx)=0;!values.f_nan
ffprime2(idx)=0;!values.f_nan
j1 =- r2 * pprime2
j2 = -ffprime2 / r2 / (4*!pi*1e-7)
jay=j1+j2


q=g.qpsi

psirz=g.psirz
psinrz=(psirz-g.ssimag)/(g.ssibry-g.ssimag)

p0=[g.rmaxis,g.zmaxis]
r=g.r
z=g.z
dr=r-p0(0)
dz=z-p0(1)

nr=n_elements(r)
nz=n_elements(z)

dr2=dr # replicate(1,nz)
dz2=replicate(1,nr) # dz

r2=r # replicate(1,nz)
z2=replicate(1,nr) # z

theta=atan(dz2,dr2)
ctheta=cos(theta)
stheta=sin(theta)


nth1=36 & theta1=findgen(nth1)/nth1 * 2*!pi
npsi1=21
reg=linspace(0,1,npsi1)
psin1=(linspace(0,1,npsi1+1))(1:npsi1) & psin1=psin1^2
maxr=1.
ri=fltarr(nth1,npsi1)
jayi=fltarr(nth1,npsi1)


gradpsix = psirz*0
gradpsiy=psirz*0
delr=r(1)-r(0)
delz=z(1)-z(0)
for i=1,nr-2 do for j=1,nz-2 do begin
   gradpsix(i,j) = (psirz(i+1,j)-psirz(i-1,j))/2/delr
   gradpsiy(i,j) = (psirz(i,j+1)-psirz(i,j-1))/2/delz
endfor
modgradpsi=sqrt(gradpsix^2+gradpsiy^2)


gradpsii=ri
for i=0,nth1-1 do begin
tmpdr=cos(theta1(i)) * maxr*reg
tmpdz=sin(theta1(i)) * maxr*reg
ix=interpol(findgen(nr),dr,tmpdr)
iy=interpol(findgen(nz),dz,tmpdz)
psini=interpolate(psinrz,ix,iy)
;dum=min(abs(psini-1.0),imin)
len=interpol(maxr*reg,psini,psin1)

ri(i,*)=len
;plot,maxr*reg,psini
;plot,tmpdr,tmpdz,/iso

;stop

tmpdr=cos(theta1(i)) * len
tmpdz=sin(theta1(i)) * len
ix=interpol(findgen(nr),dr,tmpdr)
iy=interpol(findgen(nz),dz,tmpdz)
gradpsii(i,*)=interpolate(modgradpsi,ix,iy)
jayi(i,*)=interpolate(jay,ix,iy)

endfor
;stop
dtheta=theta1(1)-theta1(0)
dli = ri 
sinchi = ri
for i=0,nth1-1 do for j=0,npsi1-1 do begin
ap0 = ri(i,j) * [cos(theta1(i)),sin(theta1(i))]
ap1= ri((i+1) mod nth1,j) * [cos(theta1((i+1) mod nth1)),sin(theta1((i+1) mod nth1))]
dp=ap1-ap0

dli(i,j)=sqrt(dp(0)^2+dp(1)^2)

sinchi(i,j)=(crossp([ap0/norm(ap0),0],[dp/norm(dp),0]))(2)

rri = ri*cos(theta1 # replicate(1,npsi1)) + g.rmaxis
zzi = ri*sin(theta1 # replicate(1,npsi1)) + g.zmaxis
;dli(i,*) = sqrt( (dri(i,*)*dtheta)^2 + (dri(( i+1) mod nth1,*)-dri(i,*))^2)
endfor
dri=ri
dri(*,0)=ri(*,0)
for i=1,npsi1-1 do dri(*,i)=ri(*,i)-ri(*,i-1)
;stop




nrr=n_elements(q)
psin = linspace(0,1,nrr)
psi = psin * (g.ssibry-g.ssimag) + g.ssimag
dpsi=psi(1)-psi(0)
dphi = 2*!pi*q*dpsi
phi=total(dphi,/cum) & phi=[0,phi(0:nrr-2)]
b0=g.bcentr
rho = sqrt(phi / !pi / b0)

drhodpsi=deriv(psi,rho)

rho1 = interpol(rho,psin,psin1)

drhodpsi1=interpol(drhodpsi,psin,psin1)

gradrhoi = gradpsii * (replicate(1,nth1) # drhodpsi1)



drho1=[rho1(0),rho1(1:npsi1-1)-rho1(0:npsi1-2)]
drho1i=replicate(1,nth1) # drho1
drdrho = dri / drho1i

vprime=fltarr(npsi1)
av1orsq=fltarr(npsi1)
avgrhoorsq=fltarr(npsi1)
avgjay=fltarr(npsi1)
avgcur=avgjay
for i=0,npsi1-1 do begin
   vprime(i) = total(drdrho(*,i) * dli(*,i)*2*!pi*rri(*,i)) 
   av1orsq(i) = total(1/rri(*,i)^2 * dli(*,i)) / total(dli(*,i))
   avgrhoorsq(i)=total(gradrhoi(*,i)^2 / rri(*,i)^2 * dli(*,i)) / total(dli(*,i))

   avgjay(i) = total(jayi(*,i) * dli(*,i) ) / total(dli(*,i))
   avgcur(i) = total(jayi(*,i) * dri(*,i) * dli(*,i) * sinchi(*,i) )
endfor
avgcur=smooth(avgcur,3)
cur=total(avgcur,/cum)

vprime=smooth(vprime,3)


s1=smooth(avgrhoorsq,5)
ist=7
avgrhoorsq(0:ist) = interpol(s1(ist:*),intspace(ist,npsi1-1),findgen(ist+1))
s1=smooth(av1orsq,5)
av1orsq(0:ist) = interpol(s1(ist:*),intspace(ist,npsi1-1),findgen(ist+1))

c2=vprime * avgrhoorsq
c3=vprime * av1orsq



;rhoi=findgen(npsi1+1)/(npsi1) * max(rho) & rhoi=rhoi(1:*)
nrhoi=101
rhoi=findgen(nrhoi)/(nrhoi-1) * max(rho) 
ix=interpol(findgen(npsi1),rho1,rhoi)
vprimei=interpolate(vprime,ix) & vprimei(0)=0
c2i=interpolate(c2,ix) & c2i(0)=0
c3i=interpolate(c3,ix) & c3i(0)=0

curi=interpolate(cur,ix) & curi(0)=0
avgcuri=interpolate(avgcur,ix) & avgcuri(0)=0
avgjayi=interpolate(avgjay,ix); & avgjayi(0)=0


;getece,9323,res
;iw=value_locate(res.t,2.)
;tmp1=res.v(iw,*)
;rr1=res.r - 0.1
;tmp1(0:20)=linspace(0,tmp1(20),21)
;tmp1(27)=0.5*(tmp1(26)+tmp1(28))
;tmp1=reform(tmp1)
;plot,rr1,tmp1
iz0=nz/2
iax=value_locate(r,p0(0))
;psintemp=interpol(psinrz(iax:*,iz0),r(iax:*),rr1)
;rhotemp=interpol(rho1,psin1,psintemp)
;tmp1=reverse(tmp1)
;rhotemp=reverse(rhotemp)
;tmp1=[tmp1(0),tmp1]
;rhotemp=[min(rhotemp)-0.03,rhotemp]
;tempi=interpol(tmp1,rhotemp,rhoi)
;plot,rhoi,tempi
;zeff=2

;etai = 2.8e-8 * (tempi/1e3) ^(-1.5) *zeff; ohm-m
mu0=4*!pi*1d-7
cfront = 1 * rhoi / mu0 / c3i^2
cmiddle = c2i * c3i / rhoi
cmiddle(0)=0.
cfront(0)=cfront(1)

psini2=interpol(psin,rho,rhoi)
psiav=psini2 * (g.ssibry-g.ssimag) + g.ssimag

;save,cfront,cmiddle,rhoi,vprimei,c2i,c3i,psiav,file='~/geom.sav',/verb


tempa=2e3
cneo=1
seta = 2.8e-8 * (tempa/1e3) ^(-1.5) / cneo

ll = 0.05;5;25
tconst = mu0/seta  * ll^2
print,tconst

curb = 1/drhodpsi1 * c2 / (2*!pi * mu0)/1e6

cur2d=interpol(cur,psin1,psi2d)
calculate_bfield,bp,br,bt,bz,g

bmid=bz(*,iz0)
imid=cur2d(*,iz0)
idx=where(psi2d gt 1)
cur2d(idx)=!values.f_nan
plot,g.r,bmid

iax=value_locate(g.r,g.rmaxis)
bout=interpol(bz(iax:*,iz0),psi2d(iax:*,iz0),psin1)
bin=interpol(bz(0:iax,iz0),psi2d(0:iax,iz0),psin1)

plot,rho1, bout*2*!pi*rho1 / (4*!pi*1e-7)
oplot,rho1, cur,col=2

stop
return,curi
end
