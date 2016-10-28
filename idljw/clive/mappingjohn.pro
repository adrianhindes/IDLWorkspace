;@getptsnew
;goto,af

;goto,ee

;newdemod,img,cars,/doload,/doplot,sh=sh,ifr=ifr,demodtype=demodtype
sh=8986
readpatch,sh,p
p.binx=1
p.biny=1
n=16
nn=n
ix2=findgen(2560/nn)*nn
iy2=findgen(2160/nn)*nn


getptsnew,rarr=r,zarr=z,str=p,ix=ix2,iy=iy2,pts=pts;,/plane

stop

;getptsnew,rarr=r2,zarr=z2,str=p,ix=ix2,iy=iy2,pts=pts

sz=size(r,/dim)
sz2=sz*n
;rr=congrid(r,sz2(0),sz2(1),/interp)
;zz=congrid(z,sz2(0),sz2(1),/interp)
rr=interpolate(r,$
               interpol(findgen(2560/nn),ix2,findgen(2560)),$
               interpol(findgen(2160/nn),iy2,findgen(2160)),/grid)

zz=interpolate(z,$
               interpol(findgen(2560/nn),ix2,findgen(2560)),$
               interpol(findgen(2160/nn),iy2,findgen(2160)),/grid)
               

;save,rr,zz,file='~/coords_8986_r_z.sav',/verb

end
