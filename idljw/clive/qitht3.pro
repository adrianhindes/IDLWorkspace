pro qitht3,sh=sh1,ifr=ifr,zeta=zeta1,int=int1,phase=phase1,p1=p1,doplot=doplot,demodtype=demodtype
;newdemod,img,cars,/doplot,sh=77982,db='h',lam=620e-9,demod='basicd44'

;; if sh1 ge 78039 and sh1 le 78041 then begin
;; sh='calibration 7 7-8-2013'
;; simga=getimgnew(sh,0,db='h')*1.0
;; sh='calibration 8 7-8-2013'
;; simgb=getimgnew(sh,0,db='h')*1.0
;; simg=simga-simgb
;; endif else if sh1 lt 78039 then begin
;; sh='calibration 5 7-8-2013'
;; simga=getimgnew(sh,0,db='h')*1.0
;; sh='calibration 6 7-8-2013'
;; simgb=getimgnew(sh,0,db='h')*1.0
;; simg=simga-simgb
;; endif else if sh1 gt 78041 and sh1 lt 78300 then begin
;; sh='calibration 9 7-8-2013'
;; simga=getimgnew(sh,0,db='h')*1.0
;; sh='calibration 10 7-8-2013'
;; simgb=getimgnew(sh,0,db='h')*1.0
;; simg=simga-simgb
;; endif else if sh1 gt 79434 and sh1 le 79526 then begin
;; sh='calibration 1 10-9-2013'
;; simga=getimgnew(sh,0,db='h')*1.0
;; sh='calibration 2 10-9-2013'
;; simgb=getimgnew(sh,0,db='h')*1.0
;; simg=simga-simgb
;; lam=620e-9*1.4
;; endif else if sh1 gt 79528 then begin
;; sh='calibration 3 10-9-2013'
;; simga=getimgnew(sh,0,db='h')*1.0
;; sh='calibration 4 10-9-2013'
;; simgb=getimgnew(sh,0,db='h')*1.0
;; simg=simga-simgb
;; lam=1/1.25*620e-9
;; endif



mdsopen,'h1data',sh1
p=mdsvalue2('\H1DATA::TOP.RF:P_RF_NET')
tw=(ifr-17+5) * 0.01
tw2=tw+0.01
ii=value_locate(p.t,[tw,tw2])
p1=mean(p.v(ii(0):ii(1)))
;stop




default,sh1,77982
default,ifr,19

sh=sh1
readpatch,sh,str,db='h'

simga=getimgnew(str.calfile,0,db='h')*1.0
simgb=getimgnew(str.calfilebg,0,db='h')*1.0

simg=simga-simgb
lam=str.lambdanm*1e-9

default,demodtype,'basicd44'
simg*=10000
newdemod,simg,cal,sh=sh,demodtype=demodtype,ix=ix,iy=iy,p=str,ifr=0,lam=lam,db='h',doplot=doplot

if keyword_set(doplot) then stop
c=cal(*,*,1)/cal(*,*,0)


sh=sh1
simg2a=getimgnew(sh,ifr,db='h')*1.0
simg2b=getimgnew(sh,1,db='h')*1.0
simg2=simg2a-simg2b

newdemod,simg2,cars,sh=sh,demodtype=demodtype,ix=ix,iy=iy,p=str,ifr=ifr,lam=lam,db='h',doplot=doplot,kz=kz,kx=kx,ky=ky

delay=4403;kz(1)
clinbo3, lambda=str.lambdanm*1e-9,kappa=kappa
gdelay=delay*kappa
if str.lambdanm eq 658. then amass=12
mi=amass * 1.67e-27

echarge=1.6e-19

clight=3e8
vchar = clight  /( !pi * (gdelay))
chart = mi * vchar^2 / 2 / echarge

d=cars(*,*,1)/cars(*,*,0)

if keyword_set(doplot) then stop

d=d/c


zeta=abs(d)
temp=-alog(zeta) * chart

phase=atan2(d)
sz=size(phase,/dim)
phase2=phase-phase(sz(0)/2,sz(1)/2)
int=abs(cars(*,*,0))
icol=sz(0)/2 ;15;21 ; 45. * 496./str.lambdanm
int1=int(icol,*)
zeta1=zeta(icol,*)
temp1=temp(icol,*)
phase1=phase(icol,*)
;return

