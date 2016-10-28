@mygaussbgfit
@mygaussfit
@fittoit
pro procxrdat, sh=sh,ton=ton,t2on=t2on,toff=toff,t2off=toff2,lookdiff=lookdiff,lookdemod=lookdemod,s1hload=shload,skip=skip,lx=lx,ly=ly,lookres=lookres,s2kip=s2kip,l1ookres=l1ookres,fdoplot=fdoplot,timeoff=timeoff,timeper=timeper
default,timeoff,10e-3


;readpatch,sh,str
default,timeoff, 10e-3
;default,timeper,str.dt
if sh eq 9229 then default, timeper, 8e-3
if sh eq 9240 then default, timeper, 29e-3

toff_frac=(timeoff/timeper)<1



default,toff2,-0.5
default,ns,4

common cbb, imglight,imgdark,img,white,whitelasertr,imglight2,$
   carscal,carscal5,pc,kz,kzv,$
   dl,dldark,dllight,$
   carswhitelasertr,carswhitelasertr5,carswhite,ix,iy,thx,thy,$
   str,$
   cars,carslight,carsdark,carslight2
common cbb2, aparlight,apardark,apar,carsfit,carslightfit,carsdarkfit,carsfit0,carslightfit0,carsdarkfit0,$
   carslight2fit,carslight2fit0,aparlight2

   


db='c' & lam=529.1e-9

if keyword_set(skip) and n_elements(imglight) ne 0 then goto,ee
if keyword_set(s2kip) and n_elements(imglight) ne 0 then goto,ff
loadcxrdat,sh=sh,ton=ton,toff=toff2,img=imglight,type='data'
loadcxrdat,sh=sh,ton=toff,toff=toff2,img=imgdarktmp,type='data'
imgdark = (imglight * (1-toff_frac) - imgdarktmp * 1) / toff_frac * (-1) ; sign error
;loadcxrdat,sh=sh,ton=ton,toff=toff,img=img,type='data'
img=(imglight-imgdarktmp)/toff_frac


if keyword_set(t2on) then loadcxrdat,sh=sh,ton=t2on,toff=toff2,img=imglight2,type='data'

;sh='cxrstest4_tuni_white_cxrsfilter'


if keyword_set(lookdiff) then begin
   window,4,title='diff'
   imgplot,imglight,pos=posarr(2,2,0),zr=[0,500],title=string(sh,ton,format='("#",I0,"@t=",G0,"s")'),/cb
   imgplot,imgdark,pos=posarr(/next),zr=[0,500],/noer,title=string(sh,toff,format='("#",I0,"@t=",G0,"s")'),/cb
   imgplot,img,pos=posarr(/next),/noer,zr=[0,500],title='difference',/cb
;   stop
endif


loadcxrdat,sh=sh,img=cal,type='cal',cars=carscal
default,demodtype,'basicd46b'
;newdemod, cal,carscal,sh=sh,db=db,lam=lam,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy,kz=kz;,/doplot
;for i=0,4 do if i ne 1 then carscal(*,*,i)=carscal(*,*,i)/carscal(*,*,1)
demodcxrssub, cal, carscal,sh=sh,db=db,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy,/just,kz=kz
correctphase, sh,carscal, carscal5, db=db,shload=shload,thx=thx,thy=thy,pc=pc,kzv=kzv

;white light
loadcxrdat,sh='cxrstest4_tuni_white_cxrsfilter',img=white,type='whiteandcal'
loadcxrdat,sh='cxrstest4_tuni_lasertr',img=whitelasertr,type='whiteandcal'
demodcxrssub, whitelasertr, carswhitelasertr,sh='cxrstest4_tuni_lasertr',db='k2',demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy,/just
correctphase, 'cxrstest4_tuni_lasertr',carswhitelasertr, carswhitelasertr5, db='k2',shload=88888,thx=thx,thy=thy
demodcxrssub, white, carswhite,carswhitelasertr5,sh='cxrstest4_tuni_white_cxrsfilter',db='k2',demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy,ns=1
;;;

;stop


demodcxrssub, img, cars,carscal5,sh=sh,db=db,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy,ns=ns
demodcxrssub, imglight, carslight,carscal5,sh=sh,db=db,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy,ns=ns
demodcxrssub, imgdark, carsdark,carscal5,sh=sh,db=db,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy,ns=ns
if keyword_set(t2on) then demodcxrssub, imglight2, carslight2,carscal5,sh=sh,db=db,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy,ns=ns


ee:

for a=0,2 do begin
   if a eq 0 then ctmp=cars
   if a eq 1 then ctmp=carsdark
   if a eq 2 then ctmp=carslight
   phase = atan2(ctmp)
   dltmp = phase/atan2(pc)* 0.1 / 529. * 3e8 / 100000. ;(imaginary(cars),real_part(cars))
   if a eq 0 then dl=dltmp
   if a eq 1 then dldark=dltmp
   if a eq 2 then dllight=dltmp
