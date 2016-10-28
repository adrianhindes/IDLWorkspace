

pro befit_ax,sh,tref,twant,norun=norun,inperr=inperr,dogas=dogas,dobeam2=dobeam2,kpp=kpp,kff=kff,runtwice=runtwice,drcm=drcm,invang=invang,rrng=rrng,gfile=gfile,mfile=mfile,lut=lut,field=field,wt=wt,dzcm=dzcm,nz=nz,distback=distback,noplot=noplot,shref=shref,mixfactor=mixfactor,outgname=outgname,calib=calib,dosym=dosym,readgg=readgg,restorecmp=restorecmp

default, lut, sh gt 8000
lut=0
tarr=tref
default,shref,sh
ifr=frameoftime(shref,tarr,db='k')&only2=1&demodtype=sh gt 8000 ? 'sm32013mse' : 'basicd'
newdemodflclt,shref, ifr,dopc=dopc1,angt=ang1,eps=eps1,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,cars=cars1,istata=istata1,demodtype=demodtype,/noid2,lut=lut;,/cacheread,/cachewrite
;ang1b=ang1



tarra=twant
na=n_elements(tarra)
;goto,ee
for i=0,na-1 do begin
   tarr=tarra(i)
;tarr=2.7
ifr=frameoftime(sh,tarr,db='k')&only1=1&only2=0
;
if tarr eq -1 then ang1b=ang1 else    newdemodflclt,sh, ifr,dopc=dopc1,angt=ang1b,eps=eps1b,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,only1=only1,cars=cars1b,istata=istata1b,demodtype=demodtype,/noid2,lut=lut;,/cacheread,/cachewrite
if tarr eq -1 then tarr=tref

if sh lt 8000 then ang1b-=16 else if not keyword_set(lut) then ang1b-=12.8 else ang1b-=1.5

default,field,2
ang1b-= 2 * (field - 3) ; for new cmapign ref is at 3T

if sh lt 8000 then ang1b*=-1



if keyword_set(invang) then ang1b*=-1
default,inperr,0

mgetptsnew,rarr=r,zarr=z,str=p,ix=ix2,iy=iy2,pts=pts,rxs=rxs,rys=rys,/calca,dobeam2=dobeam2,distback=distback,mixfactor=mixfactor; ,/plane
;    rxs(*,i)=rx ; [rad, tor, z]



newcmpmseefit,ix2=ix2,iy2=iy2,angexp=ang1b,str=p,tw=tarr,inperr=inperr,dogas=dogas,dobeam2=dobeam2,outinperr=dif2,drcm=drcm,invang=invang,rrng=rrng,pgfile=gfile2,mfile=mfile,dzcm=dzcm,nz=nz,distback=distback,mixfactor=mixfactor,readgg=readgg,/just,angsim=angsim,bz1=bz1,bt1=bt1

ang1b = angsim


;btcalc = r/180. * field

if keyword_set(restorecmp) then begin
restore,file='~/dn.sav',/verb
ang1b = dn
endif
btcalc = 180./r * field
tgam=tan(ang1b*!dtor)

bzed=bz1
;bzed =( tgam * rys(*,*,1) - rxs(*,*,1)) * btcalc / (rxs(*,*,2) - 1*rys(*,*,2)*tgam)


triangulate,r,z,tri
nr2=129
nz2=129
r2=linspace(min(r),max(r),nr2)
z2=linspace(-1,1,nz2)*max(abs(z))

bzed2=trigrid(r,z,bzed, tri, xout=r2,yout=z2,missing=!values.f_nan)
nysm=11*2+1
nxsm=11;5;11;5


if keyword_set(dosym) then begin
   bzed2b=bzed2
   ix=reverse(indgen(nz2))
   for i=0,nz2-1 do begin
      bzed2b(*,i) = 0.5 * (bzed2(*,i) + bzed2(*,ix(i)))
   endfor
   bzed2=bzed2b
endif


kern=fltarr(nxsm,nysm)+1./nysm/nxsm
bz2d2c=convol(bzed2,kern,/edge_wrap)
imgplot,bz2d2c,/cb

dbzdz=dee('y',bz2d2c)
wset2,0
imgplot,dbzdz,r2,z2,/cb,pal=-2
oplot,!x.crange,[0,0]
oplot,[1,1]*180,!y.crange


wset2,1
imgplot,-bzed2,r2,z2,/cb,xsty=1,ysty=1,pal=33,zr=[-.4,.4];pal=-2,
oplot,!x.crange,[0,0]

;oplot,[1,1]*180,!y.crange

;stop

wset2,3
imgplot,-bzed,/cb,xsty=1,ysty=1,pal=33,zr=[-.4,.4];pal=-2,,pal=-2
stop

wset2,2
iz0=nz2/2
plot,r2,bzed2(*,iz0)


dum=min(abs(bzed2(*,iz0)),imin,/nan)
oplot,r2(imin)*[1,1],!y.crange
oplot,!x.crange,[0,0]

stop
plot,r2,dbzdz(*,iz0),col=2,/noer
dum=min(abs(dbzdz(*,iz0)),imin,/nan)
oplot,r2(imin)*[1,1],!y.crange,col=2

oplot,!x.crange,[0,0],col=2
if keyword_set(calib) then begin
imgplot,ang1b,/cb,pal=-2
wset2,0
imgplot,rxs(*,*,1)/rys(*,*,1)*!radeg,/cb,pal=-2
wset2,1
imgplot,rxs(*,*,1)/rys(*,*,1)*!radeg - ang1b,/cb,pal=-2
endif
;dxz=dee('x',z)
;dyz=dee('y',z)
;dxp=dee('x',bzed)
;dyp=dee('y',bzed)

;dzx=1/dxz
;dzy=1/dyz
;dpdz = dzx * dxp + dzy * dyp


stop
endfor




end




;; ee:
;; qarr=fltarr(na,65)
;; for i=0,na-1 do begin
;;    tarr=tarra(i)
;;    fspec=string(sh,tarr*1000,format='(I6.6,".",I6.6)')
;;    dir='/home/cam112/ikstar/my2/EXP00'+string(sh,format='(I0)')+'_k'+''
;;    gfile=dir+'/g'+fspec
;;    g=readg(gfile)
;;    qarr(i,*)=g.qpsi
;;    print,gfile
;; endfor


;; end
;befitax,9163,0.92,-1,field=3.0;2.5;1.5;.;2.  ;
;end