imgplot,int,/cb,pos=posarr(2,3,0),title='intensity '+string(sh,ifr,format='(I0,",",I0)'),xsty=1,ysty=1
imgplot,temp,/cb,zr=[0,30],pos=posarr(/next),/noer,title='temp',xsty=1,ysty=1
;imgplot,zeta,/cb,zr=[0,1],pos=posarr(/next),/noer,title='contrast',xsty=1,ysty=1
imgplot,phase2,/cb,zr=[-1,1],pal=-2,pos=posarr(/next),/noer,title='phase(rad)',xsty=1,ysty=1
imgplot,simg2,/cb,pos=posarr(/next),/noer,title='raw',xsty=1,ysty=1

plot,int(icol,*),pos=posarr(/next),/noer
plot,temp(icol,*),yr=[0,30],pos=posarr(/curr),/noer,col=2
;plot,zeta(icol,*),yr=[0,1],pos=posarr(/curr),/noer,col=2

;stop
yn=''
read,'write to file?',yn
if yn eq 'y' then begin
   temp1=reform(temp1)
   int1=reform(int1)
   writecsv,indgen(128),([[int1],[temp1]]),titles=['pixel','inten','temp(eV)'],file='~/ti_'+string(sh,format='(I0)')+'.csv'
endif



; tmp=getimgnew('Cal_09102012_1',0,info=info,/getinfo,/nostop);.tif and cal_09102012_1_black

; ;tmpblack=getimgn(...black)
; ;tmp=tmp-tmpblack



; ;tmp2=getimgnew(sh,(early time frame),info=info,/getinfo,/nostop);.tif and cal_09102012_1_black


; ;newdemod, tmp,carscalzeta

; ;newdemod, tmp2,carscalphase


; ;cars = cars / abs(carscalzeta)

; ;cars = cars / ( carscalphse/abs(carcalphase) )

; ;phase = atan2(cars)
; ;contrast = abs(cars)



; ;contourn2,r

; imgplot,abs(cars(*,*,1)),xsty=1,ysty=1
; contour,r,xsty=1,ysty=1,/noer,nl=10,c_lab=replicate(1,10)

; end
stop
end

pro scan

;goto,ee
;ifrarr=[17,18,19,20,21]
;sharr=79584 * replicate(1,5)
;sharr=79500 +[intspace(67,76),intspace(82,85)] & off=3.01 & fac=3
sharr=intspace(79720,79726) &  fac=5 & off=2.6 ; off=-1.5
;sharr=79800+[8,9,11,12,13,14,17,18] &  fac=5 & off=2.5 ; off=-1.5
n=n_elements(sharr)
p=fltarr(n)

ifrarr=replicate(21,n)
int=fltarr(128,n)
zeta=int
phase=int
for i=0,n-1 do begin
qitht3,sh=sharr(i),ifr=ifrarr(i),int=int1,zeta=zeta1,phase=phase1,p1=p1
int(*,i)=int1
zeta(*,i)=zeta1
idx=where(finite(phase1))
tmp=phase1
tmp(idx)=phs_jump(phase1(idx))
tmp2 = tmp - tmp(85) + phase1(85)
phase(*,i)=tmp2
p(i)=p1
endfor

ee:
iy=indgen(128)
p=findgen(n)
;mkfig,'~/oldscan.eps',xsize=13,syize=15,font_size=10
contourn2,phase-off,iy,p,/cb,zr=[-0.1,0.1]*fac,/nonice,pal=-2,pos=posarr(1,2,0,cnx=0.1,cny=0.1),xtitle='Y pixel #',ytitle='P_RF_NET (kW)',title='phase/rad (colour) / intensity (contours)'
contour,int,iy,p,/noer,nl=10,pos=posarr(/curr)

contourn2,zeta,iy,p,/cb,zr=[0.45,0.8],/nonice,pos=posarr(/next),/noer,xtitle='Y pixel #',ytitle='P_RF_NET (kW)',title='contrast (colour) / intensity (contours)'

contour,int,iy,p,/noer,nl=10,pos=posarr(/curr)
endfig,/gs,/jp
;plot,int
;plot,zeta,/noer,col=2
;plot,phase,/noer,col=3
end


pro scan514

