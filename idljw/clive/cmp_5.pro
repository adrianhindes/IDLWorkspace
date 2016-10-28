@getptsnew
;goto,af

sh=7426&off=57&only2=-1
sh1=sh&ifr1=off
newdemodflc,sh, off,dopc=dopc1,angt=ang1,eps=eps1,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,cars=cars1,istata=istata1

common cbshot, shotc,dbc,isconnected
shotc=sh
dbc='kstar'

nbi1=cgetdata('\NB11_VG1')      ;\NB11_I0')
;nbi2=cgetdata('\NB12_VG1')
nsm=round( p.dt / (nbi1.t(1)-nbi1.t(0)))
tw=p.t0+off*p.dt
tmp=smooth(nbi1.v,nsm)
en1=interpol(tmp,nbi1.t,tw)



;sh=7428&off=57&only2=-1
sh=7427&off=56&only2=-1
sh2=sh&ifr2=off

newdemodflc,sh, off,dopc=dopc2,angt=ang1,eps=eps1,only2=only2,cars=cars2,istata=istata2

shotc=sh
dbc='kstar'
nbi1=cgetdata('\NB11_VG1')      ;\NB11_I0')
;nbi2=cgetdata('\NB12_VG1')
nsm=round( p.dt / (nbi1.t(1)-nbi1.t(0)))
tw=p.t0+off*p.dt
tmp=smooth(nbi1.v,nsm)
en2=interpol(tmp,nbi1.t,tw)



af:
dd=dopc1-dopc2
dd=dd*!dtor
jumpimg,dd
dd=dd*!radeg


iy=100

;plot,dd(*,iy)
;mkfig,'~/rsphy/cmp5b.eps',xsize=15,ysize=10,font_size=10
;contourn2,dd,/cb,title='diff btw '+string(sh1,ifr1)+' and '+string(sh2,ifr2)
plot,dd(*,iy)
endfig,/gs,/jp
end
