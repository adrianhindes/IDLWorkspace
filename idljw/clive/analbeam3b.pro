@filt_common
pro createvig,sz,vig,imgbin=imgbin
; for roi 1600x1644 pco edge images
x=findgen(sz(0))
mid=[  0.415375,     0.459976]

theta = (x - sz(0)*mid(0)) * 6.5e-3 * imgbin / 55. * !radeg
y=findgen(sz(1))
thetay = (y - sz(1)*mid(1)) * 6.5e-3 * imgbin / 55. * !radeg
thx2=theta # replicate(1,n_elements(thetay))
thy2=replicate(1,n_elements(theta)) # thetay
th2=sqrt(thx2^2+thy2^2)
vig=vigfunc2(th2)
end





pro getax,xhat,yhat,zhat,p0,flen=flen,distt=dist,distcx=distcx,distcy=distcy,file=file,doback=doback

;view={tor:134.35,$
;      rad:2.208,$
;      hei:0.2,$
;      yaw:0.,$
;      pit:-14.,$
;      rol:0.}

;view={tor:134.935,$
;      rad:2.22626,$
;      hei:0.199349,$
;      yaw:-0.939619,$;
;      pit:-13.0344,$
;      rol:-0.562990}
;flen=4.81661e-3
;dist=0.239977


;restore,file='~/idl/clive/nleonw/kmse2/irset.sav',/verb

restore,file=file

;restore,file='~/idl/clive/nleonw/kmse_7891/irset.sav',/verb
;restore,file='~/idl/clive/nleonw/kmse_7891n2/irset.sav',/verb

view=str
;stop



;focal length: 4.81661
; dist1/rad2 = 0.239977
;centx=0.5
;centy=0.7
;stop
;  FLEN            FLOAT           25.3598
;   DIST            FLOAT           0.00000
;   RAD             FLOAT           2.88900
;   TOR             FLOAT           113.320
;   HEI             FLOAT          0.285000
;   YAW             FLOAT           45.0985
;   PIT             FLOAT          -6.49085
;   ROL             FLOAT           7.21060
;   DISTCX          FLOAT          0.500000
;   DISTCY          FLOAT          0.500000

if keyword_set(doback) then begin
    view.tor=view.tor-90
    view.yaw=-view.yaw+5;2
    view.hei=0.2
    view.pit = view.pit * 28./28.
    view.flen=view.flen/4*1.5
    view.flen=13.;21.8;13.5;5;3;17;13;17.5;9.66;05;11.8;'9.5;13.47
    print,'efl = ',view.flen
endif

flen=view.flen*1e-3
dist=view.dist
distcx=view.distcx
distcy=view.distcy

ang=view.tor*!dtor
r=view.rad*1e2
z=view.hei*1e2
yaw=view.yaw*!dtor


ang2=ang+yaw-!pi
pit=view.pit*!dtor
rol=view.rol*!dtor


;z=-z*0
;pit=pit*1.2
;rol=-rol*0.4*0
;flen=flen*0.7
;stop
;pit*=1.3
;stop
;z/=2
;z=0
;pit=0.
;rol=0.

;
p0=[r*cos(ang),r*sin(ang),z]

zhat=[cos(ang2)*cos(pit),sin(ang2)*cos(pit),sin(pit)] & zhat=zhat/norm(zhat)
xhat=-crossp([0,0,1],zhat) & xhat=xhat/norm(xhat)
yhat=-crossp(zhat,xhat) & yhat=yhat/norm(yhat)

; ah ! xhat and y hat did not include any "roll" of camera about its
; axis.  This is defined by xhat2,yhat2

xhat2=xhat * cos(rol) + yhat * sin(rol)
yhat2=-xhat*sin(rol) +  yhat * cos(rol)

;stop
xhat=xhat2 ; and overwrite the orinal array
yhat=yhat2

   us_NB        = -4.5*[1,1];[53.9,-139.85]		; abscissa coordinate of beam aperture (cm)
   vs_NB        = 370.8*[1,1];[-192.6,-142.98]		; vertical coordinate of beam aperture (cm)
   alpha_NB     = [(-90+24.3)*!dtor,(-90+24.3+4)*!dtor];-180*!dtor		; angle of injected beam relative to u axis (radians)