;goto,ee
;ifrarr=[17,18,19,20,21]
;sharr=79584 * replicate(1,5)
;sharr=79500 +[intspace(67,76),intspace(82,85)] & off=3.01 & fac=3
sharr=81110+[4,5,7,8,9] &  fac=5 & off=2.6 ; off=-1.5
;sharr=79800+[8,9,11,12,13,14,17,18] &  fac=5 & off=2.5 ; off=-1.5
n=n_elements(sharr)
p=fltarr(n)

ifrarr=replicate(21,n)
int=fltarr(128,n)
zeta=int
phase=int
for i=0,n-1 do begin
qitht3,sh=sharr(i),ifr=ifrarr(i),int=int1,zeta=zeta1,phase=phase1,p1=p1
int(*,i)=int1
zeta(*,i)=zeta1
idx=where(finite(phase1))
tmp=phase1
tmp(idx)=phs_jump(phase1(idx))
np=n_elements(phase1)
tmp2 = tmp - tmp(np/2) + phase1(np/2)
phase(*,i)=tmp2
p(i)=p1
endfor

ee:
iy=indgen(128)
p=findgen(n)
;mkfig,'~/oldscan.eps',xsize=13,syize=15,font_size=10
contourn2,phase-off,iy,p,/cb,zr=[-0.1,0.1]*fac,/nonice,pal=-2,pos=posarr(1,2,0,cnx=0.1,cny=0.1),xtitle='Y pixel #',ytitle='P_RF_NET (kW)',title='phase/rad (colour) / intensity (contours)'
contour,int,iy,p,/noer,nl=10,pos=posarr(/curr)

contourn2,zeta,iy,p,/cb,zr=[0.,1],/nonice,pos=posarr(/next),/noer,xtitle='Y pixel #',ytitle='P_RF_NET (kW)',title='contrast (colour) / intensity (contours)'

contour,int,iy,p,/noer,nl=10,pos=posarr(/curr)
endfig,/gs,/jp
;plot,int
;plot,zeta,/noer,col=2
;plot,phase,/noer,col=3
end

pro scan65835

;goto,ee
;ifrarr=[17,18,19,20,21]
;sharr=79584 * replicate(1,5)
;sharr=79500 +[intspace(67,76),intspace(82,85)] & off=3.01 & fac=3
sharr=81130+[5,6,7,8,9] &  fac=5 & off=2.6 ; off=-1.5
;sharr=79800+[8,9,11,12,13,14,17,18] &  fac=5 & off=2.5 ; off=-1.5
n=n_elements(sharr)
p=fltarr(n)

ifrarr=replicate(21,n)
int=fltarr(128,n)
zeta=int
phase=int
for i=0,n-1 do begin
qitht3,sh=sharr(i),ifr=ifrarr(i),int=int1,zeta=zeta1,phase=phase1,p1=p1
int(*,i)=int1
zeta(*,i)=zeta1
idx=where(finite(phase1))
tmp=phase1
tmp(idx)=phs_jump(phase1(idx))
np=n_elements(phase1)
tmp2 = tmp - tmp(np/2) + phase1(np/2)
phase(*,i)=tmp2
p(i)=p1
endfor

ee:
iy=indgen(128)
p=findgen(n)
;mkfig,'~/oldscan.eps',xsize=13,syize=15,font_size=10
contourn2,phase-off,iy,p,/cb,zr=[-0.1,0.1]*fac,/nonice,pal=-2,pos=posarr(1,2,0,cnx=0.1,cny=0.1),xtitle='Y pixel #',ytitle='P_RF_NET (kW)',title='phase/rad (colour) / intensity (contours)'
contour,int,iy,p,/noer,nl=10,pos=posarr(/curr)

contourn2,zeta,iy,p,/cb,zr=[0.,1],/nonice,pos=posarr(/next),/noer,xtitle='Y pixel #',ytitle='P_RF_NET (kW)',title='contrast (colour) / intensity (contours)'

contour,int,iy,p,/noer,nl=10,pos=posarr(/curr)
endfig,/gs,/jp
;plot,int
;plot,zeta,/noer,col=2
;plot,phase,/noer,col=3
end

pro scan65825sav

;goto,ee
;ifrarr=[17,18,19,20,21]
;sharr=79584 * replicate(1,5)
;sharr=79500 +[intspace(67,76),intspace(82,85)] & off=3.01 & fac=3
sharr=81130+[0,1,2,3,4] &  fac=5 & off=2.6 ; off=-1.5
;sharr=79800+[8,9,11,12,13,14,17,18] &  fac=5 & off=2.5 ; off=-1.5
n=n_elements(sharr)
p=fltarr(n)

