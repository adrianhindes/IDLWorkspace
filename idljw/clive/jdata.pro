
pro cdata,sh,tref,twant,norun=norun,inperr=inperr,dogas=dogas,dobeam2=dobeam2,kpp=kpp,kff=kff,runtwice=runtwice,drcm=drcm,invang=invang,rrng=rrng,gfile=gfile,mfile=mfile,lut=lut,field=field,wt=wt,dzcm=dzcm,nz=nz,distback=distback,noplot=noplot,shref=shref,mixfactor=mixfactor,outgname=outgname,calib=calib,dosym=dosym,readgg=readgg,angout=ang1b,inten=inten

default, lut, sh gt 8000
lut=0
tarr=tref
default,shref,sh
ifr=frameoftime(shref,tarr,db='k')&only2=1&demodtype=sh gt 8000 ? 'smjtest2013mse' : 'basicd'
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
if tarr eq -1 then ang1b=ang1 else    newdemodflclt,sh, ifr,dopc=dopc1,angt=ang1b,eps=eps1b,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,only1=only1,cars=cars1b,istata=istata1b,demodtype=demodtype,/noid2,lut=lut,inten=inten;,/cacheread,/cachewrite
if tarr eq -1 then tarr=tref

if sh lt 8000 then ang1b-=16 else if not keyword_set(lut) then ang1b-=12.8 else ang1b-=1.5

default,field,2
ang1b-= 2 * (field - 3) ; for new cmapign ref is at 3T

if sh lt 8000 then ang1b*=-1



if keyword_set(invang) then ang1b*=-1
default,inperr,0
endfor

mgetptsnew,rarr=r,zarr=z,str=p,ix=ix2,iy=iy2,pts=pts,rxs=rxs,rys=rys,/calca,dobeam2=dobeam2,distback=distback,mixfactor=mixfactor; ,/plane
;    rxs(*,i)=rx ; [rad, tor, z]

end





;t=mdsvalue('DIM_OF(.DEMOD:THETA0,0)')
t=read_segmented_images_timebase('mse_2013',9323,'.DEMOD:THETA0')

;t=read_segmented_images_timebase('mse_2013',9323,'.DEMOD1:THETA0')
;stop

;t=t*1. / 1e6
i=value_locate3(t,2.15)
;i=3; ?guess
mdsopen,'mse_2013',9323
d= ( get_image_seg('.DEMOD:THETA0',i)).images
;d=( -( get_image_seg('.DEMOD:THETA',i)).images- 43.*!dtor)/4.
;d= ( get_image_seg('.DEMOD1:THETA0',i)).images
di= ( get_image_seg('.DEMOD:I0',i)).images 
idx=where(di lt max(di)*0.2)
;
mdsclose

cdata,9323,1.925,2.1,angout=ang,inten=inten

sz1=size(d,/dim)*1.
sz2=size(ang,/dim)*1.
rat=sz1/sz2
rat=round(rat)
kern=fltarr(rat(0),rat(1))+1./(rat(0)*rat(1))
dc=convol(d,kern)
dc(idx)=!values.f_nan
dn=congrid(dc,sz2(0),sz2(1))*!radeg

iy=sz2(1)/2
plot,ang(*,iy),yr=minmax2([ang(*,iy),dn(*,iy)])
oplot,dn(*,iy),col=2

stop

save,dn,file='~/dn.sav',/verb
stop
befit_ax,9323,1.925,2.1,/restorecmp,field=3.,/readgg
end



