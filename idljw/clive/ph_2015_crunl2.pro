;sh=8052;3;46
;ifr=155
;sh=8053
;ifr=100
;goto,ee


dataset=2

if dataset eq 0 then begin
;dataset from 0 to 90:

tab0=[[63,20,0],$
[64,20,1],$
[65,10,0],$
[66,10,1],$
[67,5,0],$
[68,5,1],$
[69,0,0],$
[70,0,1],$
[71,-5,0],$
[72,-5,1],$
[73,-10,0],$
[74,-10,1],$
[75,-20,0],$
[75,-20,1]] & theta0=0 & coffset = -10.
endif

if dataset eq 1 then begin
;dataset from -45 to 45:
tab0=[[49,00,0],$
[50,00,1],$
[51,-5,0],$
[52,-5,1],$
[53,-10,0],$
[54,-10,1],$
[55,-20,0],$
[56,-20,1],$
[57,5,0],$
[58,5,1],$
[59,10,0],$
[60,10,1],$
[61,20,0],$
[62,20,1]]  & theta0=-45 & coffset = -10.
endif

if dataset eq 2 then begin
tab0=[$
[21,0,0],$
[29,-5,0],$
[22,-10,0],$
[23,-20,0],$
[30,-30,0],$
[24,0,1],$
[29,-5,1],$
[25,-10,1],$
[26,-20,1],$
[27,-30,1]] & theta0=0. & coffset=0.
endif


qwp_ang0=[0,-5,-10,-20,-30]
;qwp_ang0=[-20,-10,0,10,20]
qwp_ang=qwp_ang0
tab=fltarr(3,5)
nsh=5
for i=0,nsh-1 do begin
   idx=where( tab0(1,*) eq qwp_ang0(i) and tab0(2,*) eq 0)
   tab(0,i)=tab0(0,idx)
   idx=where( tab0(1,*) eq qwp_ang0(i) and tab0(2,*) eq 1)
   tab(1,i)=tab0(0,idx)
   tab(2,i)=qwp_ang(i)
endfor

shp=tab(0,*)
sha=tab(1,*)

nang=19
linang=linspace(0,90,nang)+theta0

linang2 = replicate(1,nsh) # linang
qwp_ang2 = qwp_ang # replicate(1,nang)



demodtype='basic3'

cachewrite=1
cacheread=1
doplot=0
db='t5a'

kref=1&iref=0&ifrref=9


   newdemod,imgref,carsr,sh=tab(kref,iref),ifr=ifrref,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/doload,cachewrite=cachewrite,cacheread=cacheread

   ia=2
   ib=3
   ic=1                         ;circ

carsr=carsr/abs(carsr)
sz=size(carsr,/dim)
cstore=fltarr(2,nsh,nang,sz(0),sz(1))
for k=0,1 do begin
for i=0,nsh-1 do begin
for ifr=0,nang-1 do begin
   sh1=tab(0+k,i)
;img=getimgnew(sh,db=db,ifr,info=info,/getinfo,/nostop,/nosubindex,str=str)*1.0
   newdemod,img,cars,sh=sh1,ifr=ifr,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/doload,cachewrite=cachewrite,cacheread=cacheread

denom= (abs(cars(*,*,ia))+abs(cars(*,*,ib)))
numer=        abs2(cars(*,*,ic)/carsr(*,*,ic))

   circ=0.5*!radeg*atan($
numer,denom) 

cstore(k,i,ifr,*,*)=circ

endfor
endfor
endfor

ee:

;cstore=atan(cstore)*!radeg
ix=sz(0)/2
iy=sz(1)/2
ia=1

chi=fltarr(nsh,nang)
delta=chi

theta=chi
epsilon=chi
for i=0,nsh-1 do for j=0,nang-1 do begin
   d=coffset*!dtor
   c=linang(j)*!dtor - 45*!dtor
   q=qwp_ang(i)*!dtor
   svec=[1,cos(2*(-c - q))*cos(2*(-d + q)),-(cos(2*(-d + q))*sin(2*(-c - q))),sin(2*(-d + q))]


   chi(i,j)=atan(sqrt(svec(2)^2+svec(3)^2)*sgn(svec(2)) , svec(1) )*!radeg/2 ;- 180
   delta(i,j)=atan(svec(3),svec(2))*!radeg

   theta(i,j)=atan(svec(2),svec(1))*!radeg/2 + 45
   epsilon(i,j)=(-d+q)*!radeg
;   if i eq 1 then stop
endfor



c=reform(cstore(ia,*,*,ix,iy))

iw=3
plot,c(iw,*),yr=[-180,180]
oplot,chi(iw,*),col=2


;endfor



;plotm,l2,transpose(c/2),xticklen=1,yticklen=1
;oplot,l2,-l2
;plotm,l2,transpose(chi),/oplot,linesty=2

end