ifrarr=replicate(21,n)
int=fltarr(128,n)
zeta=int
phase=int
for i=0,n-1 do begin
qitht3,sh=sharr(i),ifr=ifrarr(i),int=int1,zeta=zeta1,phase=phase1,p1=p1
int(*,i)=int1
zeta(*,i)=zeta1
idx=where(finite(phase1))
tmp=phase1
tmp(idx)=phs_jump(phase1(idx))
np=n_elements(phase1)
tmp2 = tmp - tmp(np/2) + phase1(np/2)
phase(*,i)=tmp2
p(i)=p1
endfor

ee:
iy=indgen(128)
p=findgen(n)
;mkfig,'~/oldscan.eps',xsize=13,syize=15,font_size=10
contourn2,phase-off,iy,p,/cb,zr=[-0.1,0.1]*fac,/nonice,pal=-2,pos=posarr(1,2,0,cnx=0.1,cny=0.1),xtitle='Y pixel #',ytitle='P_RF_NET (kW)',title='phase/rad (colour) / intensity (contours)'
contour,int,iy,p,/noer,nl=10,pos=posarr(/curr)

contourn2,zeta,iy,p,/cb,zr=[0.,1],/nonice,pos=posarr(/next),/noer,xtitle='Y pixel #',ytitle='P_RF_NET (kW)',title='contrast (colour) / intensity (contours)'

contour,int,iy,p,/noer,nl=10,pos=posarr(/curr)
endfig,/gs,/jp
;plot,int
;plot,zeta,/noer,col=2
;plot,phase,/noer,col=3
end


pro scan65825

;goto,ee
;ifrarr=[17,18,19,20,21]
;sharr=79584 * replicate(1,5)
;sharr=79500 +[intspace(67,76),intspace(82,85)] & off=3.01 & fac=3
sharr=[$
80682 ,$
;80776 ,$
80705 ,$
;80838,$
80811];,$
;80841]
;80682 - 3.08
;80776 - 8.06
;80705 - 11.27
;80811 - 17.56
;80838 - 14.96
;80841 - 24.20

sharr=[80682, 80776,80705,80811];,80841]

;80682, 80776,80705,80811

   fac=5 & off=2.6 ; off=-1.5
;sharr=79800+[8,9,11,12,13,14,17,18] &  fac=5 & off=2.5 ; off=-1.5
n=n_elements(sharr)
p=fltarr(n)

ifrarr=replicate(21,n)
int=fltarr(128,n)
zeta=int
phase=int
for i=0,n-1 do begin
qitht3,sh=sharr(i),ifr=ifrarr(i),int=int1,zeta=zeta1,phase=phase1,p1=p1
int(*,i)=int1
zeta(*,i)=zeta1
idx=where(finite(phase1))
tmp=phase1
tmp(idx)=phs_jump(phase1(idx))
np=n_elements(phase1)
tmp2 = tmp - tmp(np/2) + phase1(np/2)
phase(*,i)=tmp2
p(i)=p1
endfor

ee:

iy=indgen(128)
p=findgen(n)
;mkfig,'~/oldscan.eps',xsize=13,syize=15,font_size=10
contourn2,phase-off,iy,p,/cb,zr=[-0.1,0.1]*fac,/nonice,pal=-2,pos=posarr(1,2,0,cnx=0.1,cny=0.1),xtitle='Y pixel #',ytitle='P_RF_NET (kW)',title='phase/rad (colour) / intensity (contours)'
contour,int,iy,p,/noer,nl=10,pos=posarr(/curr)

contourn2,zeta,iy,p,/cb,zr=[0.,1],/nonice,pos=posarr(/next),/noer,xtitle='Y pixel #',ytitle='P_RF_NET (kW)',title='contrast (colour) / intensity (contours)'

contour,int,iy,p,/noer,nl=10,pos=posarr(/curr)
endfig,/gs,/jp
;plot,int
;plot,zeta,/noer,col=2
;plot,phase,/noer,col=3
end




;qitht3,sh=80366,ifr=19
;qitht3,sh=79726,ifr=19
;qitht3,sh=79818,ifr=19

;qitht3,sh=80663,ifr=20;1
;qitht3,sh=809697,ifr=20

;end
;
