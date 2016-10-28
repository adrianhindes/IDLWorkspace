@getptsnew
goto,af
sh=7426
off=52 ; 2.5s
newdemodflc,sh, off,dopc=dopc1,angt=ang1,eps=eps1,ix=ix2,iy=iy2,pp=p


sh=7485
off=52 ; 2.5s

newdemodflc,sh, off,dopc=dopc1b,angt=ang1b,only2=1


sh=1203
off=5 ; 2.5s
newdemodflc,sh, off,dopc=dopc2,angt=ang2;,only2=1
af:
dd=dopc1-dopc2
dd=dd*!dtor
jumpimg,dd
dd=dd*!radeg

ddb=dopc1b-dopc2
ddb=ddb*!dtor
jumpimg,ddb
ddb=ddb*!radeg

iy=100
plot,dd(*,iy),yr=[-400,300]
oplot,ddb(*,iy),col=2
dd2=ddb-dd
oplot,dd2(*,iy),col=3


getptsnew,rarr=r2,zarr=z2,str=p,ix=ix2,iy=iy2,pts=pts,cdir=cdir,ang=ang


;endfig,/jp,/gs



;, only2=only2, eps=eps,angt=ang,dop1=dop1,dop2=dop2,doplot=doplot,cacheread=cacheread,cachewrite=cachewrite,dop3=dop3,dopc=dopc,dostop=dostop,ang0=ang0,pp=p,str=str,sd=sd,noload=noload,vkz=vkz,lin=lin,inten=inten,ix=ix,iy=iy,plotcar=plotcar,cix=cix,ciy=ciy,only1=only1,cars=cars
end
