@mygaussbgfit
@mygaussfit
@fittoit
pro procxrdat2, sh=sh,ton=ton,toff=toff,t2off=t2off,type=type,subtype=subtype,timeoff=timeoff,timeper=timeper,force=force,apar0=apar0

default,demodtype,'basicd46b'

 lam=529.1e-9


loadcxrdat,sh=sh,ton=ton,toff=toff,t2off=t2off,type='data',img=img,subtype=subtype,timeoff=timeoff,timeper=timeper

common cbb,carscal5,carswhite,sh2
doit=1
if n_elements(sh2) ne 0 then if sh2 eq sh then doit=0
if not keyword_set(force) then doit=1
if doit eq 1 then begin
   initcxrfit, sh=sh,carscal=carscal5,carshite=carswhite,pc=pc,demodtype=demodtype,kzv=kzv
   sh2=sh
endif


demodcxrssub, img, cars,carscal5,sh=sh,db='c',demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy,ns=ns

phase = atan2(cars)
contrast=abs(cars)

velest = phase/atan2(pc)* 0.1 / 529. * 3e8 / 100000.

sz=size(cars,/dim)


if fittype eq 'mygaussfit' then npar=4
if fittype eq 'mygaussbgfit' then npar=4
if fittype eq 'mymgaussfit' then npar=6

apar=fltarr(sz(0),sz(1),npar)

carsfit=cars*0
carsfit0=cars*0


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


end
