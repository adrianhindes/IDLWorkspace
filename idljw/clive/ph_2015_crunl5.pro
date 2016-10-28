;goto,ee

sh=[103];77,78,intspace(89,96)]
shref=103 & ifrref=1

nsh=n_elements(sh)

nang=37

np=nsh*nang
sh2=reform( replicate(1,nang) # sh,np)
iarr2=reform((findgen(nang)+1) # replicate(1,nsh)  ,np)
ash=fltarr(np)
theta0=fltarr(np)
dtheta=fltarr(np)
theta=fltarr(np)
qwpang=fltarr(np); & for i=0,np-1 do qwpang(i)=getc(sh2(i))


demodtype='basic3'

cachewrite=1
cacheread=1
doplot=0
db='t5sc'




   newdemod,imgref,carsr,sh=shref,ifr=ifrref,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/doload,cachewrite=cachewrite,cacheread=cacheread

   ia=2
   ib=3
   ic=1                         ;circ

;carsr=carsr/abs(carsr)
sz=size(carsr,/dim)
cstore=complexarr(sz(0),sz(1),sz(2),np)
pastore=fltarr(sz(0),sz(1),np)
pbstore=pastore
psumarr=pastore
pdifarr=pastore


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

      
;      denom= (abs(cars(*,*,ia))+abs(cars(*,*,ib)))
;      numer=        abs2(cars(*,*,ic)/carsr(*,*,ic))
      
;      circ=0.5*!radeg*atan($
;           numer,denom) 
      cstore(*,*,*,k)=cars

      pastore(*,*,k)=atan2(cars(*,*,ic)/carsr(*,*,ic))
      pbstore(*,*,k)=atan2(cars(*,*,ib)/carsr(*,*,ib))
      psumarr(*,*,k)=(pastore(*,*,k)+pbstore(*,*,k))/2.
      pdifarr(*,*,k)=(pastore(*,*,k)-pbstore(*,*,k))/4.
;      stop
      contourn2,(pdifarr(*,*,k)-pdifarr(sz(0)/2,sz(1)/2,k))*!radeg,pal=-2,title='k',/cb
      a='' & read,a
   endfor
endfor



ee:
tmp=pdifarr(sz(0)/2,sz(1)/2,*)
tmp2=phs_jump(tmp*4)/4*!radeg
plot,tmp2
oplot,-theta,col=2
plot,tmp2+theta
end





