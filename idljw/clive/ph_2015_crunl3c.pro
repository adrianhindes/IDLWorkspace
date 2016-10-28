@phs_jump
function getc,sh1
sh=[90024,90025,90028]
ang=[0,10,-10]
iw=value_locate(sh,sh1)
return,ang(iw)
end


;goto,ee2

sh=[90024,90024,90025,90025,90028,90028]
aoff=[0,1,0,1,0,1]
shref=90024 & ifrref=4*2+8*2 ; +0 makes it ash, i.e. 3rd carrier is chi
;shref=79 & ifrref=4*2+1

nsh=n_elements(sh)

nang=17

np=nsh*nang
sh2=reform( replicate(1,nang) # sh,np)
iarr2=2*reform(findgen(nang) # replicate(1,nsh)  ,np)
ash=fltarr(np)
theta0=fltarr(np)
dtheta=fltarr(np)
theta=fltarr(np)
qwpang=fltarr(np) & for i=0,np-1 do qwpang(i)=getc(sh2(i))



demodtype='basicnofull2'
cachewrite=1
cacheread=1
doplot=0
db='kcal2015'




   newdemod,imgref,carsr,sh=shref,ifr=ifrref,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/doload,cachewrite=cachewrite,cacheread=cacheread

   ia=1
   ib=3
   ic=2                         ;circ
carsr0=carsr

;stop
carsr=carsr/abs(carsr)
sz=size(carsr,/dim)
cstore=fltarr(np,sz(0),sz(1))
for i=0,nsh-1 do begin
   img=getimgnew(sh(i),db=db,0,info=info,/getinfo,/nostop,/nosubindex,str=str)*1.0
   for j=0,nang-1 do begin
      k=i*nang + j
      theta0(k)=-40.
      ash(k)=aoff(i) eq 1  ;j mod 2 ; zero is ash
      dtheta(k)=5.
      theta(k)=theta0(k) + iarr2(k)/2 * dtheta(k)
;img=getimgnew(sh,db=db,ifr,info=info,/getinfo,/nostop,/nosubindex,str=str)*1.0

      newdemod,img,cars,sh=sh2(k),ifr=iarr2(k)+aoff(i),db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ixi,iy=iyi,p=strr,kx=kx,ky=ky,kz=kz,/doload,cachewrite=cachewrite,cacheread=cacheread
      
      denom= (abs(cars(*,*,ia))+abs(cars(*,*,ib))) ;* abs2(cars(*,*,ia)/carsr(*,*,ia)) / abs(cars(*,*,ia))
      denom= (abs(cars(*,*,ia)))*2;+abs(cars(*,*,ib))) ;* abs2(cars(*,*,ia)/carsr(*,

      if ash(k) eq 1 then denom=abs(denom)
      denom=abs(denom)
      numer= abs2(cars(*,*,ic)/carsr(*,*,ic))
      
      dum=atan($
           numer,denom) 
      dum2=amod(dum)
      
      circ=0.5*!radeg*dum2;amod(atan($
;           numer,denom) )
;      print,circ(58,45),dum2(58,45),dum(58,45)
      cstore(k,*,*)=circ
;      if k eq 5 or k eq 6 then stop
   endfor
endfor


;stop
ee:

thpr=[-9e9,9e9];[25,65.]
;stop

;cstore=atan(cstore)*!radeg
pos=posarr(2,1,0) & erase
thetap=theta+qwpang*0+45
for ashsel=0,1 do begin
ix=sz(0)/2;9
iy=sz(1)/2;23
;ashsel=0 ; 0 is angle
idx=where(ash eq ashsel and thetap ge thpr[0] and thetap le thpr[1])
c=cstore(idx,ix,iy)
if ashsel eq 0 then c=.5*!radeg*amod(2*!dtor*(90+2*c)/2) ; to correct for inverse
if ashsel eq 1 then c=2*c ;.5*!radeg*amod(2*c*2*!dtor)
epsilon=qwpang*2

cv2non, 2*thetap*!dtor,epsilon*!dtor, chi, delta & chi*=!radeg/2 & delta*=!radeg
plot,c,pos=pos,/noer,yr=[-180,180]
;if ashsel eq 0 then oplot,thetap(idx),col=2
if ashsel eq 0 then oplot,chi(idx),col=3
if ashsel eq 1  then oplot,epsilon(idx),col=2
pos=posarr(/next)
stop
endfor

;stop
regarr=fltarr(sz(0),sz(1),5)
csarr=fltarr(sz(0),sz(1))
devarr=csarr
dev0arr=devarr
;




;tih6 - low verday constatn
regarr_c=fltarr(sz(0),sz(1),5)
csarr_c=fltarr(sz(0),sz(1))
devarr_c=csarr
dev0arr_c=devarr
for ix=0,sz(0)-1 do for iy=0,sz(1)-1 do begin

idx=where(ash eq 0 and thetap ge thpr[0] and thetap le thpr[1]) ;and chi ge 10 and chi le 80) ; 0 is ash
c=cstore(idx,ix,iy)
;c=(90+2*c)/2 ; to correct for inverse
c=.5*!radeg*amod(2*!dtor*(90+2*c)/2) ; to correct for inverse

chi1=chi(idx)
delta1=delta(idx)


idxb=where(ash eq 1 and thetap ge thpr[0] and thetap le thpr[1]); and chi ge 10 and chi le 80)
e=2*cstore(idxb,ix,iy)
eps1=epsilon(idxb)
theta1=thetap(idxb)


;stop

de = e-eps1 ; measured - real

dc = amod(2*!dtor*(c-chi1))*0.5*!radeg

c45=c-45

;measure_errors=(abs(c45) le 20)*(-999) + 1000
cde=regress(transpose([[e],[e^2],[c45],[c45^2]]),de,chisq=chisq_de,yfit=fit_de,const=cde_0  ) & print,chisq_de
regarr(ix,iy,0)=cde_0
regarr(ix,iy,1:4)=cde
csarr(ix,iy)=chisq_de
devarr(ix,iy)=max(abs(de-fit_de))
dev0arr(ix,iy)=max(abs(de))


cdc=regress(transpose([[e],[c45],[c45^2],[e^2]]),dc,chisq=chisq_dc,yfit=fit_dc,const=cdc_0  ) & print,chisq_dc
regarr_c(ix,iy,0)=cdc_0
regarr_c(ix,iy,1:4)=cdc
csarr_c(ix,iy)=chisq_dc
devarr_c(ix,iy)=sqrt(mean((dc-fit_dc)^2 ) )
dev0arr_c(ix,iy)=sqrt(mean(dc^2))

;if total(finite(de)) eq 0 then continue
if (finite(total(de))) eq 0 then continue
print,ix,iy

;if ix eq sz(0)/2 and iy eq sz(1)/2 then mkfig,'~/reg_fit1.eps',xsize=25,ysize=18,font_size=11
plot,fit_de,de,psym=4,pos=posarr(3,3,0,cnx=.1,cny=.1),xtitle='fit_deltaepsilon',ytitle='deltaepsilon'
oplot,fit_de,de-fit_de,psym=4,col=2
plot,c,de,pos=posarr(/next),/noer,psym=4,xtitle='chi',ytitle='deltaepsilon'
plot,e,de,pos=posarr(/next),/noer,psym=4,xtitle='epsilon',ytitle='deltaepsilon'
plot,chi1,c,pos=posarr(/next),/noer,psym=4,xtitle='true chi',ytitle='meas chi'

;oplot,!x.crange,m_chi(ix,iy)*[1,1],col=3

plot,eps1,e,pos=posarr(/next),/noer,psym=4,xtitle='true eps',ytitle='meas eps'

;oplot,!x.crange,m_eps(ix,iy)*[1,1],col=3



if total(finite(dc)) eq 0 then continue

plot,fit_dc,dc,psym=4,pos=posarr(/next),/noer,xtitle='fit_deltachi',ytitle='delta chi'
oplot,fit_dc,dc-fit_dc,psym=4,col=2
plot,c,dc,pos=posarr(/next),/noer,psym=4,xtitle='chi',ytitle='delta chi'
plot,e,dc,pos=posarr(/next),/noer,psym=4,xtitle='epsilon',ytitle='delta chi'

;endfig,/gs,/jp

;stop

print,'ix,iy=',ix,iy,sz(0),sz(1)
if ix eq sz(0)/2 and iy eq sz(1)/2 then stop
;stop
endfor

save, regarr_c, regarr, ixi,iyi,file='~/idl/lt1.sav',/verb


ee2:
m_eps=(myrest2('~/shflipp.sav')).circ * 2
m_chi=(myrest2('~/shflipa.sav')).circ+45


;mkfig,'~/fig_improvement.eps',xsize=17,ysize=17,font_size=10
imgplot,dev0arr_c,/cb,pos=posarr(2,2,0),zr=[0,6],offx=1.,title='original  error in chi (over all epsilon,chi)'
imgplot,devarr_c,/cb,pos=posarr(/next),/noer,zr=[0,6],offx=1.,title='maerror in chi after regression'
imgplot,dev0arr,/cb,pos=posarr(/next),/noer,zr=[0,20],offx=1.,title='original error in epsilon'
imgplot,devarr,/cb,pos=posarr(/next),/noer,zr=[0,20],offx=1.,title='error in epsilon after regression'
endfig,/gs,/jp



thetapa=thetap-45
aa=-5
iw=where(thetapa eq aa and qwpang eq 0 and ash eq 1) ; 1 is ph
ir=where(thetapa eq aa and qwpang eq 0 and ash eq 0) ; 0 is a


 ; zero is ash
      newdemod,img,carsrr,sh=sh2(ir),ifr=iarr2(ir),db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ixi,iy=iyi,p=strr,kx=kx,ky=ky,kz=kz,/doload,cachewrite=cachewrite,cacheread=cacheread ; ir is ash is carsrr


      newdemod,img,cars,sh=sh2(iw),ifr=iarr2(iw)+1,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ixi,iy=iyi,p=strr,kx=kx,ky=ky,kz=kz,/doload,cachewrite=cachewrite,cacheread=cacheread ; iw is psh is cars


p=atan2(cars/carsrr)
pa=p(*,*,ia)
pb=p(*,*,ib)

paj=pa
pbj=pb
;jumpimgh,paj
;jumpimgh,pbj

psum=(paj-pbj)/2*!radeg
pdif=(paj+pbj)/4*!radeg

;denom= (abs(cars(*,*,ia))+abs(cars(*,*,ib)))

;denom= (abs(cars(*,*,ia))+abs(cars(*,*,ib))) ;* abs2(cars(*,*,ia)/carsr(*,*,ia)) / abs(cars(*,*,ia))
denom= 2*(abs(cars(*,*,ia))) ;* abs2(cars(*,*,ia)/carsr(*,*,ia)) / abs(cars(*,*,ia))

;      if ash(k) eq 1 then
 denom=abs(denom) ; zero is ash


numer=        abs2(cars(*,*,ic)/carsr(*,*,ic))
epsx=2*0.5*!radeg*atan($
     numer,denom) 


;denom= (abs(carsrr(*,*,ia))+abs(carsrr(*,*,ib)))
denom= (abs(carsrr(*,*,ia))+abs(carsrr(*,*,ib))) ;* abs2(carsrr(*,*,ia)/carsr(*,*,ia)) / abs(carsrr(*,*,ia))




numer=        abs2(carsrr(*,*,ic)/carsr(*,*,ic))
chix=(90 + 2 * 0.5*!radeg*atan($
     numer,denom) )/2

epsx = -abs(m_eps)*1
chix = -(m_chi-45)+45;m_chi
;chix = m_chi

chix45=chix-45

deps = regarr(*,*,0) + $
      regarr(*,*,1) * epsx + $
      regarr(*,*,2) * epsx^2 + $
      regarr(*,*,3) * chix45 + $
      regarr(*,*,4) * chix45^2 ; meas-real


dchi = regarr_c(*,*,0) + $
      regarr_c(*,*,1) * epsx + $
      regarr_c(*,*,2) * chix45 + $
      regarr_c(*,*,3) * chix45^2 + $
      regarr_c(*,*,4) * epsx^2 ; meas-real
                  
eps = epsx - deps
chi = chix - dchi

cv2non,dummy,eps*!dtor,2*(chi)*!dtor,delta,/back & delta = delta*!radeg

;plot,chix,yr=minmax2([chix,chi])
;oplot,chi,col=2
;mkfig,'lut2.eps',xsize=26,ysize=16,font_size=10
;imgplot,pdif,/cb
imgplot,chix-45,/cb,pal=-2,pos=posarr(2,3,0),title='orig chi-45',zr=[-20,20]
imgplot,chi-45,/cb,pal=-2,pos=posarr(/next),/noer,title='corr chi-45',zr=[-20,20]
imgplot,epsx,/cb,pos=posarr(/next),/noer,title='orig eps',pal=-2
imgplot,eps,/cb,pos=posarr(/next),/noer,title='corr eps',pal=-2
plot,chix(*,45)-45,pos=posarr(/next),/noer,title='compare chi-45, midplane',yr=[-15,15],ysty=1
oplot,chi(*,45)-45,col=2
;oplot,chip(*,45)-45,col=3

legend,['original','corrected with correct elipticity','corrected assuming elipticity is zero'],textcol=[1,2,3],box=0
plot,epsx(*,45),pos=posarr(/next),/noer,title='compare eps, midplane'
oplot,eps(*,45),col=2
legend,['original','corrected with correct elipticity'],textcol=[1,2,3],box=0,/bottom

endfig,/gs,/jp

end





