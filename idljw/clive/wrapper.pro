;goto,ee

which='old' & dofilt=1.
;sh=87801 & dt=0.01/5 ; 260

;sh=87793 & dt=0.01/5;tw=[.03,.04]; 250 ; outward flux during dithering, inwar dspike at crash
;sh=87792 & dt=0.01/5;tw=[.03,.04]; 240 inward flux few 1019 in dithering state
;which='new'
;sh=87780 & dt=0.01/5;tw=[.03,.04]; 230 loutward flux in downward
;dithering state ~ 1e18 in dithering. out.

;sh=87846 & dt=0.01/5 & which='old' & dofilt=1;tw=[.03,.04]; 250 with poloidal scan

sh=88533 & dt=0.01/5 & which='new' & dofilt=1


t=linspace(.005,.095,10*5)
nt=n_elements(t)
flux=fltarr(nt)
for i=0,nt-1 do begin
myflux2,sh,t(i),dt,dum,which=which,dofilt=dofilt,noplot=0 & flux(i)=dum
print,i,t(i),dum
endfor
ee:
plot,t,flux,psym=-4
oplot,!x.crange,[0,0],linesty=2
dum= getpar( sh, 'isat', tw=[0,.1],y=y)

plot,y.t,y.v>0,/noer,xr=!x.crange
plot,t,flux,psym=-4,col=2,/noer


tspec=(gettiming(sh,nameunit='greg')  -1400.) / 1000.
read_spedb,sh,lam,t,d,str=str




idx=where(lam ge 655.8 and lam le 656.8)



end