endfor

jj=[0,2,4]
if keyword_set(lookdemod) then begin

   lab=['cars','carsdark','carslight']
   for a=0,2 do begin
      if a eq 0 then ctmp=cars
      if a eq 1 then ctmp=carsdark
      if a eq 2 then ctmp=carslight
      contrast = abs(ctmp)
      phase = atan2(ctmp)
;      if a eq 0 then
      dl = phase/atan2(pc)* 0.1 / 529. * 3e8 / 100000. ;(imaginary(cars),real_part(cars))
;      if a eq 0 then
      do3=1 ;else do3=0
      
      window,a,title=lab(a)
      for k=0,2 do begin
         if do3 eq 1 then pos1=posarr(3,3,3*k) else pos1=posarr(2,3,2*k)
         imgplot,contrast(*,*,jj(k)),xsty=1,ysty=1,/cb,title=kz(jj(k)),zr=[0.,1.2],pos=pos1,/noer,offx=1.
         
         if do3 eq 1 then pos1=posarr(3,3,3*k+1) else pos1=posarr(2,3,2*k+1)
         imgplot,phase(*,*,jj(k)),xsty=1,ysty=1,/cb,title=kz(jj(k)),pal=-2,pos=pos1,/noer,offx=1
         if do3 eq 1 then $
            imgplot,dl(*,*,jj(k)),xsty=1,ysty=1,/cb,title=kz(jj(k)),pal=-2,pos=posarr(3,3,3*k+2),/noer,offx=1,zr=[-1,1]
         
      endfor
   endfor
endif


;stop

common cbkappa, kappa
ccrystal, {crystal:'bbo',lambda:529.1e-9,facetilt:0,thickness:1e-3},kappa=kappa

;restore,file='~/idl/clive/settings/aparact1.sav',/verb
;restore,file='~/idl/clive/settings/aparbg1.sav',/verb
;restore,file='~/idl/clive/settings/carswhite.sav',/verb
dum=carswhite
carswhite1=dum

common cbmgf2, xtrue2,cohwhite
sz=size(cars,/dim)

aparlight=fltarr(sz(0),sz(1),6)
aparlight2=fltarr(sz(0),sz(1),6)
apardark=fltarr(sz(0),sz(1),4)
apar=fltarr(sz(0),sz(1),4)

carsfit=cars*0
carslightfit=carslight*0
carsdarkfit=carsdark*0
if keyword_set(t2on) then begin
   carslight2fit=carslight2*0
   carslight2fit0=carslight2*0
endif

carsfit0=cars*0
carslightfit0=carslight*0
carsdarkfit0=carsdark*0

default, lx,[0,sz(0)-1,1]
default, ly,[0,sz(1)-1,1]

;for iplot=0,np-1 do begin
for dx=lx(0),lx(1),lx(2) do begin
for dy=ly(0),ly(1),ly(2) do begin


   fittoit, kzv,dx,dy,jj,6,[1.,dl(dx,dy,jj(1)),1.,0.],cars,'mygaussfit',apar,carsfit,carsfit0,carswhite1,[0,1,1,0],doplot=fdoplot

   correction=carsfit/cars
  correction=1
   carsdark1=carsdark*correction
   carslight1=carslight*correction

;   stop
   fittoit, kzv,dx,dy,jj,6,[1.,dldark(dx,dy,jj(1)),1.,0.],carsdark1,'mygaussbgfit',apardark,carsdarkfit,carsdarkfit0,carswhite1,[1,1,1,0],doplot=fdoplot
;   stop

 
   a1=reform(apardark(dx,dy,0:2))
   i1=abs(carsdark(dx,dy,1))
   a2=reform(apar(dx,dy,0:2))
   i2=abs(cars(dx,dy,1))
   a=[a1,a2]
   is=i1+i2
   a(0)=a1(0) * i1/is
   a(3)=i2/is
;  a(1)=0.
   fittoit, kzv,dx,dy,jj,8,a,carslight1,'mymgaussfit',aparlight,carslightfit,carslightfit0,carswhite1,[0,0,0,0,0,1],doplot=fdoplot

   if keyword_set(t2on) then begin
      carslight21=carslight2*correction
      a1=reform(apardark(dx,dy,0:2))
      i1=abs(carsdark(dx,dy,1))
      a2=reform(apar(dx,dy,0:2))
      i2=abs(cars(dx,dy,1))
      a=[a1,a2]
      is=i1+i2
      a(0)=a1(0) * i1/is
      a(3)=i2/is
;  a(1)=0.
      fittoit, kzv,dx,dy,jj,8,a,carslight21,'mymgaussfit',aparlight2,carslight2fit,carslight2fit0,carswhite1,[0,0,0,1,1,1],doplot=fdoplot

   endif

