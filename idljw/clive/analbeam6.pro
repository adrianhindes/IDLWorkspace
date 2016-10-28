@filt_common
pro analbeam6, ibeam,ans,ans2,signin,uselin,cmno=cmno,cwl=cwl,switchans=switchans
doback=0

default,cmno,31;2;31 ;32 is all 90 31 is 95,80,70
dores=1
docmb=1
dosimp=0
dofill=0

wtbeam=[0,0,0]
wtbeam(ibeam)=1

;basepath='/home/cam112/rsphy/fres/KSTAR/26887/'
basepath='/tmp/'
if dores eq 1 then restore,file=basepath+'/smcd_26887.00230_A02_1_CM'+string(cmno,format='(I0)')+'.dat',/verb  
if dores eq 1 and docmb eq 1 then combinebeams3,cd,wt=wtbeam

;createvig,size(uc,/dim),vig,imgbin=imgbin
;vig=uc*0+1


 
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

;em=reform(total(cd.neutrals.frspectra,2),nx,ny,nz)     

nlam=n_elements(cd.spectra.lambda)
stoklam=fltarr(nx*ny*nz,nlam,4)
stoklam(*,*,0)=cd.neutrals.srspectra0
stoklam(*,*,1)=cd.neutrals.srspectra1
stoklam(*,*,2)=cd.neutrals.srspectra2
stoklam(*,*,3)=sqrt(stoklam(*,*,1)^2 + stoklam(*,*,2)^2 )

spv=reform(stoklam,nx,ny,nz,nlam,4)


;hack to make midplane

;; simple model
if dosimp eq 1 then begin
   spv1=spv(*,ny/2,*,*,*)&spv*=0&spv(*,ny/2,*,*,*)=spv1
endif

if dofill eq 1 then spv = spv * 0 + 1


;readpatch,9414,str,db='k',nfr=1

readpatch,9998,str,db='k',nfr=1


;readpatch,8943,str,db='c',nfr=1 ; for i port

getptsnew,pts=pts,str=str,bin=16,rarr=r,zarr=z,/plane,ix=ix2,iy=iy2,rxs=rxs,rys=rys,/calca,detx=detx,dety=dety

getptsnew,pts=pts,str=str,bin=16,rarr=rb2,zarr=zb2,/plane,ix=ix2,iy=iy2,rxs=rxs2,rys=rys2,/calca,detx=detx2,dety=dety2,/dobeam2

sz=size(z,/dim)

iz0=value_locate(z(sz(0)/2,*),0)
szb=size(pts(*,*,0,0),/dim)

ptsr=pts

ptst=pts
ptst(*,*,*,0)-=uo
ptst(*,*,*,1)-=vo
rotangle=-rotangle
ptsr(*,*,*,0) = ptst(*,*,*,0) * cos(rotangle) - ptst(*,*,*,1) * sin(rotangle)
ptsr(*,*,*,1) = ptst(*,*,*,1) * cos(rotangle) + ptst(*,*,*,0) * sin(rotangle)

;if dores eq 0 then goto,ee
ix=interpol(findgen(n_elements(xx)),xx,ptsr(*,iz0,*,0))
iy=interpol(findgen(n_elements(yy)),yy,ptsr(*,iz0,*,1))
iz=interpol(findgen(n_elements(zz)),zz,ptsr(*,iz0,*,2))
;stop
spvr=fltarr(szb(0),1,nlam,4)
for il=0,nlam-1 do for k=0,3 do begin
tmp=interpolate(spv(*,*,*,il,k),ix,iy,iz,missing=0)
spvr(*,0,il,k)=total(tmp,3)
;print,il,nlam
endfor

ee:
lam=cd.spectra.lambda*1e9

default,cwl,661.1
scalld,la,fa,l0=cwl,fwhm=2.,opt='a3'

;scalld,la,fa,l0=651.1,fwhm=2.,opt='a3'

