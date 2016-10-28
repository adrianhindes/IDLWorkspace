;sh=8052;3;46
;ifr=155
;sh=8053
;ifr=100
;goto,ee

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
[75,-20,1]]

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

qwp_ang0=[-20,-10,0,10,20]
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

cachewrite=0
cacheread=0
doplot=1
db='t5a'

kref=1&iref=0&ifrref=9


   newdemod,imgref,carsr,sh=tab(kref,iref),ifr=ifrref,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,/doload,cachewrite=cachewrite,cacheread=cacheread


end
