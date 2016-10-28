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
    view.yaw=-view.yaw+5
    view.hei=0.2
    view.pit = view.pit * 28./28.
    view.flen=view.flen/4*1.5
    view.flen=13.5;5;3;17;13;17.5;9.66;05;11.8;'9.5;13.47
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

end


pro getpts,sz,bin,imgbin,pts,file=file,doback=doback,flen=flen

;bin=8;0


;sz=[688,520] / bin

;sz=[688,512] / bin
psiz=6.5e-6*imgbin * bin

nx=sz(0)*1l
ny=sz(1)*1L
ix1=indgen(nx)
iy1=indgen(ny)


ix=reform(ix1 # replicate(1,ny),nx*ny)
iy=reform(replicate(1,nx) # iy1,nx*ny)
np=nx*ny


getax,xhat,yhat,zhat,p0,flen=flen,distt=dist,distcx=distcx,distcy=distcy,file=file,doback=doback

cdir=fltarr(3,np)
p0p=cdir
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

fileali='~/idl/clive/nleonw/kmse_7891n2/irset.sav'& imgbin=1 

;sz=fix([7.1,4.7]/6.5e-3)/4*4

sz=[2560/2,2560/2*4/6*40./39.] * 3./4.
cmno=18&ii=200 ; sensicam dims [688,580]
;[1376,1040]/2

;fileali='~/idl/clive/nleonw/kmse_mate/irset.sav'&uc=read_tiff('~/idl/clive/nleonw/kmse_mate/beam2.tif')&uc=reform(uc(0,*,*))&uc=rotate(uc,5) & imgbin=2 & &cmno=16&ii=400

;fileali='~/idl/clive/nleonw/kmse_7345n2/irset.sav'&uc=getimg(7451,index=44,sm=1,path='/home/cam112/prlpro/res_jh/mse_data',/mdsplus,/flipy)<1000 & imgbin=2 & uc=float(uc)&uc-=00&uc=uc>0&cmno=12&ii=400
;prev line one for NBI2 only
doback=1

dores=0


if dores eq 1 then restore,file='/home/cam112/rsphy/fres/KSTAR/26887/cd_26887.00230_A02_1_CM'+string(cmno,format='(I0)')+'.dat',/verb  

;createvig,size(uc,/dim),vig,imgbin=imgbin
;vig=uc*0+1



bin=8*2;0

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

;em=reform(total(cd.neutrals.frspectra,2),nx,ny,nz)     

em=reform(cd.neutrals.fdens(*,0),nx,ny,nz)     




;em*=0&em(*,ny/2,nz/2)=1.
;em=exp(-(y2^2+z2^2) / (1.^2) )
;em=exp(-(rho-1.0)^2 / 0.1^2)*inout
;em=exp(-(r2-230)^2 / 2.5^2);*inout
;emt=em & em*=0 & for i=0,ny-1 do em(*,ny/2,*)=emt(*,ny/2,*)

emv=totaldim(em,[0,0,1])
emh=totaldim(em,[0,1,0])
r2h=reform(r2(*,ny/2,*))

;set_plot,'ps'
;device,file='~/rsphy/a.ps',/landscape
;set_plot,'metafile'
;device,file='pr.
xr=[-220,-60]&yr=[-60,60]&pos=[0,0,1,1]

xsiz=abs(xr(1)-xr(0))
ysiz=abs(yr(1)-yr(0))

nx2=nx*5
nz2=nz*5
ix=linspace(0,nx-1,nx2)
iz=linspace(0,nz-1,nz2)
emh1=interpolate(emh,ix,iz,/grid,cubic=-0.5)
xx1=interpolate(xx,ix)
zz1=interpolate(zz,iz)


mkfig,'~/rsphy/pr.eps',xsize=xsiz,ysize=ysiz,font_size=24*4



contour,emh1/max(emh1),-xx1,zz1,/iso,c_lab=replicate(1,10),lev=linspace(0.1,1,10),xr=xr,yr=yr,xsty=1+4,ysty=1+4,pos=pos,thick=30
contour,r2h,-xx,zz,/iso,/noer,c_lab=replicate(1,10),lev=linspace(170,230,7),c_col=[2,2,2,2,2,2,2],xr=xr,yr=yr,xsty=1+4,ysty=1+4,pos=pos,thick=30
defcirc,/fill
nx=(xr(1)-xr(0))/5.
ny=(yr(1)-yr(0))/5.

x1=xr(0)+findgen(nx)*5.
y1=yr(0)+findgen(ny)*5.

x2=x1 # replicate(1,ny)
y2=replicate(1,nx) # y1
oplot,x2,y2,psym=8,symsize=1/4.*1.5


endfig;,/gs
;device,/close
set_plot,'x'
end
