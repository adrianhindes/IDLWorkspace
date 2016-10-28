;@getptsnew
;goto,af

;goto,ee

;newdemod,img,cars,/doload,/doplot,sh=sh,ifr=ifr,demodtype=demodtype
sh=8986
readpatch,sh,p
n=16
nn=n
ix2=findgen(2560/nn)*nn
iy2=findgen(2160/nn)*nn


getptsnew,rarr=r,zarr=z,str=p,ix=ix2,iy=iy2,pts=pts,/plane,rxs=rxs,rys=rys,/calca
sz=size(r,/dim)
iz=sz(1)/2

plotm,r(*,iz),reform(rxs(*,iz,*)),pos=posarr(2,1,0),yr=[-1.2,1.2],title='Ex',ysty=1
plotm,r(*,iz),reform(rys(*,iz,*)),pos=posarr(/next),yr=[-1.2,1.2],/noer,title='Ey',ysty=1
legend,['Brad', 'Btor', 'Bz'],col=[1,2,3],linesty=[0,0,0]
retall
nr2=2560/nn
nz2=2160/nn
r2=linspace(min(r),max(r),nr2)
z2=linspace(min(z),max(z),nz2)
r22=r2 # replicate(1,nz2)
z22=replicate(1,nr2) # z2

triangulate, r, z, tri



rxs2=fltarr(nr2,nz2,3)
rys2=rxs2
for i=0,2 do rys2(*,*,i)=trigrid(r,z,rys(*,*,i),tri,xout=r2,yout=z2,missing=!values.f_nan)
for i=0,2 do rxs2(*,*,i)=trigrid(r,z,rxs(*,*,i),tri,xout=r2,yout=z2,missing=!values.f_nan)


g=readg('/home/cam112/idl/g007894.001200')

calculate_bfield,bp,br,bt,bz,g
ix=interpol(findgen(n_elements(g.r)),g.r,r22*.01)
iy=interpol(findgen(n_elements(g.z)),g.z,z22*.01)
bt1=interpolate(bt,ix,iy)
br1=interpolate(br,ix,iy)
bz1=interpolate(bz,ix,iy)
psi=interpolate((g.psirz-g.ssimag)/(g.ssibry-g.ssimag),ix,iy)
;rys(0,*)=0.
ey=rys2(*,*,0) * br1 + rys2(*,*,1) * bt1 + rys2(*,*,2) * bz1
ex=rxs2(*,*,0) * br1 + rxs2(*,*,1) * bt1 + rxs2(*,*,2) * bz1
tang2=ex/ey                     ;atan(ex,ey)*!radeg

ang2=atan(ex,ey)*!radeg
ee:
contourn2,psi,r2,z2,/iso

end
