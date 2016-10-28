@phs_jump
function getc,sh1
sh=[79,80,81]
ang=[10,0,-10]
iw=value_locate(sh,sh1)
return,ang(iw)
end


;goto,ee2

sh=[80,80,79,79,81,81]
aoff=[0,1,0,1,0,1]
shref=80 & ifrref=6*2+9*2 ; +1 makes it ash, i.e. 3rd carrier is chi
;shref=79 & ifrref=4*2+1

nsh=n_elements(sh)

nang=37

np=nsh*nang
sh2=reform( replicate(1,nang) # sh,np)
iarr2=2*reform(findgen(nang) # replicate(1,nsh)  ,np)
ash=fltarr(np)
theta0=fltarr(np)
dtheta=fltarr(np)
theta=fltarr(np)
qwpang=fltarr(np) & for i=0,np-1 do qwpang(i)=getc(sh2(i))



demodtype='basicnofull2test'
cachewrite=0
cacheread=0
doplot=1
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

img=getimgnew(80,db=db,11,info=info,/getinfo,/nostop,/nosubindex,str=str)*1.0

newdemod,img,cars,sh=80,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ixi,iy=iyi,p=strr,kx=kx,ky=ky,kz=kz
      

      denom= (abs(cars(*,*,ia))+abs(cars(*,*,ib))) ;* abs2(cars(*,*,ia)/carsr(*,*,ia)) / abs(cars(*,*,ia))

      denom=abs(denom)
      numer= -       abs2(cars(*,*,ic)/carsr(*,*,ic))
      
      dum=atan($
           numer,denom) 
      dum2=amod(dum)
      
      circ=0.5*!radeg*dum2;amod(atan($
;           numer,denom) )
;      print,circ(58,45),dum2(58,45),dum(58,45)

imgplot,circ,/cb,pal=-2


end
