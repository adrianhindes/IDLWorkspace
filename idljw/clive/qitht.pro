
newdemod,simg,cal,sh='cal_haitao',demodtype='basic',ix=ix,iy=iy,p=str,/doload,ifr=0

c=cal(*,*,1)/cal(*,*,0)


sh='shot77418'
newdemod,simg2,cars,sh=sh,demodtype='basic',ix=ix,iy=iy,p=str,/doload,ifr=1


d=cars(*,*,1)/cars(*,*,0)


d=d/c

zeta=abs(d)
phase=atan2(d)
sz=size(phase,/dim)
phase2=phase-phase(sz(0)/2,sz(1)/2)
int=abs(cars(*,*,0))
imgplot,int,ix,iy,/cb,pos=posarr(2,2,0),title='intensity '+sh
imgplot,zeta,ix,iy,/cb,zr=[0,1],pos=posarr(/next),/noer,title='contrast'
imgplot,phase2,ix,iy,/cb,zr=[-1,1],pal=-2,pos=posarr(/next),/noer,title='phase(rad)'


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
