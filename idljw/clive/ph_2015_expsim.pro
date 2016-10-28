pro getrampsim, wl=wl, psum,pdif
sh=8053;46
ifr=100

doplot=0

lam=659.89e-9


   
simimgnew,imgr,sh=sh,lam=lam,svec=[2,1,1,0]

newdemod,imgr,carsr,sh=sh,lam=lam,doplot=doplot,demodtype='basicfull',ix=ix,iy=iy,p=str,kx=kx,ky=ky,kz=kz
pr=atan2(carsr)

;stop
;imgplot,img
;stop

shr=1615

;img=getimgnew(shr,0,/nosubindex)*1.0
default,wl,661.5
lam2=wl*1e-9




if wl eq 662 then begin
;   lamv=lam*(fltarr(1600,1644)+1) ;529e-9
   lamh=linspace(660,662,1600)*1e-9
   lamv=lamh # replicate(1,1644)
endif else begin
   lamv=lam2
endelse


simimgnew,img,sh=sh,lam=lamv,svec=[2,1,1,0]

;img=getimgnew(sh,ifr,info=info,/getinfo,/nostop,/nosubindex)*1.0

newdemod,img,cars,sh=sh,lam=lam,doplot=doplot,demodtype='basicfull',ix=ix,iy=iy,p=str,kx=kx,ky=ky,kz=kz


ia=1
ib=3
p=atan2(cars/carsr)
pa=p(*,*,ia)
pb=p(*,*,ib)

paj=pa
pbj=pb
jumpimg,paj
jumpimg,pbj


psum=paj+pbj
pdif=paj-pbj


end



pro getrampexp,psum,pdif

sh=8052;3;46
ifr=155
;sh=8053
;ifr=100
doplot=0
shr=1605
ifrr=18
img=getimgnew(sh,ifr,info=info,/getinfo,/nostop,/nosubindex,str=str,/getflc)*1.0
idx=where(long(img) eq 65535L) 
if idx(0) ne -1 then img(idx)=0.
roi2=[str.roil,    str.roir,    str.roib,    str.roit]



imgr=getimgnew(shr,ifrr,/nosubindex,roi=roi2,str=strr,/getflc)*1.0


newdemod,imgr,carsr,sh=shr,lam=lam,doplot=doplot,demodtype='basicfull2w',ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/no2load
pr=atan2(carsr)

;stop
;imgplot,img
;stop



newdemod,img,cars,sh=sh,lam=lam,doplot=doplot,demodtype='basicfull2',ix=ix,iy=iy,p=str,kx=kx,ky=ky,kz=kz,/no2load


ia=1
ib=3
p=atan2(cars/carsr)
pa=p(*,*,ia)
pb=p(*,*,ib)

paj=pa
pbj=pb
jumpimgh,paj
jumpimgh,pbj

psum=paj+pbj
pdif=paj-pbj

imgplot,pdif

pdif = pdif+!pi/2 
ny=n_elements(pdif(0,*))
plot,pdif(*,ny/2)*!radeg

end

goto,ee

getrampexp,psum,pdif
ny=n_elements(pdif(0,*))
nx=n_elements(pdif(*,0))

wlarr=[662,660,661,662,663,664] & nw=n_elements(wlarr)
plot,psum(*,ny/2)
parr=fltarr(nx,nw)

for i=0,0 do begin
   wl=wlarr(i)
   getrampsim, wl=wl, psum2,pdif2
   parr(*,i)=psum2(*,ny/2)
   oplot,psum2(*,ny/2),col=i+1
endfor
ee:
mkfig,'correction_doppler.eps',xsize=28,ysize=21,font_size=11
plot,psum(*,ny/2)/2*!radeg,title='Doppler phase, horizontal variation in midplane',pos=posarr(2,2,0),ytitle='deg'
oplot,psum2(*,ny/2)/2*!radeg,col=2
legend,['measurement','model, assuming going from 660-662nm'],col=[1,2],textcol=[1,2],/right

imgplot,pdif/4*!radeg,pal=-2,title='Mearsured polarization angle without correction (deg)',pos=posarr(/next),/noer

imgplot,pdif2/4*!radeg,pal=-2,title='Calculated polarization angle correction (deg)',pos=posarr(/next),/noer

imgplot,(pdif-pdif2)/4.*!radeg,/cb,pal=-2,title='Corrected polarization angle (deg)',pos=posarr(/next),/noer

endfig,/gs,/jp
end