endfor
print,dx,lx
endfor
ff:

if keyword_set(lookres) then begin
mkfig,'~/fign.eps',xsize=24,ysize=19,font_size=10
   imgplot,apar(*,*,2),zr=[0,6],pos=posarr(3,3,0),title='active temp(keV)',xsty=5,ysty=5,/cb,offx=1
   imgplot,apardark(*,*,2),zr=[0,6],pos=posarr(/next),title='bg temp (keV)',/noer,xsty=5,ysty=5,/cb,offx=1
   imgplot,aparlight(*,*,5),zr=[0,6],pos=posarr(/next),title='active temp FIT2 (keV)',/noer,xsty=5,ysty=5,/cb,offx=1
   imgplot,apar(*,*,1),zr=[-2,2],pos=posarr(/next),title='active v (100km/s)',/noer,pal=-2,xsty=5,ysty=5,/cb,offx=1
   imgplot,apardark(*,*,1),zr=[-2,2],pos=posarr(/next),title='bg v (100km/s)',/noer,pal=-2,xsty=5,ysty=5,/cb,offx=1
   imgplot,aparlight(*,*,4),zr=[-2,2],pos=posarr(/next),title='active v (FIT2) (100km/s)',/noer,pal=-2,xsty=5,ysty=5,/cb,offx=1
;   imgplot,apar(*,*,0)*abs(cars(*,*,1)),pos=posarr(/next),title='active amp',/noer,xsty=5,ysty=5,/cb,offx=1
   pos=posarr(/next)
   imgplot,apardark(*,*,0),pos=posarr(/next),title='gaussian frac. in bg (rel to bremss)',/noer,xsty=5,ysty=5,/cb,offx=1,zr=[0,1]
   imgplot,aparlight(*,*,3),pos=posarr(/next),title='active fraction (FIT2) (frozen)',/noer,zr=[0,1],xsty=5,ysty=5,/cb,offx=1
endfig,/gs,/jp
endif


if keyword_set(l1ookres) then begin
   row=fix((ly(0)+ly(1))/2)

mkfig,'~/fign.eps',xsize=24,ysize=19,font_size=10
;   window,4,xsize=1000
   plot,apar(*,row,2),yr=[0,7],pos=posarr(3,2,0),title='temp(keV)'
   oplot,apardark(*,row,2),col=2
   oplot,aparlight(*,row,5),col=3,psym=4
   oplot,aparlight(*,row,2),col=2,psym=4
;  stop
   oplot,aparlight2(*,row,5),col=3,psym=6
;  stop
   oplot,aparlight2(*,row,2),col=2,psym=6
   plot,apar(*,row,1),yr=[-2,2],pos=posarr(/next),title=' v (100km/s)',/noer
   oplot,apardark(*,row,1),col=2
   oplot,aparlight(*,row,1),col=2,psym=4
   oplot,aparlight(*,row,4),col=3,psym=4
   oplot,aparlight2(*,row,1),col=2,psym=6
   oplot,aparlight2(*,row,4),col=3,psym=6
   plot,carslight(*,row,1),col=3,pos=posarr(/next),/noer
   oplot,carsdark(*,row,1),col=2
   oplot,cars(*,row,1),col=1
;   plot,apar(*,*,0)*abs(cars(*,*,1)),pos=posarr(/next),title='active amp',/noer,xsty=5,ysty=5,/cb,offx=1
;   pos=posarr(/next)
   plot,aparlight(*,row,3),pos=posarr(/next),title='frac',/noer,yr=[0,1]
   oplot,aparlight(*,row,0),col=2
   oplot,1-aparlight(*,row,0)-aparlight(*,row,3),col=3
   plot,apardark(*,row,0),col=2,linesty=3,pos=posarr(/next),/noer,title='frac of bg (r:gauss,g:bs)',yr=[0,1]
   oplot,1-apardark(*,row,0),col=3,linesty=3
endfig,/gs,/jp
endif

stop
end





fdoplot=1
procxrdat, sh=9229,ton=1.541,toff=1.501,s1hload=9229,/skip,lx=[73*(fdoplot eq 1 ? 0.5 : 0), 73,1],ly=[65/2,65/2,1],/l1ookres,fdoplot=fdoplot;,t2on=3.1;,/lookdemod
;procxrdat, sh=9240,ton=3.16,toff=3.12,s1hload=9229,/skip,lx=[73*(fdoplot eq 1 ? 0.5 : 0), 73,1],ly=[65/2,65/2,1],fdoplot=fdoplot,/l1ookres

;,t2on=1.5;,/lookdemod


;,lx=[37,37,1],ly=[33,33,1]
;sh=9240&ton=3.16&toff=3.12
;sh=9229&ton=1.541&toff=1.501
;sh=9211&ton=3.54&toff=3.50
;sh=9211&ton=2.54&toff=2.50
;shload=9229

end
