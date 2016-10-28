;goto,af
sh=7426
off=52 ; 2.5s
newdemodflc,sh, off,dopc=dopc1,angt=ang1,eps=eps1,/dostop


newdemodflc,sh, off,dopc=dopc2,angt=ang2,only2=-1,cars=cars
af:
tit=string(sh,off)
sz=size(ang1,/dim)
iy=sz(1)/2
zr=[60,70.]
;plot,ang1(*,iy),yr=[60,70]
;oplot,ang2(*,iy),col=2

;mkfig,'~/rsphy/cmp_42.eps',xsize=25,ysize=18,font_size=12
contourn2,ang1,/cb,zr=zr,pos=posarr(2,2,0),title=tit+'4 frame demod'
contourn2,ang2,/cb,zr=zr,pos=posarr(/next),/noer,title='2 frame demod'
contourn2,ang2-ang1,/cb,zr=[-3,3]/2.,pos=posarr(/next),/noer,pal=-2,title='difference (deg)'

contourn2,eps1,/cb,zr=[-5,5],pos=posarr(/next),/noer,pal=-2,title='epsilon(deg)'
endfig,/jp,/gs



;, only2=only2, eps=eps,angt=ang,dop1=dop1,dop2=dop2,doplot=doplot,cacheread=cacheread,cachewrite=cachewrite,dop3=dop3,dopc=dopc,dostop=dostop,ang0=ang0,pp=p,str=str,sd=sd,noload=noload,vkz=vkz,lin=lin,inten=inten,ix=ix,iy=iy,plotcar=plotcar,cix=cix,ciy=ciy,only1=only1,cars=cars
end
