;sh=8052;3;46
;ifr=155
;sh=8053
;ifr=100
goto,ee

tab0=$
[[21, 0,0],$
[22, 350,0],$
[23, 340,0],$
[24, 0,1],$
[25, 350,1],$
[26, 340,1],$
[27, 330,1],$
[28, 355,1],$
[29, 355,0],$
[30, 330,0]]


qwp_ang0=[0,355,350,340,330]
qwp_ang=[0,-5,-10,-20,-30]
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
linang=linspace(0,90,nang)

linang2 = replicate(1,nsh) # linang
qwp_ang2 = qwp_ang # replicate(1,nang)

demodtype='basic3'

cachewrite=1
cacheread=0
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

   circ=(abs2(cars(*,*,ic)/carsr(*,*,ic))/ (abs(cars(*,*,ia))+abs(cars(*,*,ib))) )

cstore(k,i,ifr,*,*)=circ

endfor
endfor
endfor

ee:

;cstore=atan(cstore)*!radeg
ix=sz(0)/2
iy=sz(1)/2
ia=1

c=reform(cstore(ia,*,*,ix,iy))
end


