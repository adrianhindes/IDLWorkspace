function getfwhm,x,y
dum=max(y,imax)
n=n_elements(y)
i0=intspace(0,imax)
i1=intspace(imax,n-1)
yn=y/dum
x1=interpol(x(i0),yn(i0),0.5)
x2=interpol(x(i1),yn(i1),0.5)
wid=x2-x1
return,wid
end


pro ocircle,pts
rrng=[170,240]
nr=8
rval=linspace(rrng(0),rrng(1),nr)
th=linspace(0,2*!pi,100)
cth=cos(th)
sth=sin(th)

for i=0,nr-1 do oplot,rval(i)*cth,rval(i)*sth,col=2

sz=size(pts,/dim)
for i=0,sz(0)-1 do oplot,pts(i,sz(1)/2,*,0),pts(i,sz(1)/2,*,1),col=3

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

fileali='~/idl/clive/nleonw/kmse_7891n2/irset.sav'&uc=fltarr(2560,2160)
;getimg(7983,index=34,sm=4,path='/home/cam112/prlpro/res_jh/mse_data')<2000 
 imgbin=4 & uc=float(uc)&uc-=300&uc=uc>0&cmno=24&ii=200


;fileali='~/idl/clive/nleonw/kmse_mate/irset.sav'&uc=read_tiff('~/idl/clive/nleonw/kmse_mate/beam2.tif')&uc=reform(uc(0,*,*))&uc=rotate(uc,5) & imgbin=2 & &cmno=16&ii=400

;fileali='~/idl/clive/nleonw/kmse_7345n2/irset.sav'&uc=getimg(7451,index=44,sm=1,path='/home/cam112/prlpro/res_jh/mse_data',/mdsplus,/flipy)<1000 & imgbin=2 & uc=float(uc)&uc-=00&uc=uc>0&cmno=12&ii=400
;prev line one for NBI2 only
doback=0

dores=0
docmb=0


if dores eq 1 then restore,file='/home/cam112/rsphy/fres/KSTAR/26887/cd_26887.00230_A02_1_CM'+string(cmno,format='(I0)')+'.dat',/verb  
;if dores eq 1 and docmb eq 1 then combinebeams,cd


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




u=(reform(cd.coords.u,nx,ny,nz))[*,*,0]
v=(reform(cd.coords.v,nx,ny,nz))[*,*,0]
z=reform(z2(0,0,*))
x=reform(x2(*,0,0))
y=reform(y2(0,*,0))
rotangle=cd.inputs.nbgeom.alpha

em=reform(total(cd.neutrals.frspectra[*,*,*,0],2),nx,ny,nz)     
ems=total(em,3)

em2=reform(total(cd.neutrals.frspectra[*,*,*,1],2),nx,ny,nz)     
ems2=total(em2,3)

readpatch,9414,str,db='k',nfr=1
getptsnew,pts=pts,str=str,bin=64,rarr=rarr,zarr=zarr,/plane
mkfig,'~/beams.eps',xsize=28,ysize=10,font_size=8
contourn2,ems+ems2,u,v,/cb,/iso,pos=posarr(4,1,0,cny=0.1),title='both beams'
ocircle,pts
contourn2,ems,u,v,/cb,/iso,pos=posarr(/next),/noer,title='beam 2'
ocircle,pts
contourn2,ems2,u,v,/cb,/iso,pos=posarr(/next),/noer,title='beam 1'
ocircle,pts

print,'theor fwhm=', 0.8*2*sqrt(alog(2))*!dtor * 1300.

plot,y,ems(63/2,*)+ems2(63/2,*),pos=posarr(/next),/noer,title='transverse profiles, 11.5m from beam source',xtitle='cm across beam'
oplot,y,ems(63/2,*),col=2
oplot,y,ems2(63/2,*),col=3
print,'fwhm 1=',getfwhm(y,ems(63/2,*))
print,'fwhm 2=',getfwhm(y,ems2(63/2,*))
endfig,/gs,/jp
end