nxim=n_elements(pts(*,0,0,0))
nyim=n_elements(pts(0,*,0,0))


filtstr={nref:2.05,cwl:cwl} ;651.};
thetatilt=signin*2*!dtor;4.*!dtor;


nlam=n_elements(lam)
f2=fltarr(nlam,nxim,1)
tshiftarr=fltarr(nxim,1)
dshift2=tshiftarr

mom=fltarr(nxim,1,3,4)
;topl=transpose(reform(spvr(*,15,*,0)))

par3={crystal:'bbo',thickness:5e-3,lambda:lam*1e-9,facetilt:30*!dtor}
nwav1=opd(1e-6,0.,par=par3,delta=!pi/4)/2/!pi

par4={crystal:'linbo3',thickness:1*.46e-3,lambda:lam*1e-9,facetilt:0*!dtor}
nwav2=opd(1e-6,0.,par=par4,delta=!pi/4)/2/!pi
nwav = nwav1 + nwav2 * uselin
;stop
eikonal = exp(complex(0,1)*2*!pi*nwav)
spvrw=complexarr(nxim,1,4)
for i=0,nxim-1 do for j=0,0 do begin
   jj=j+iz0
    thetax = detx(i)*1e-3/85e-3 - thetatilt
    thetay = dety(jj)*1e-3/85e-3 
    thetao=sqrt(thetax^2+thetay^2)
    dlol=1-sqrt(filtstr.nref^2-sin(thetao)^2)/filtstr.nref
    tshifted=filtstr.cwl*dlol ;lam0c=lam0*(1-dlol)
    tshiftarr(i,j)=tshifted
    f2(*,i,j)=interpolo(fa,la,lam+tshifted)  
;    f2(*,i,j)=1.;!!!!!!!!!!!!!!!!!!
    for k=0,3 do for h=0,2 do begin
        exp=1.
        if h eq 0 then premu=1.
        if h eq 0 then denom=1 else denom=mom(i,j,0,k)
        if h eq 1 then premu=lam
        if h eq 2 then premu=(lam-mom(i,j,1,k))^2
        if h eq 2 then exp=0.5
        mom(i,j,h,k)=( total(spvr(i,j,*,k)*f2(*,i,j) * premu) / denom )^exp
;        mom(i,j,h,k)=( total(spvr(i,j,*,k) * premu) / denom )^exp

    endfor

    for k=0,3 do begin
        spvrw(i,j,k) = total(spvr(i,j,*,k)*f2(*,i,j)*eikonal)
    endfor

endfor

;; c1=complex(float(spvrw(*,*,1)) - imaginary(spvrw(*,*,2)) , $
;;            -float(spvrw(*,*,2)) - imaginary(spvrw(*,*,1)) )

;; c2=complex(-float(spvrw(*,*,1)) - imaginary(spvrw(*,*,2)) , $
;;            -float(spvrw(*,*,2)) + imaginary(spvrw(*,*,1)) )


c1 = spvrw(*,*,1) + complex(0,1) * spvrw(*,*,2)
c2 = spvrw(*,*,1) - complex(0,1) * spvrw(*,*,2)

p1=atan2(c1)
p2=atan2(c2)
p1=phs_jump(p1)
p2=phs_jump(p2)
;jumpimg,p1
;jumpimg,p2

psia=(p1-p2)/4
psid=(p1+p2)/2.



;mgetptsnew,rarr=r,zarr=z,str=p,ix=ix2,iy=iy2,pts=pts,rxs=rxs,rys=rys,/calca,dobeam2=dobeam2,distback=distback,mixfactor=mixfactor;,/plane


;gfile='/home/cam112/rsphy/idl/g007485.002500'
;g=readg(gfile)
g=cd.inputs.g

calculate_bfield,bp,br,bt,bz,g
;br*=-1
;bz*=-1;flip as though bt were flipped

bt*=-1

for jbeam=0,1 do begin
if jbeam eq 0 then begin
   rtmp=r
   ztmp=z
   rxstmp=rxs
   rystmp=rys
