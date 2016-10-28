function getc,sh1
sh=[77,78,intspace(89,96)]
ang=[0,0,-10,-10,-20,-20,10,10,20,20]
iw=value_locate(sh,sh1)
return,ang(iw)
end
;goto,ee2

sh=[77,78,intspace(89,96)]
shref=95 & ifrref=0

nsh=n_elements(sh)

nang=9

np=nsh*nang
sh2=reform( replicate(1,nang) # sh,np)
iarr2=reform(findgen(nang) # replicate(1,nsh)  ,np)
ash=fltarr(np)
theta0=fltarr(np)
dtheta=fltarr(np)
theta=fltarr(np)
qwpang=fltarr(np) & for i=0,np-1 do qwpang(i)=getc(sh2(i))


demodtype='basic3'

cachewrite=1
cacheread=0
doplot=0
db='t5a'




   newdemod,imgref,carsr,sh=shref,ifr=ifrref,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/doload,cachewrite=cachewrite,cacheread=cacheread

   ia=2
   ib=3
   ic=1                         ;circ

carsr=carsr/abs(carsr)
sz=size(carsr,/dim)
cstore=fltarr(np,sz(0),sz(1))
for i=0,nsh-1 do begin
   img=getimgnew(sh(i),db=db,0,info=info,/getinfo,/nostop,/nosubindex,str=str)*1.0
   for j=0,nang-1 do begin
      k=i*nang + j
      theta0(k)=info.theta0
      ash(k)=info.flipper
      dtheta(k)=info.angstep
      theta(k)=theta0(k) + iarr2(k) * dtheta(k)
;img=getimgnew(sh,db=db,ifr,info=info,/getinfo,/nostop,/nosubindex,str=str)*1.0
      newdemod,img,cars,sh=sh2(k),ifr=iarr2(k),db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ixi,iy=iyi,p=strr,kx=kx,ky=ky,kz=kz,/doload,cachewrite=cachewrite,cacheread=cacheread
      if k eq 0 then begin
         szc=size(cars,/dim)
         cars_s=complexarr(szc(0),szc(1),szc(2),np)
      endif
      cars_s(*,*,*,k)=cars

      
      denom= (abs(cars(*,*,ia))+abs(cars(*,*,ib)))
      numer=        abs2(cars(*,*,ic)/carsr(*,*,ic))
      
      circ=0.5*!radeg*atan($
           numer,denom) 
      cstore(k,*,*)=circ
   endfor
endfor



ee:

;cstore=atan(cstore)*!radeg
pos=posarr(2,1,0) & erase
for ashsel=0,1 do begin
ix=sz(0)/2;9
iy=sz(1)/2;23
;ashsel=0 ; 0 is angle
idx=where(ash eq ashsel)
c=cstore(idx,ix,iy)
if ashsel eq 0 then c=(90+2*c)/2 ; to correct for inverse
if ashsel eq 1 then c=c*2
thetap=theta+qwpang+45
epsilon=qwpang*2

cv2non, 2*thetap*!dtor,epsilon*!dtor, chi, delta & chi*=!radeg/2 & delta*=!radeg
plot,c,pos=pos,/noer
;if ashsel eq 0 then oplot,thetap(idx),col=2
if ashsel eq 0 then oplot,chi(idx),col=3
if ashsel eq 1  then oplot,epsilon(idx),col=2
pos=posarr(/next)
endfor
regarr=fltarr(sz(0),sz(1),5)
csarr=fltarr(sz(0),sz(1))
devarr=csarr
dev0arr=devarr

regarr_c=fltarr(sz(0),sz(1),5)
csarr_c=fltarr(sz(0),sz(1))
devarr_c=csarr
dev0arr_c=devarr
for ix=0,sz(0)-1 do for iy=0,sz(1)-1 do begin

idx=where(ash eq 0) ; 0 is ash
c=cstore(idx,ix,iy)
c=(90+2*c)/2 ; to correct for inverse
chi1=chi(idx)
delta1=delta(idx)


idxb=where(ash eq 1)
e=2*cstore(idxb,ix,iy)
eps1=epsilon(idxb)
theta1=thetap(idxb)

de = e-eps1 ; measured - real

dc = c-chi1

c45=c-45

;measure_errors=(abs(c45) le 20)*(-999) + 1000
cde=regress(transpose([[e],[e^2],[c45],[c45^2]]),de,chisq=chisq_de,yfit=fit_de,const=cde_0  ) & print,chisq_de
regarr(ix,iy,0)=cde_0
regarr(ix,iy,1:4)=cde
csarr(ix,iy)=chisq_de
devarr(ix,iy)=max(abs(de-fit_de))
dev0arr(ix,iy)=max(abs(de))


cdc=regress(transpose([[e],[c45],[c45^2],[c45^3]]),dc,chisq=chisq_dc,yfit=fit_dc,const=cdc_0  ) & print,chisq_dc
regarr_c(ix,iy,0)=cdc_0
regarr_c(ix,iy,1:4)=cdc
csarr_c(ix,iy)=chisq_dc
devarr_c(ix,iy)=sqrt(mean((dc-fit_dc)^2 ) )
dev0arr_c(ix,iy)=sqrt(mean(dc^2))

if total(finite(de)) eq 0 then continue
print,ix,iy

;if ix eq sz(0)/2 and iy eq sz(1)/2 then mkfig,'~/reg_fit1.eps',xsize=25,ysize=18,font_size=11
plot,fit_de,de,psym=4,pos=posarr(3,2,0),xtitle='fit_deltaepsilon',ytitle='deltaepsilon'
oplot,fit_de,de-fit_de,psym=4,col=2
plot,c,de,pos=posarr(/next),/noer,psym=4,xtitle='chi',ytitle='deltaepsilon'
plot,e,de,pos=posarr(/next),/noer,psym=4,xtitle='epsilon',ytitle='deltaepsilon'



if total(finite(dc)) eq 0 then continue

plot,fit_dc,dc,psym=4,pos=posarr(/next),/noer,xtitle='fit_deltachi',ytitle='delta chi'
oplot,fit_dc,dc-fit_dc,psym=4,col=2
plot,c,dc,pos=posarr(/next),/noer,psym=4,xtitle='chi',ytitle='delta chi'
plot,e,dc,pos=posarr(/next),/noer,psym=4,xtitle='epsilon',ytitle='delta chi'

;endfig,/gs,/jp




;if ix eq sz(0)/2 and iy eq sz(1)/2 then stop
endfor

save, regarr_c, regarr, ixi,iyi,file='~/idl/lt1.sav',/verb


ee2:


;mkfig,'~/fig_improvement.eps',xsize=17,ysize=17,font_size=10
imgplot,dev0arr_c,/cb,pos=posarr(2,2,0),zr=[0,6],offx=1.,title='original  error in chi (over all epsilon,chi)'
imgplot,devarr_c,/cb,pos=posarr(/next),/noer,zr=[0,6],offx=1.,title='maerror in chi after regression'
imgplot,dev0arr,/cb,pos=posarr(/next),/noer,zr=[0,20],offx=1.,title='original error in epsilon'
imgplot,devarr,/cb,pos=posarr(/next),/noer,zr=[0,20],offx=1.,title='error in epsilon after regression'
endfig,/gs,/jp



thetapa=thetap-45

iw=where(thetapa eq 0 and qwpang eq 00 and ash eq 1) ; 1 is ph
ir=where(thetapa eq 0 and qwpang eq 00 and ash eq 0) ; 0 is a

      newdemod,img,carsrr,sh=sh2(ir),ifr=iarr2(ir),db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ixi,iy=iyi,p=strr,kx=kx,ky=ky,kz=kz,/doload,cachewrite=cachewrite,cacheread=cacheread


      newdemod,img,cars,sh=sh2(iw),ifr=iarr2(iw),db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ixi,iy=iyi,p=strr,kx=kx,ky=ky,kz=kz,/doload,cachewrite=cachewrite,cacheread=cacheread


p=atan2(cars/carsrr)
pa=p(*,*,ia)
pb=p(*,*,ib)

paj=pa
pbj=pb
;jumpimgh,paj
;jumpimgh,pbj

psum=(paj-pbj)/2*!radeg
pdif=(paj+pbj)/4*!radeg

denom= (abs(cars(*,*,ia))+abs(cars(*,*,ib)))
numer=        abs2(cars(*,*,ic)/carsr(*,*,ic))
epsx=2*0.5*!radeg*atan($
     numer,denom) 


denom= (abs(carsrr(*,*,ia))+abs(carsrr(*,*,ib)))
numer=        abs2(carsrr(*,*,ic)/carsr(*,*,ic))
chix=(90 + 2 * 0.5*!radeg*atan($
     numer,denom) )/2
chix45=chix-45

deps = regarr(*,*,0) + $
      regarr(*,*,1) * epsx + $
      regarr(*,*,2) * epsx^2 + $
      regarr(*,*,3) * chix45 + $
      regarr(*,*,4) * chix45^2 ; meas-real
                  
eps = epsx - deps
;imgplot,pdif,/cb


end





