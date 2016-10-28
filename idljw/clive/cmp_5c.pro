@getptsnew
goto,af

sh=7450&off=30&only2=1&demodtype='basicd'
sh1=sh&ifr1=off
newdemodflc,sh, off,dopc=dopc1,angt=ang1,eps=eps1,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,cars=cars1,istata=istata1,demodtype=demodtype,/noid2


;stop
common cbshot, shotc,dbc,isconnected
shotc=sh
dbc='kstar'

;nbi1=cgetdata('\NB11_VG1')      ;\NB11_I0')
nbi1=cgetdata('\NB12_VG1')
nsm=round( p.dt / (nbi1.t(1)-nbi1.t(0)))
tw=p.t0+off*p.dt
tmp=smooth(nbi1.v,nsm)
en1=interpol(tmp,nbi1.t,tw)



sh=7451&off=30&only2=1&demodtype='basicd'
sh2=sh&ifr2=off

newdemodflc,sh, off,dopc=dopc2,angt=ang2,eps=eps2,only2=only2,cars=cars2,istata=istata2,demodtype=demodtype,/noid2

;stop
shotc=sh
dbc='kstar'
;nbi1=cgetdata('\NB11_VG1')      ;\NB11_I0')
nbi1=cgetdata('\NB12_VG1')
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
mkfig,'~/rsphy/cmp5b.eps',xsize=15,ysize=10,font_size=10
contourn2,dd,/cb,title='diff btw '+string(sh1,ifr1)+' and '+string(sh2,ifr2)+' has energies '+string(en1,en2)


endfig,/gs,/jp
end
