pro qitht2,sh=sh1,ifr=ifr
;newdemod,img,cars,/doplot,sh=77982,db='h',lam=620e-9,demod='basicd44'

if sh1 ge 78039 and sh1 le 78041 then begin
sh='calibration 7 7-8-2013'
simga=getimgnew(sh,0,db='h')*1.0
sh='calibration 8 7-8-2013'
simgb=getimgnew(sh,0,db='h')*1.0
simg=simga-simgb
endif else if sh1 lt 78039 then begin
sh='calibration 5 7-8-2013'
simga=getimgnew(sh,0,db='h')*1.0
sh='calibration 6 7-8-2013'
simgb=getimgnew(sh,0,db='h')*1.0
simg=simga-simgb
endif else if sh1 gt 78041 then begin
sh='calibration 9 7-8-2013'
simga=getimgnew(sh,0,db='h')*1.0
sh='calibration 10 7-8-2013'
simgb=getimgnew(sh,0,db='h')*1.0
simg=simga-simgb
endif

newdemod,simg,cal,sh=sh,demodtype='basicd45',ix=ix,iy=iy,p=str,ifr=0,lam=620e-9,db='h',/doplot

;stop
c=cal(*,*,1)/cal(*,*,0)


default,sh1,77982
default,ifr,19
sh=sh1
simg2a=getimgnew(sh,ifr,db='h')*1.0
simg2b=getimgnew(sh,1,db='h')*1.0
simg2=simg2a-simg2b

newdemod,simg2,cars,sh=sh,demodtype='basicd44',ix=ix,iy=iy,p=str,ifr=ifr,lam=620e-9,db='h',/doplot


d=cars(*,*,1)/cars(*,*,0)

;stop
d=d/c

zeta=abs(d)
phase=atan2(d)
sz=size(phase,/dim)
phase2=phase-phase(sz(0)/2,sz(1)/2)
int=abs(cars(*,*,0))
imgplot,int,/cb,pos=posarr(2,2,0),title='intensity '+string(sh,ifr,format='(I0,",",I0)'),xsty=1,ysty=1
imgplot,zeta-1,/cb,zr=[-0.3,0.3],pos=posarr(/next),/noer,title='contrast',pal=-2
imgplot,phase2,/cb,zr=[-1,1],pal=-2,pos=posarr(/next),/noer,title='phase(rad)'


stop




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
end