endif
if jbeam eq 1 then begin
   rtmp=rb2
   ztmp=zb2
   rxstmp=rxs2
   rystmp=rys2
endif

ix=interpol(findgen(n_elements(g.r)),g.r,rtmp*.01)
iy=interpol(findgen(n_elements(g.z)),g.z,ztmp*.01)
bt1=interpolate(bt,ix,iy)
br1=interpolate(br,ix,iy)
bz1=interpolate(bz,ix,iy)
psi=interpolate((g.psirz-g.ssimag)/(g.ssibry-g.ssimag),ix,iy)
psiun=interpolate((g.psirz),ix,iy)
;rys(0,*)=0.
sgn=keyword_set(invang) ? -1 : 1
ey=rystmp(*,*,0) * br1 + rystmp(*,*,1) * bt1 + rystmp(*,*,2) * bz1
ex=rxstmp(*,*,0) * br1 + rxstmp(*,*,1) * bt1 + rxstmp(*,*,2) * bz1
ex*=sgn
tang2=ex/ey                     ;atan(ex,ey)*!radeg
if jbeam eq 0 then ang2=atan(-ex,-ey)*!radeg
if jbeam eq 1 then ang22=atan(-ex,-ey)*!radeg
endfor

iy=iz0
ix=14;7;*2+1

plot,ang2(*,iy);,pos=posarr(1,2,0)
;oplot,ang22(*,iy),col=2
oplot,psia*!radeg+45,thick=2
lr=[660*0,662*1e9]
idx=where(lam ge lr(0) and lam le lr(1))
th=fltarr(40)
for i=0,39 do begin
   dum=max(spvr(i,0,idx,0),imax)
   s1=spvr(i,0,idx(imax),1)
   s2=spvr(i,0,idx(imax),2)
   th1=atan(s2,s1)/2*!radeg
   th(i)=th1
endfor

;plots,[ix,-th1],psym=4
;plot,lam,spvr(10,8,*,0),xr=[660,662],psym=-4

;stop
;erase

imgplot,reform(spvr(*,*,*,0)) ,indgen(40),lam,pos=posarr(1,1,0);,/;noer
contour,transpose(f2),indgen(40),lam,/noer ,pos=posarr(/curr)
oplot,mom(*,0,1,0),thick=3

plot,psid,/noer,thick=3,col=2


ans=mom(*,0,1,0)
ans3=psid

ans2=phs_jump(atan2(spvrw(*,0,3)))


if keyword_set(switchans) then ans2=ans3
;stop




;top=imaginary(spvrw(*,*,2))
;bottom=float(spvrw(*,*,1))
;p1=atan(-top,bottom)
;p2=atan(-top,-bottom)
;imgplot,topl,lam,indgen(50),pos=posarr(3,1,0)
;imgplot,f2,lam,indgen(50),pos=posarr(/next),/noer
;imgplot,topl*f2,lam,indgen(50),pos=posarr(/next),/noer



;for i=0,nxim-1 do begin
;lstop


end


pro t1
;goto,eea
;window,1
;analbeam6,1,ans1x,ans1,1.,1
window,2
analbeam6,1,ans2x,ans2,-1.,1
window,3
analbeam6,1,ans3x,ans3,0,1
eea:
window,0
plot,ans1-ans1(20)
oplot,(ans2-ans2(20))*1.,col=2
oplot,(ans3-ans3(20))*1.,col=3
stop
plot,ans1x-ans1x(20)
oplot,(ans2x-ans2x(20))*1.,col=2
oplot,(ans3x-ans3x(20))*1.,col=3


;window,2
;analbeam6,2
end


pro t2
window,1
analbeam6,1,ans1x,ans1,1.,0,cmno=31
window,2
analbeam6,1,ans2x,ans2,-1.,0,cmno=31
window,3
plot,ans1-ans1(20)
oplot,(ans2-ans2(20)),col=2

end