solint,[us_NB(0),vs_NB(0),0],[cos(alpha_NB(0)),sin(alpha_NB(0)),0],p0,zhat,ca,cb,a,b
;stop
end



pro getpts,sz,bin,imgbin,pts,file=file,doback=doback,detx=detx

;bin=8;0


;sz=[688,520] / bin

;sz=[688,512] / bin
psiz=6.5e-6*imgbin * bin

nx=sz(0)
ny=sz(1)
ix1=indgen(nx)
iy1=indgen(ny)


ix=reform(ix1 # replicate(1,ny),nx*ny)
iy=reform(replicate(1,nx) # iy1,nx*ny)
np=nx*ny


getax,xhat,yhat,zhat,p0,flen=flen,distt=dist,distcx=distcx,distcy=distcy,file=file,doback=doback

cdir=fltarr(3,np)
p0p=cdir

detx=((ix1-sz(0)/2) * psiz)

for i=0,np-1 do begin

    thx=((ix(i)-sz(0)/2) * psiz/flen)
    thy=((iy(i)-sz(1)/2) * psiz/flen)

;    print,"thx,thy",thx,thy
    thxc=((sz(0)*distcx-sz(0)/2) * psiz/flen)
    thyc=((sz(1)*distcy-sz(1)/2) * psiz/flen)

    thx=atan(thx-thxc)
    thy=atan(thy-thyc)

;    print,thx*!radeg,thy*!radeg
    thr = sqrt((thx)^2+(thy)^2)
    fac=(1 - dist * thr^2 + 3 * dist^2 * thr^4)
;    print,'fac=',1-fac,i,np
;    stop
    thx = (thx )* fac
    thy = (thy )* fac
    
    thx=thx+atan(thxc)
    thy=thy+atan(thyc)


    cdir1=zhat + xhat * tan(thx) + yhat * tan(thy)
    cdir1=cdir1/norm(cdir1)
    cdir(*,i)=cdir1
    p0p(*,i)=p0

;    pv=[ -1196.07   ,   918.184   ,  -364.050]/10.

;    tmp=(pv-p0)/cdir1
;    print,tmp/tmp(0)
;    stop

endfor
nl=100*3
lene=[50,400]
len=linspace(lene(0),lene(1),nl)
dl=(len(1)-len(0) ) * 0.01 ; cm to m
pts=fltarr(np,nl,3)
for i=0,np-1 do begin
    for j=0,2 do pts(i,*,j)=p0p(j,i) + cdir(j,i) * len
endfor


pts=reform(pts,nx,ny,nl,3)
end


;img=getimg(7350,index=20,/mdsplus,info=info,/getinfo,/flipy)

;uc=getimg(7350,index=6,/mdsplus,info=info,/getinfo,/flipy)& imgbin=4


;uc=getimg(7430,index=71,/mdsplus,info=info,/getinfo,/flipy,sm=2)<200 & imgbin=4

;uc=getimg(7891,index=25,sm=1,path='/home/cam112/prlpro/res_jh/mse_data')>350<600& imgbin=1;for finding references
;stop
;uc=getimg(7894,index=35,sm=4,path='/home/cam112/prlpro/res_jh/mse_data')<2000 & imgbin=4; smaller radius on

;uc=getimg(7983,index=34,sm=4,path='/home/cam112/prlpro/res_jh/mse_data')<2000 & imgbin=4 & uc=float(uc)&uc-=400.& uc=uc>0


;uc=getimg(7485,index=52,sm=1,path='/home/cam112/prlpro/res_jh/mse_data',/mdsplus,/flipy) & imgbin=2 & uc=float(uc)

;uc=getimg(7869,index=50,info=info,/getinfo,path=getenv('HOME')+'/prlpro/res_jh/mse_data',sm=4)&imbin=4;;;used for vignetting



;fileali='~/idl/clive/nleonw/kmse_7345n2/irset.sav'&uc=getimg(7485,index=52,sm=1,path='/home/cam112/prlpro/res_jh/mse_data',/mdsplus,/flipy) & imgbin=2 & uc=float(uc)&cmno=13&ii=400
;7897/13
;7983/34
;.201303201517


;goto,ee
doback=1

dores=1

fileali='~/idl/clive/nleonw/kmse_7891n2/irset.sav'& imgbin=1 

;sz=fix([7.1,4.7]/6.5e-3)/4*4

;sz=[2560/2,2560/2*4/6*40./39.] * 3./4.
sz=[2560/2,2160/2]
sz=fix([2160/2,2560/2] * 0.97)
if doback eq 1 then cmno=25 else cmno=19
if doback eq 0 then sz=[1600,1600]
;cmno=18
ii=200 ; sensicam dims [688,580]
;[1376,1040]/2


;fileali='~/idl/clive/nleonw/kmse_7891n2/irset.sav'&uc=getimg(7983,index=34,sm=4,path='/home/cam112/prlpro/res_jh/mse_data')<2000 & imgbin=4 & uc=float(uc)&uc-=300&uc=uc>0&cmno=25&ii=200


;fileali='~/idl/clive/nleonw/kmse_mate/irset.sav'&uc=read_tiff('~/idl/clive/nleonw/kmse_mate/beam2.tif')&uc=reform(uc(0,*,*))&uc=rotate(uc,5) & imgbin=2 & &cmno=16&ii=400

;fileali='~/idl/clive/nleonw/kmse_7345n2/irset.sav'&uc=getimg(7451,index=44,sm=1,path='/home/cam112/prlpro/res_jh/mse_data',/mdsplus,/flipy)<1000 & imgbin=2 & uc=float(uc)&uc-=00&uc=uc>0&cmno=12&ii=400
;prev line one for NBI2 only


if dores eq 1 then restore,file='/home/cam112/rsphy/fres/KSTAR/26887/cd_26887.00230_A02_1_CM'+string(cmno,format='(I0)')+'.dat',/verb  


sz=fix([2160/2,2560/2] * 0.97)

;createvig,size(uc,/dim),vig,imgbin=imgbin
;vig=uc*0+1


;sz=size(uc,/dim)

bin=8*4;0

szb=sz / bin

xx=cd.coords.xx
yy=cd.coords.yy
zz=cd.coords.zz
nx=cd.coords.nx
ny=cd.coords.ny
nz=cd.coords.nz

x2=reform(cd.coords.x,nx,ny,nz)
y2=reform(cd.coords.y,nx,ny,nz)
z2=reform(cd.coords.z,nx,ny,nz)

;rho=reform(cd.coords.rho,nx,ny,nz)
r2=reform(cd.coords.r,nx,ny,nz)
inout=reform(cd.coords.inout,nx,ny,nz)

gr=cd.inputs.g.r
gz=cd.inputs.g.z
ssimag=cd.inputs.g.ssimag
ssibry=cd.inputs.g.ssibry
ix=interpol(findgen(n_elements(gr)),gr*100,r2)
iy=interpol(findgen(n_elements(gz)),gz*100,z2)
psia=interpolate(cd.inputs.g.psirz,ix,iy)
rhoa=(psia-ssimag)/(ssibry-ssimag)
rho=reform(rhoa,nx,ny,nz)
rho=r2;fudge
uo=cd.coords.uo
vo=cd.coords.vo




u=(reform(cd.coords.u,nx,ny,nz))[*,0,0]
v=(reform(cd.coords.v,nx,ny,nz))[0,*,0]
z=reform(z2(0,0,*))
x=reform(x2(*,0,0))
y=reform(y2(0,*,0))
rotangle=cd.inputs.nbgeom.alpha

em=reform(total(cd.neutrals.frspectra,2),nx,ny,nz)     

nlam=n_elements(cd.spectra.lambda)
stoklam=fltarr(nx*ny*nz,nlam,4)
stoklam(*,*,0)=cd.neutrals.frspectra0+cd.neutrals.hrspectra0+cd.neutrals.trspectra0
stoklam(*,*,1)=cd.neutrals.frspectra1+cd.neutrals.hrspectra1+cd.neutrals.trspectra1
stoklam(*,*,2)=cd.neutrals.frspectra2+cd.neutrals.hrspectra2+cd.neutrals.trspectra2
stoklam(*,*,3)=cd.neutrals.frspectra+cd.neutrals.hrspectra+cd.neutrals.trspectra
spv=reform(stoklam,nx,ny,nz,nlam,4)


getpts,szb,bin,imgbin,pts,file=fileali,doback=doback,detx=detx

ptsr=pts
ptst=pts
ptst(*,*,*,0)-=uo
ptst(*,*,*,1)-=vo
rotangle=-rotangle
ptsr(*,*,*,0) = ptst(*,*,*,0) * cos(rotangle) - ptst(*,*,*,1) * sin(rotangle)
ptsr(*,*,*,1) = ptst(*,*,*,1) * cos(rotangle) + ptst(*,*,*,0) * sin(rotangle)

ix=interpol(findgen(n_elements(xx)),xx,ptsr(*,*,*,0))
iy=interpol(findgen(n_elements(yy)),yy,ptsr(*,*,*,1))
iz=interpol(findgen(n_elements(zz)),zz,ptsr(*,*,*,2))

emr=interpolate(em,ix,iy,iz,missing=0)

rhor=interpolate(rho,ix,iy,iz,missing=0)
emrp=total(emr,3)

rhoav=total(emr*rhor,3) / emrp


;imgplot,emrp
contour,emrp/max(emrp),xsty=1,ysty=1,/iso,lev=linspace(0.1,1.,10),c_lab=replicate(1,10),$
  title='efl='
contour,rhoav,xsty=1+4,ysty=1+4,/iso,c_col=replicate(2,10),lev=linspace(160,230,8),/noer,c_lab=replicate(1,10)

;stop




;goto,ee
;;stop
spvr=fltarr(szb(0),szb(1),nlam,4)
for il=0,nlam-1 do for k=0,3 do begin
tmp=interpolate(spv(*,*,*,il,k),ix,iy,iz,missing=0)
spvr(*,*,il,k)=total(tmp,3)
print,il,nlam
endfor

ee:



lam=cd.spectra.lambda*1e9

;scalld,la,fa,l0=661.1,fwhm=2.,opt='a3'

nxim=n_elements(pts(*,0,0,0))
nyim=n_elements(pts(*,0,0,0))

if doback eq 1 then lc0=651.0 else lc0=660.4;661.1

for jj=0,1 do begin
if jj eq 0 then lc=lc0;+0.2
if jj eq 1 then lc=lc0;+0.2;0.4
scalld,la,fa,l0=lc,fwhm=2.85,opt='a3'
;scalld,la,fa,l0=lc,fwhm=2.,opt='a3'


filtstr={nref:2.05,cwl:lc}
thetatilt=-3*!dtor
if jj eq 1 then thetatilt=-2*!dtor
;if jj eq 1 then thetatilt=(-3+1.2)/2*!dtor

if doback eq 0 then thetatilt=1.12*!dtor
flen=55e-3
nlam=n_elements(lam)
f2=fltarr(nlam,nxim)
dshiftarr=fltarr(nxim)
dshift2=dshiftarr
if doback eq 1 then ysel=20 else ysel=13
topl=transpose(reform(spvr(*,ysel,*,0)))
for i=0,nxim-1 do begin
    thetao = detx(i)/flen - thetatilt
    dlol=1-sqrt(filtstr.nref^2-sin(thetao)^2)/filtstr.nref
    dshifted=filtstr.cwl*dlol ;lam0c=lam0*(1-dlol)
    dshiftarr(i)=dshifted
    f2(*,i)=interpolo(fa,la,lam+dshifted)  
    dshift2(i) = total(topl(*,i)*f2(*,i)*lam) / total(topl(*,i)*f2(*,i))
endfor
if doback eq 1 then xr=[649,654] else xr=[657,664]


absc2=rhoav(*,ysel)
idx=where(finite(absc2))
absc=findgen(nxim)
absc3=linspace(min(absc2),max(absc2),50)
ix=interpol(absc(idx),absc2(idx),absc3)
iy=indgen(nlam)
topl2=interpolate(topl,iy,ix,/grid)
ff2=interpolate(f2,iy,ix,/grid)
if jj eq 0 then imgplot,topl2,lam,absc3,xr=xr,/cb
contour,ff2,lam,absc3,c_col=replicate(jj+2,10),/noer,xr=xr
endfor

stop

dssimp,r1,ds1,en=80.
oplot,ds1,r1,thick=3
; simple caclulation of dopler shift
;vec=reform((pts(*,ysel,1,*)-pts(*,ysel,0,*)))
;vec=vec/(sqrt(total(vec^2,2)) # replicate(1,3))





;imgplot,topl,lam,indgen(nxim),pos=posarr(3,1,0),xr=xr
;imgplot,f2,lam,indgen(nxim),pos=posarr(/next),/noer,xr=xr
;imgplot,topl*f2,lam,indgen(nxim),pos=posarr(/next),/noer,xr=xr
;stop
;;for i=0,60 do begin
;p;lot,lam,topl(*,i),xr=[648,655],xsty=1
;o;plot,lam,f2(*,i)*!y.crange(1),col=2
;cursor,dx,dy,/down
;endfor

;gotoretall
sh=7344

;gencarriers,sh=sh,th=[0,0],kx=kx,ky=ky,dkx=dkx,dky=dky,p=p,str=str,toutlist=toutlist,tkz=kz,kz=kzav,nkz=nkz,mat=mat

gencarriers2,sh=sh,th=[0,0],kx=kx,ky=ky,dkx=dkx,dky=dky,p=p,str=str,toutlist=toutlist,tkz=kz,kz=kzav,nkz=nkz,mat=mat2,tdkz=dkz,dmat=da2,lam=lamref;,fudgethick=5.e-3


xsel=31                         ;nxim/2


;nwav=opd(1e-6,0.,par=par3,delta=!pi/4)
;par={crystal:'bbo',thickness:5e-3,lambda:lam*1e-9,facetilt:30*!dtor}
;nwav=opd(0.,0.,par=par,kappa=kappa)/2/!pi


;for i=0,nxim-1 do begin
slam=reform(spvr(xsel,ysel,*,*)) * (f2(*,xsel) # replicate(1,4))
;slam*=0&slam(300,0:1)=1.
slam(*,3)=0. ; 3rd is not circular rather diff estimate of s0
slam/=total(slam(*,0))

;slam(*,0)=sqrt(slam(*,1)^2 + slam(*,2)^2)

ang=!pi/2*0.7
mpol=matpol(ang)

slamt=slam
for i=0,nlam-1 do begin
    slam(i,*)=mpol ## transpose(slamt(i,*))
endfor


f=lam*1e-9/lamref
nidx=n_elements(nkz)
b2=complexarr(4,nidx)
for i=0,nidx-1 do for beta=0,3 do b2(beta,i) = total($

exp(2*!pi*complex(0,1)*f * kzav(i)) * slam(*,beta))


;b2b=b2*0
;for i=0,nidx-1 do begin
;    b2b(*,i)=mpol ## transpose(b2(*,i))
;endfor
b2b=b2

car=total(b2b*da2,1)
print,abs(car)/abs(car(0))*2
;print,kzav(1)
;print,abs(b2)
;print,atan(abs(b2(2,1)),abs(b2(1,1)))*!radeg
print,sqrt(abs(b2(2,1))^2 + abs(b2(1,1))^2) / abs(b2(0,0))
;slam(*,1)/=
;scl=max(slam(*,1))
plot,lam,slam(*,1),yr=max(abs(slam(*,1)))*[-1,1];/scal;;
;
pd=0*!dtor
ff=1.0
arg1=slam(*,1)*cos(2*!pi*f * kzav(1)*ff+pd)
arg2=slam(*,1)*sin(2*!pi*f * kzav(1)*ff+pd)
oplot,lam,arg1,col=2
oplot,lam,arg2,col=3
print,total(arg1),total(arg2),sqrt(total(arg1)^2 + total(arg2)^2),total(slam(*,0))
end
